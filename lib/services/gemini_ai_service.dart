import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/ai_analysis_models.dart';
import 'ai_exceptions.dart';
import 'ai_logger.dart';

abstract class AiAnalysisService {
  Future<AiAnalysisResult> analyze(AiAnalysisRequest request);
}

class GeminiAiAnalysisService implements AiAnalysisService {
  /// Models verified working with the current API key.
  static const _defaultModel = 'gemini-3.6-flash';
  static const _fallbackModels = [
    'gemini-2.5-pro',
    'gemini-3.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
  ];

  static const _instruction = '''
You are an explanation engine for a Type 2 Diabetes self-management support app.
Explain the patient's current indicators and risk using ONLY the supplied data.
Do not diagnose diseases or prescribe medications.
When a point suggests clinical review (e.g., possible complications, concerning symptoms, abnormal values), clearly say the user should consult a clinician.
Return ONLY valid JSON with this schema:
{
  "confidence": {
    "level": "High|Moderate|Low",
    "reason": "Short reason based on data completeness/recency",
    "dataGaps": ["missing metric 1", "missing metric 2"]
  },
  "cdriScore": 0.0,
  "riskClassification": "Low|Moderate|High",
  "contributingFactors": ["factor 1", "factor 2"],
  "summary": "Brief supportive explanation for the patient",
  "selfManagement": {
    "vitalSigns": [
      { "metric": "Blood Pressure|Fasting Glucose|Random Glucose|HbA1c|BMI|Heart Rate|Other", "valueLabel": "value with unit", "status": "high|low|poor|good|unknown", "guidance": "what this means and what to do" }
    ],
    "behaviors": [
      { "area": "diet|exercise|medicationAdherence", "status": "good|needsImprovement", "guidance": "what to maintain or improve" }
    ]
  },
  "symptomAnalysis": {
    "symptoms": [
      { "symptom": "name", "status": "good|concerning", "guidance": "why it might happen and how to respond", "linkedBehavior": "diet|exercise|medicationAdherence|other|optional" }
    ],
    "complicationPredictions": [
      { "area": "kidney|retinopathy|cardiovascular|other", "riskLevel": "Low|Moderate|High", "insight": "insight + why", "requiresClinicianReview": true }
    ]
  },
  "recommendations": ["optional short tips (non-clinical)"]
}
Keep language simple, supportive, and non-alarming.
Be confident and specific when the advice is generic self-management guidance.
Use explicit cause/effect patterns:
- "This is good because ... Maintain by ..."
- "This is worse because ... Improve by ..."
- "These symptoms are likely due to ... Reduce by ..."
Only mention clinician/clinic when the action should be clinician-approved, or when the situation is concerning/unclear.
''';

  final Duration requestTimeout;

  GeminiAiAnalysisService({this.requestTimeout = const Duration(seconds: 90)});

  @override
  Future<AiAnalysisResult> analyze(AiAnalysisRequest request) async {
    request.validate();

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AiServiceException(
        type: AiFailureType.configuration,
        message: 'GEMINI_API_KEY is not configured',
        userMessage:
            'AI is not configured. Add GEMINI_API_KEY to the .env file.',
      );
    }

    final payload = request.toJson();
    final models = _resolveModels();
    AiServiceException? lastError;

    for (final modelName in models) {
      try {
        return await _analyzeWithModel(
          apiKey: apiKey.trim(),
          modelName: modelName,
          payload: payload,
        );
      } on AiServiceException catch (error) {
        lastError = error;
        AiLogger.warning(
          'Gemini model failed',
          data: {
            'model': modelName,
            'type': error.type.name,
            'statusCode': error.statusCode,
            'message': error.message,
          },
        );

        if (error.type == AiFailureType.modelNotFound) {
          continue;
        }
        rethrow;
      }
    }

