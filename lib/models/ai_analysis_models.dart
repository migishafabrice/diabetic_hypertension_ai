import 'dart:convert';

import 'recommendation_categories.dart';

class AiAnalysisRequest {
  final Map<String, dynamic> patientProfile;
  final Map<String, dynamic> monitoring;
  final List<Map<String, dynamic>> history;

  const AiAnalysisRequest({
    required this.patientProfile,
    required this.monitoring,
    required this.history,
  });

  Map<String, dynamic> toJson() => {
        'patientProfile': patientProfile,
        'monitoring': monitoring,
        'history': history,
      };

  void validate() {
    if (patientProfile.isEmpty) {
      throw const FormatException('patientProfile cannot be empty');
    }

    // Ensure the payload can be JSON-encoded before sending to Gemini.
    try {
      jsonEncode(toJson());
    } catch (error) {
      throw FormatException(
        'AI payload is not JSON-encodable: $error',
      );
    }
  }
}

class AiAnalysisResult {
  final String provider;
  final String? model;
  final double? cdriScore;
  final String? riskClassification;
  final List<String> contributingFactors;
  final List<String> recommendations;
  final String formattedText;

  const AiAnalysisResult({
    required this.provider,
    this.model,
    this.cdriScore,
    this.riskClassification,
    this.contributingFactors = const [],
    this.recommendations = const [],
    required this.formattedText,
  });

  factory AiAnalysisResult.fromJson(
    Map<String, dynamic> json, {
    String provider = 'gemini',
    String? model,
  }) {
    final factors = _parseStringList(json['contributingFactors']);
    final recommendations = _parseRecommendations(json['recommendations']);
    final categorized = CategorizedHealthInsights.fromJson(json, source: provider);
    final confidence = json['confidence'];
    final confidenceMap =
        confidence is Map ? Map<String, dynamic>.from(confidence) : null;
    final confidenceLevel = confidenceMap?['level']?.toString();
    final confidenceReason = confidenceMap?['reason']?.toString();
    final dataGaps = _parseStringList(confidenceMap?['dataGaps']);

    return AiAnalysisResult(
      provider: provider,
      model: model,
      cdriScore: _parseDouble(json['cdriScore'] ?? json['cdri']),
      riskClassification: json['riskClassification'] as String?,
      contributingFactors: factors,
      recommendations: recommendations,
      formattedText: _buildFormattedText(
        cdriScore: _parseDouble(json['cdriScore'] ?? json['cdri']),
        riskClassification: json['riskClassification'] as String?,
        contributingFactors: factors,
        recommendations: recommendations,
        summary: json['summary'] as String?,
        categorizedInsights: categorized,
        confidenceLevel: confidenceLevel,
        confidenceReason: confidenceReason,
        dataGaps: dataGaps,
      ),
    );
  }

  factory AiAnalysisResult.fromBackendResponse(Map<String, dynamic> json) {
    final provider = json['provider'] as String? ?? 'backend';
    final recommendationsText = json['recommendations'] as String? ?? '';

    return AiAnalysisResult(
      provider: provider,
      formattedText: recommendationsText,
      recommendations: recommendationsText
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(),
    );
  }

  void validate() {
    if (formattedText.trim().isEmpty &&
        recommendations.isEmpty &&
        cdriScore == null &&
        riskClassification == null) {
      throw const FormatException('AI response did not contain usable data');
    }
  }

  Map<String, dynamic> toDisplayMap() => {
        'provider': provider,
        'model': model,
        'recommendations': formattedText,
        'cdriScore': cdriScore,
        'riskClassification': riskClassification,
        'contributingFactors': contributingFactors,
      };

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  static List<String> _parseRecommendations(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      return value
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    }
    return [];
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String _buildFormattedText({
    double? cdriScore,
    String? riskClassification,
    List<String> contributingFactors = const [],
    List<String> recommendations = const [],
    String? summary,
    CategorizedHealthInsights? categorizedInsights,
    String? confidenceLevel,
    String? confidenceReason,
    List<String> dataGaps = const [],
  }) {
    final buffer = StringBuffer();

    if (cdriScore != null || riskClassification != null) {
      buffer.writeln('Overall Health Assessment:');
      if (cdriScore != null) {
        buffer.writeln(
          '- Composite score (CDRI): $cdriScore (based on your logged indicators)',
        );
      }
      if (riskClassification != null) {
        buffer.writeln('- Risk level: $riskClassification');
      }
      buffer.writeln();
    }

    if ((confidenceLevel != null && confidenceLevel.isNotEmpty) ||
        (confidenceReason != null && confidenceReason.isNotEmpty) ||
        dataGaps.isNotEmpty) {
      buffer.writeln('Confidence:');
      if (confidenceLevel != null && confidenceLevel.isNotEmpty) {
        buffer.writeln('- Level: $confidenceLevel');
      }
      if (confidenceReason != null && confidenceReason.isNotEmpty) {
        buffer.writeln('- Reason: $confidenceReason');
      }
      if (dataGaps.isNotEmpty) {
        buffer.writeln('- Data gaps: ${dataGaps.join(', ')}');
      }
      buffer.writeln();
    }

    if (summary != null && summary.isNotEmpty) {
      buffer.writeln(summary);
      buffer.writeln();
    }

    if (contributingFactors.isNotEmpty) {
      buffer.writeln('Complication Risk:');
      for (final factor in contributingFactors) {
        buffer.writeln('- $factor');
      }
      buffer.writeln();
    }

    if (categorizedInsights != null && categorizedInsights.hasContent) {
      final selfManagement = categorizedInsights.selfManagement;
      final symptomAnalysis = categorizedInsights.symptomAnalysis;

      if (!selfManagement.isEmpty) {
        buffer.writeln('Self Management Tips:');
        if (selfManagement.vitalSigns.isNotEmpty) {
          buffer.writeln('Measurements of Vital Signs:');
          for (final insight in selfManagement.vitalSigns) {
            buffer.writeln(_formatVitalSignInsight(insight));
          }
          buffer.writeln();
        }

        if (selfManagement.behaviors.isNotEmpty) {
          buffer.writeln('Behaviors:');
          for (final behavior in selfManagement.behaviors) {
            buffer.writeln(_formatBehaviorInsight(behavior));
          }
          buffer.writeln();
        }
      }

      if (!symptomAnalysis.isEmpty) {
        buffer.writeln('Symptoms Analysis:');
        if (symptomAnalysis.symptoms.isNotEmpty) {
          buffer.writeln('Symptoms:');
          for (final symptom in symptomAnalysis.symptoms) {
            buffer.writeln(_formatSymptomInsight(symptom));
          }
          buffer.writeln();
        }

        if (symptomAnalysis.complicationPredictions.isNotEmpty) {
          buffer.writeln('Possible Complication Risks:');
          for (final prediction in symptomAnalysis.complicationPredictions) {
            final consult = prediction.requiresClinicianReview
                ? ' Consult a clinician.'
                : '';
            buffer.writeln(
              '- ${_formatComplicationArea(prediction.area)} (${prediction.riskLevel}): ${_normalizeSentence(prediction.insight)}$consult',
            );
          }
          buffer.writeln();
        }
      }
    }

    if (recommendations.isNotEmpty) {
      buffer.writeln('Actionable Steps:');
      for (final recommendation in recommendations) {
        buffer.writeln('- $recommendation');
      }
    }

    return buffer.toString().trim();
  }

