import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/blood_pressure_dao.dart';
import '../database/blood_sugar_dao.dart';
import '../database/symptom_dao.dart';
import '../provider/authProvider.dart';
import '../models/local_blood_pressure.dart';
import '../models/local_blood_sugar.dart';
import '../models/local_symptom.dart';
import '../widgets/profile_icon.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/components.dart';

class HealthAnalysis extends ConsumerStatefulWidget {
  const HealthAnalysis({super.key});

  @override
  ConsumerState<HealthAnalysis> createState() => _HealthAnalysisState();
}

class _HealthAnalysisState extends ConsumerState<HealthAnalysis> {
  final BloodPressureDao _bloodPressureDao = BloodPressureDao();
  final BloodSugarDao _bloodSugarDao = BloodSugarDao();
  final SymptomDao _symptomDao = SymptomDao();
  List<LocalBloodPressure>? bloodPressureRecords = [];
  List<LocalBloodSugar>? bloodSugarRecords = [];
  List<LocalSymptom>? symptomRecords = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    dashboardWidget(context, index);
  }

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final user = ref.read(authProvider);
    if (user?.id != null) {
      final bpList = await _bloodPressureDao.getAllBloodPressureForUser(
        user!.id!,
      );
      final bsList = await _bloodSugarDao.getAllBloodSugarForUser(user.id!);
      final symList = await _symptomDao.getAllSymptomsForUser(user.id!);
      setState(() {
        bloodPressureRecords = bpList;
        bloodSugarRecords = bsList;
        symptomRecords = symList;
        isLoading = false;
      });
    }
  }

  double get healthScore {
    int total = 0;

    // Blood pressure score
    if (bloodPressureRecords?.isNotEmpty ?? false) {
      int goodCount = 0;
      for (final rec in bloodPressureRecords!) {
        if (rec.systolic <= 120 && rec.diastolic <= 80) {
          goodCount++;
        }
      }
      total += (goodCount / bloodPressureRecords!.length * 40).round();
    }

    // Blood sugar score
    if (bloodSugarRecords?.isNotEmpty ?? false) {
      int goodCount = 0;
      for (final rec in bloodSugarRecords!) {
        if (rec.level >= 70 && rec.level <= 140) {
          goodCount++;
        }
      }
      total += (goodCount / bloodSugarRecords!.length * 40).round();
    }

    // Add base score for activity (placeholder)
    total += 20;
    return total.toDouble();
  }

  List<String> get selfManagementTips {
    final tips = <String>[];

    final latestBp = (bloodPressureRecords?.isNotEmpty ?? false)
        ? bloodPressureRecords!.first
        : null;
    if (latestBp != null) {
      final isHigh = latestBp.systolic >= 140 || latestBp.diastolic >= 90;
      final isElevated = latestBp.systolic >= 130 || latestBp.diastolic >= 80;
      if (isHigh) {
        tips.add(
          "Blood pressure looks high in your latest log. Re-check at rest, reduce salt, and consult a clinician if readings stay high.",
        );
      } else if (isElevated) {
        tips.add(
          "Blood pressure is slightly elevated. Focus on hydration, lower salt, and keep measuring regularly.",
        );
      } else {
        tips.add(
          "Blood pressure is in a good range. Maintain your current routines and continue regular checks.",
        );
      }
    } else {
      tips.add("Log blood pressure to get personalized guidance.");
    }

    final latestSugar = (bloodSugarRecords?.isNotEmpty ?? false)
        ? bloodSugarRecords!.first
        : null;
    if (latestSugar != null) {
      if (latestSugar.level < 70) {
        tips.add(
          "Blood sugar appears low in your latest log. Monitor closely and consult a clinician if you feel unwell or readings stay low.",
        );
      } else if (latestSugar.level > 140) {
        tips.add(
          "Blood sugar is above target in your latest log. Review meal portions and activity, and consult a clinician/dietitian for tailored advice.",
        );
      } else {
        tips.add(
          "Blood sugar is within target range. Keep maintaining your diet, activity, and medication routine.",
        );
      }
    } else {
      tips.add("Log blood sugar to see whether your readings are on target.");
    }

    tips.add(
      "Maintain good behaviors: balanced meals, regular activity, and consistent medication adherence (as prescribed by your clinician).",
    );

    return tips;
  }

  List<String> get symptomAnalysisTips {
    final tips = <String>[];

    final recent = (symptomRecords ?? const []).take(3).toList();
    if (recent.isEmpty) {
      tips.add(
        "No symptoms logged. If you notice dizziness, blurred vision, swelling, chest discomfort, or unusual fatigue, log it and consult a clinician if severe.",
      );
    } else {
      for (final symptom in recent) {
        final severity = symptom.severity?.toString() ?? 'unknown';
        tips.add(
          "Symptom: ${symptom.symptomName} (severity: $severity). If it worsens or affects daily activities, consult a clinician.",
        );
      }
    }

    final hasHighSugar = bloodSugarRecords?.any((r) => r.level > 180) ?? false;
    final hasHighBp =
        bloodPressureRecords?.any(
          (r) => r.systolic >= 140 || r.diastolic >= 90,
        ) ??
        false;
    if (hasHighSugar || hasHighBp) {
      tips.add(
        "If high readings persist, consider clinician-approved screening discussions for kidney, eye (retinopathy), and cardiovascular health.",
      );
    }

    return tips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DiaCare Health Analysis"),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        actions: const [ProfileIcon()],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Health Score Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const Text(
                                  "Your Health Score",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 8,
                                      color: const Color(0xFF4CAF50),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      healthScore.toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: healthScore / 100,
                                  backgroundColor: Colors.grey[300],
                                  color: const Color(0xFF4CAF50),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Self Management Tips",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...selfManagementTips.map(
                          (rec) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.lightbulb,
                                color: Color(0xFFFFC107),
                              ),
                              title: Text(rec),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Symptoms Analysis",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...symptomAnalysisTips.map(
                          (rec) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.health_and_safety,
                                color: Color(0xFF1E88E5),
                              ),
                              title: Text(rec),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Your Logs",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.monitor_heart,
                                    color: Color(0xFFE53935),
                                  ),
                                  title: const Text("Blood Pressure Tracking"),
                                  subtitle: Text(
                                    "${bloodPressureRecords?.length ?? 0} records",
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(
                                    Icons.opacity,
                                    color: Color(0xFF1E88E5),
                                  ),
                                  title: const Text("Blood Sugar Tracking"),
                                  subtitle: Text(
                                    "${bloodSugarRecords?.length ?? 0} records",
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(
                                    Icons.health_and_safety,
                                    color: Color(0xFF1E88E5),
                                  ),
                                  title: const Text("Symptoms Tracking"),
                                  subtitle: Text(
                                    "${symptomRecords?.length ?? 0} records",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
