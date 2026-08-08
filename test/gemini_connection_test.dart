import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:diacare/services/gemini_ai_service.dart';
import 'package:diacare/models/ai_analysis_models.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
  });

  test('Diagnostic: test raw Gemini API call and model compatibility', () async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    stdout.writeln('\n=========================================');
    stdout.writeln('GEMINI DIAGNOSTIC TEST');
    stdout.writeln('API Key configured: ${apiKey != null && apiKey.isNotEmpty}');
    if (apiKey != null && apiKey.isNotEmpty) {
      stdout.writeln('API Key length: ${apiKey.length}');
      stdout.writeln('API Key prefix: ${apiKey.substring(0, 6)}...');
    }
    final envModel = dotenv.env['GEMINI_MODEL'];
    stdout.writeln('Configured GEMINI_MODEL in .env: "$envModel"');
    stdout.writeln('=========================================\n');

    final modelsToTest = [
      if (envModel != null && envModel.isNotEmpty) envModel,
      'gemini-3.6-flash',
      'gemini-2.5-pro',
      'gemini-3.5-flash',
      'gemini-3.5-flash-lite',
      'gemini-3.1-flash-lite',
    ];

    for (final modelName in modelsToTest) {
      stdout.writeln('--> Testing modelName: "$modelName" ...');
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey ?? '',
          generationConfig: GenerationConfig(
            temperature: 0.3,
            responseMimeType: 'application/json',
          ),
        );

        final response = await model.generateContent([
          Content.text('Return valid JSON: {"status": "ok"}'),
        ]).timeout(const Duration(seconds: 15));

        stdout.writeln('   SUCCESS [$modelName] -> Response: ${response.text}');
      } catch (e) {
        stdout.writeln('   FAILED [$modelName] -> Error Type: ${e.runtimeType}');
        stdout.writeln('   FAILED [$modelName] -> Exception: $e');
      }
    }
  });

  test('Diagnostic: test GeminiAiAnalysisService', () async {
    final service = GeminiAiAnalysisService();
    final request = AiAnalysisRequest(
      patientProfile: {'age': 45, 'sex': 'Male'},
      monitoring: {'systolicBp': 135, 'diastolicBp': 85, 'fastingGlucose': 110},
      history: [],
    );

    stdout.writeln('\n--> Testing GeminiAiAnalysisService.analyze()...');
    try {
      final result = await service.analyze(request);
      stdout.writeln('   SUCCESS -> CDRI Score: ${result.cdriScore}, Classification: ${result.riskClassification}');
    } catch (e) {
      stdout.writeln('   FAILED -> Error: $e');
    }
  });
}