    throw lastError ??
        const AiServiceException(
          type: AiFailureType.unavailable,
          message: 'All Gemini models failed',
          userMessage:
              'AI recommendations could not be generated. Please try again shortly.',
        );
  }

  List<String> _resolveModels() {
    final configured = dotenv.env['GEMINI_MODEL']?.trim();
    final models = <String>[
      if (configured != null && configured.isNotEmpty) configured,
      _defaultModel,
      ..._fallbackModels,
    ];
    return models.toSet().toList();
  }

  Future<AiAnalysisResult> _analyzeWithModel({
    required String apiKey,
    required String modelName,
    required Map<String, dynamic> payload,
  }) async {
    AiLogger.logRequest(provider: 'gemini', model: modelName, payload: payload);

    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        //responseMimeType: 'application/json',
      ),
    );

    final prompt =
        '''
$_instruction

Patient data:
${jsonEncode(payload)}
''';

    try {
      final response = await model
          .generateContent([Content.text(prompt)])
          .timeout(requestTimeout);

      _ensureResponseUsable(response);

      final responseText = response.text;
      if (responseText == null || responseText.trim().isEmpty) {
        throw const AiServiceException(
          type: AiFailureType.invalidResponse,
          message: 'Gemini returned an empty response',
          userMessage: 'The AI returned an empty response. Please try again.',
        );
      }

      AiLogger.logResponse(
        provider: 'gemini',
        model: modelName,
        responsePreview: responseText,
      );

      final parsed = _parseJsonResponse(responseText);
      final result = AiAnalysisResult.fromJson(
        parsed,
        provider: 'gemini',
        model: modelName,
      );

      // If JSON schema was incomplete, still show the raw text.
      if (result.formattedText.trim().isEmpty) {
        return AiAnalysisResult(
          provider: 'gemini',
          model: modelName,
          formattedText: responseText.trim(),
          recommendations: [responseText.trim()],
        );
      }

      result.validate();
      return result;
    } on TimeoutException catch (error, stackTrace) {
      AiLogger.error(
        'Gemini request timed out',
        error: error,
        stackTrace: stackTrace,
        data: {'model': modelName},
      );
      throw AiServiceException.fromError(error);
    } on AiServiceException {
      rethrow;
    } catch (error, stackTrace) {
      // Temporary debug prints — remove after tracing.
      // ignore: avoid_print
      print('[Gemini] catch errorType=${error.runtimeType}');
      // ignore: avoid_print
      print('[Gemini] catch error=$error');
      // ignore: avoid_print
      print('[Gemini] catch model=$modelName');
      // ignore: avoid_print
      print('[Gemini] catch stackTrace:\n$stackTrace');
      AiLogger.error(
        'Gemini request failed',
        error: error,
        stackTrace: stackTrace,
        data: {'model': modelName},
      );
      throw _mapSdkError(error);
    }
  }

  void _ensureResponseUsable(GenerateContentResponse response) {
    final feedback = response.promptFeedback;
    if (feedback?.blockReason != null) {
      throw AiServiceException(
        type: AiFailureType.invalidResponse,
        message: 'Prompt blocked: ${feedback!.blockReason}',
        userMessage:
            'The AI could not process this health data. Please try again.',
      );
    }

    if (response.candidates.isEmpty) {
      throw const AiServiceException(
        type: AiFailureType.invalidResponse,
        message: 'Gemini returned no candidates',
        userMessage:
            'The AI did not return a result. Please try again in a moment.',
      );
    }
  }

  AiServiceException _mapSdkError(Object error) {
    if (error is InvalidApiKey) {
      return AiServiceException(
        type: AiFailureType.authentication,
        message: error.message,
        userMessage:
            'The Gemini API key is invalid. Check GEMINI_API_KEY in .env.',
        statusCode: 401,
        cause: error,
      );
    }

    if (error is UnsupportedUserLocation) {
      return AiServiceException(
        type: AiFailureType.unavailable,
        message: error.message,
        userMessage: 'Gemini is not available in your region.',
        cause: error,
      );
    }

    if (error is ServerException) {
      return _mapServerMessage(error.message, cause: error);
    }

    return AiServiceException.fromError(error);
  }

  AiServiceException _mapServerMessage(String message, {Object? cause}) {
    final lower = message.toLowerCase();

    if (lower.contains('quota') ||
        lower.contains('resource_exhausted') ||
        lower.contains('rate limit') ||
        lower.contains('too many requests') ||
        lower.contains('429')) {
      return AiServiceException.quotaExceeded(message, cause: cause);
    }

    if (lower.contains('not found') ||
        lower.contains('no longer available') ||
        lower.contains('is not found') ||
        lower.contains('404')) {
      return AiServiceException(
        type: AiFailureType.modelNotFound,
        message: message,
        userMessage:
            'The AI model is unavailable. The app will try another supported model.',
        statusCode: 404,
        responseBody: message,
        cause: cause,
      );
    }

    if (lower.contains('bad request') || lower.contains('invalid')) {
      return AiServiceException(
        type: AiFailureType.invalidRequest,
        message: message,
        userMessage:
            'The AI request was rejected. Wait a minute, then try again once.',
        statusCode: 400,
        responseBody: message,
        cause: cause,
      );
    }

    if (lower.contains('503') || lower.contains('unavailable')) {
      return AiServiceException(
        type: AiFailureType.unavailable,
        message: message,
        userMessage:
            'Gemini is busy right now. Please wait a moment and try again.',
        statusCode: 503,
        responseBody: message,
        cause: cause,
      );
    }

    return AiServiceException(
      type: AiFailureType.unknown,
      message: message,
      userMessage: message,
      responseBody: message,
      cause: cause,
    );
  }

  Map<String, dynamic> _parseJsonResponse(String responseText) {
    try {
      final decoded = jsonDecode(responseText);
      if (decoded is Map<String, dynamic>) return decoded;
      throw FormatException('Expected JSON object, got ${decoded.runtimeType}');
    } catch (error) {
      final start = responseText.indexOf('{');
      final end = responseText.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        try {
          return jsonDecode(responseText.substring(start, end + 1))
              as Map<String, dynamic>;
        } catch (_) {
          // Fall through — return a text-shaped map so UI can still show content.
          return {
            'summary': responseText.trim(),
            'recommendations': [responseText.trim()],
          };
        }
      }

      return {
        'summary': responseText.trim(),
        'recommendations': [responseText.trim()],
      };
    }
  }
}
