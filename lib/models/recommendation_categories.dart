/// Shared recommendation taxonomy used by Dashboard, Health Analysis, and AI.
class RecommendationTip {
  final String title;
  final String detail;
  final String status; // good | needsImprovement | high | low | poor | info
  final bool requiresClinicianReview;

  const RecommendationTip({
    required this.title,
    required this.detail,
    this.status = 'info',
    this.requiresClinicianReview = false,
  });

  factory RecommendationTip.fromJson(Map<String, dynamic> json) {
    return RecommendationTip(
      title: (json['title'] ?? json['name'] ?? 'Tip').toString(),
      detail: (json['detail'] ?? json['description'] ?? json['tip'] ?? '')
          .toString(),
      status: (json['status'] ?? 'info').toString(),
      requiresClinicianReview:
          json['requiresClinicianReview'] == true ||
          json['consultClinician'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'detail': detail,
    'status': status,
    'requiresClinicianReview': requiresClinicianReview,
  };
}

class VitalSignInsight {
  final String metric;
  final String valueLabel;
  final String status; // high | low | poor | good | unknown
  final String guidance;

  const VitalSignInsight({
    required this.metric,
    required this.valueLabel,
    required this.status,
    required this.guidance,
  });

  factory VitalSignInsight.fromJson(Map<String, dynamic> json) {
    return VitalSignInsight(
      metric: (json['metric'] ?? 'Vital sign').toString(),
      valueLabel: (json['valueLabel'] ?? json['value'] ?? '-').toString(),
      status: (json['status'] ?? 'unknown').toString(),
      guidance: (json['guidance'] ?? json['detail'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'metric': metric,
    'valueLabel': valueLabel,
    'status': status,
    'guidance': guidance,
  };
}

class BehaviorInsight {
  final String area; // diet | exercise | medicationAdherence
  final String status; // good | needsImprovement
  final String guidance;

  const BehaviorInsight({
    required this.area,
    required this.status,
    required this.guidance,
  });

  factory BehaviorInsight.fromJson(Map<String, dynamic> json) {
    return BehaviorInsight(
      area: (json['area'] ?? 'behavior').toString(),
      status: (json['status'] ?? 'needsImprovement').toString(),
      guidance: (json['guidance'] ?? json['detail'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'area': area,
    'status': status,
    'guidance': guidance,
  };
}

class SymptomInsight {
  final String symptom;
  final String status; // good | concerning
  final String guidance;
  final String? linkedBehavior;

  const SymptomInsight({
    required this.symptom,
    required this.status,
    required this.guidance,
    this.linkedBehavior,
  });

  factory SymptomInsight.fromJson(Map<String, dynamic> json) {
    return SymptomInsight(
      symptom: (json['symptom'] ?? json['title'] ?? 'Symptom').toString(),
      status: (json['status'] ?? 'concerning').toString(),
      guidance: (json['guidance'] ?? json['detail'] ?? '').toString(),
      linkedBehavior: json['linkedBehavior']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'symptom': symptom,
    'status': status,
    'guidance': guidance,
    'linkedBehavior': linkedBehavior,
  };
}

class ComplicationInsight {
  final String area; // kidney | retinopathy | cardiovascular | other
  final String riskLevel; // Low | Moderate | High
  final String insight;
  final bool requiresClinicianReview;

  const ComplicationInsight({
    required this.area,
    required this.riskLevel,
    required this.insight,
    this.requiresClinicianReview = true,
  });

  factory ComplicationInsight.fromJson(Map<String, dynamic> json) {
    return ComplicationInsight(
      area: (json['area'] ?? 'other').toString(),
      riskLevel: (json['riskLevel'] ?? 'Moderate').toString(),
      insight: (json['insight'] ?? json['detail'] ?? '').toString(),
      requiresClinicianReview: json['requiresClinicianReview'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
    'area': area,
    'riskLevel': riskLevel,
    'insight': insight,
    'requiresClinicianReview': requiresClinicianReview,
  };
}

class SelfManagementTips {
  final List<VitalSignInsight> vitalSigns;
  final List<BehaviorInsight> behaviors;

  const SelfManagementTips({
    this.vitalSigns = const [],
    this.behaviors = const [],
  });

  factory SelfManagementTips.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SelfManagementTips();
    return SelfManagementTips(
      vitalSigns: CategorizedHealthInsights._mapList(
        json['vitalSigns'],
        VitalSignInsight.fromJson,
      ),
      behaviors: CategorizedHealthInsights._mapList(
        json['behaviors'],
        BehaviorInsight.fromJson,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'vitalSigns': vitalSigns.map((e) => e.toJson()).toList(),
    'behaviors': behaviors.map((e) => e.toJson()).toList(),
  };

  bool get isEmpty => vitalSigns.isEmpty && behaviors.isEmpty;
}

class SymptomAnalysis {
  final List<SymptomInsight> symptoms;
  final List<ComplicationInsight> complicationPredictions;

  const SymptomAnalysis({
    this.symptoms = const [],
    this.complicationPredictions = const [],
  });

  factory SymptomAnalysis.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SymptomAnalysis();
    return SymptomAnalysis(
      symptoms: CategorizedHealthInsights._mapList(
        json['symptoms'],
        SymptomInsight.fromJson,
      ),
      complicationPredictions: CategorizedHealthInsights._mapList(
        json['complicationPredictions'] ?? json['predictions'],
        ComplicationInsight.fromJson,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'symptoms': symptoms.map((e) => e.toJson()).toList(),
    'complicationPredictions': complicationPredictions
        .map((e) => e.toJson())
        .toList(),
  };

  bool get isEmpty => symptoms.isEmpty && complicationPredictions.isEmpty;
}

class CategorizedHealthInsights {
  final double? cdriScore;
  final String? riskClassification;
  final String? summary;
  final SelfManagementTips selfManagement;
  final SymptomAnalysis symptomAnalysis;
  final String source; // local | gemini | cache

  const CategorizedHealthInsights({
    this.cdriScore,
    this.riskClassification,
    this.summary,
    this.selfManagement = const SelfManagementTips(),
    this.symptomAnalysis = const SymptomAnalysis(),
    this.source = 'local',
  });

  factory CategorizedHealthInsights.fromJson(
    Map<String, dynamic> json, {
    String source = 'gemini',
  }) {
    final rawSelfManagement = json['selfManagement'];
    final rawSymptomAnalysis = json['symptomAnalysis'];
    return CategorizedHealthInsights(
      cdriScore: _parseDouble(json['cdriScore'] ?? json['cdri']),
      riskClassification: json['riskClassification']?.toString(),
      summary: json['summary']?.toString(),
      selfManagement: SelfManagementTips.fromJson(
        rawSelfManagement is Map
            ? Map<String, dynamic>.from(rawSelfManagement)
            : null,
      ),
      symptomAnalysis: SymptomAnalysis.fromJson(
        rawSymptomAnalysis is Map
            ? Map<String, dynamic>.from(rawSymptomAnalysis)
            : null,
      ),
      source: source,
    );
  }

  Map<String, dynamic> toJson() => {
    'cdriScore': cdriScore,
    'riskClassification': riskClassification,
    'summary': summary,
    'selfManagement': selfManagement.toJson(),
    'symptomAnalysis': symptomAnalysis.toJson(),
    'source': source,
  };

  bool get hasContent =>
      !selfManagement.isEmpty ||
      !symptomAnalysis.isEmpty ||
      (summary != null && summary!.isNotEmpty) ||
      cdriScore != null;

  static List<T> _mapList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => mapper(Map<String, dynamic>.from(item)))
        .toList();
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