  static String _formatVitalSignInsight(VitalSignInsight insight) {
    final metric = insight.metric.trim().isEmpty ? 'Vital sign' : insight.metric;
    final valueLabel =
        insight.valueLabel.trim().isEmpty ? '' : ' (${insight.valueLabel.trim()})';
    final status = insight.status.trim().toLowerCase();

    String prefix;
    if (status == 'good') {
      prefix = 'This is good because ';
    } else if (status == 'high' || status == 'low' || status == 'poor') {
      prefix = 'This is worse because ';
    } else {
      prefix = '';
    }

    final guidance = insight.guidance.trim();
    final normalized = _normalizeBecausePattern(guidance, prefix: prefix);
    final statusLabel = insight.status.trim().isEmpty ? '' : ' (${insight.status})';
    return '- $metric$valueLabel$statusLabel: $normalized';
  }

  static String _formatBehaviorInsight(BehaviorInsight behavior) {
    final area = _formatBehaviorArea(behavior.area);
    final status = behavior.status.trim().toLowerCase();
    final statusLabel = behavior.status.trim().isEmpty ? '' : ' (${behavior.status})';
    final guidance = behavior.guidance.trim();

    final prefix = status == 'good'
        ? 'This is good because '
        : status == 'needsimprovement' || status == 'needs_improvement'
        ? 'This is worse because '
        : '';
    final normalized = _normalizeBecausePattern(guidance, prefix: prefix);
    return '- $area$statusLabel: $normalized';
  }

  static String _formatSymptomInsight(SymptomInsight symptom) {
    final name = symptom.symptom.trim().isEmpty ? 'Symptom' : symptom.symptom;
    final status = symptom.status.trim().toLowerCase();
    final statusLabel = symptom.status.trim().isEmpty ? '' : ' (${symptom.status})';
    final linked = (symptom.linkedBehavior == null ||
            symptom.linkedBehavior!.trim().isEmpty)
        ? ''
        : ' (linked to ${symptom.linkedBehavior})';
    final guidance = symptom.guidance.trim();

    final prefix = status == 'good'
        ? 'This is good because '
        : status == 'concerning'
        ? 'These symptoms are likely due to '
        : '';
    final normalized = _normalizeBecausePattern(guidance, prefix: prefix);
    return '- $name$statusLabel$linked: $normalized';
  }

  static String _normalizeBecausePattern(String text, {required String prefix}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'Keep logging to get clearer guidance.';

    final lower = trimmed.toLowerCase();
    if (lower.contains('because') ||
        lower.contains('likely due to') ||
        lower.startsWith('this is good') ||
        lower.startsWith('this is worse') ||
        lower.startsWith('these symptoms')) {
      return _normalizeSentence(trimmed);
    }

    if (prefix.isEmpty) return _normalizeSentence(trimmed);
    return _normalizeSentence('$prefix$trimmed');
  }

  static String _normalizeSentence(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.endsWith('.')) return trimmed;
    return '$trimmed.';
  }

  static String _formatBehaviorArea(String value) {
    switch (value.toLowerCase()) {
      case 'diet':
        return 'Diet';
      case 'exercise':
        return 'Exercise';
      case 'medicationadherence':
      case 'medication_adherence':
      case 'medication':
        return 'Medication adherence';
      default:
        return value.isEmpty ? 'Behavior' : value;
    }
  }

  static String _formatComplicationArea(String value) {
    switch (value.toLowerCase()) {
      case 'kidney':
        return 'Kidney';
      case 'retinopathy':
        return 'Retinopathy';
      case 'cardiovascular':
      case 'cardio':
        return 'Cardiovascular';
      default:
        return value.isEmpty ? 'Other' : value;
    }
  }
}
