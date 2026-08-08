import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:diacare/database/blood_pressure_dao.dart';
import 'package:diacare/database/blood_sugar_dao.dart';
import 'package:diacare/database/body_measurement_dao.dart';
import 'package:diacare/database/food_intake_dao.dart';
import 'package:diacare/database/medication_intake_dao.dart';
import 'package:diacare/database/physical_activity_dao.dart';
import 'package:diacare/services/health_data_aggregator.dart';
import 'package:diacare/widgets/app_bottom_nav.dart';
import 'package:diacare/widgets/components.dart';
import 'package:diacare/widgets/profile_icon.dart';
import 'package:diacare/provider/authProvider.dart';
import 'package:diacare/provider/syncProvider.dart';

class Dashboard extends ConsumerStatefulWidget {
  final Map<String, dynamic> userData;
  const Dashboard({super.key, required this.userData});
  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  int _selectedIndex = 0;
  final HealthDataAggregator _aggregator = HealthDataAggregator();
  final BloodPressureDao _bloodPressureDao = BloodPressureDao();
  final BloodSugarDao _bloodSugarDao = BloodSugarDao();
  final BodyMeasurementDao _bodyMeasurementDao = BodyMeasurementDao();
  final FoodIntakeDao _foodIntakeDao = FoodIntakeDao();
  final PhysicalActivityDao _physicalActivityDao = PhysicalActivityDao();
  final MedicationIntakeDao _medicationIntakeDao = MedicationIntakeDao();

  bool _isIndicatorsLoading = true;
  double? _fastingGlucose;
  double? _randomGlucose;
  double? _hba1c;
  double? _avgGlucose7d;
  int? _systolic;
  int? _diastolic;
  double? _avgSystolic7d;
  double? _avgDiastolic7d;
  double? _bmi;
  double? _medicationAdherenceRate7d;
  int? _activityMinutes7d;
  double? _dietLoggingRate7d;
  int _riskScore = 0;
  String _riskLevel = 'Unknown';
  DateTime? _lastRecordedAt;
  List<Map<String, dynamic>> _symptoms = const [];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    dashboardWidget(context, index);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadIndicators);
  }

  Future<void> _loadIndicators() async {
    final user = ref.read(authProvider);
    if (user == null || user.id == null) {
      if (mounted) {
        setState(() {
          _isIndicatorsLoading = false;
        });
      }
      return;
    }

    final request = await _aggregator.buildRequest(user);
    final monitoring = request.monitoring;
    final bpHistory = await _bloodPressureDao.getAllBloodPressureForUser(
      user.id!,
    );
    final sugarHistory = await _bloodSugarDao.getAllBloodSugarForUser(user.id!);

    final bp = monitoring['bloodPressure'];
    int? systolic;
    int? diastolic;
    if (bp is Map) {
      final bpMap = Map<String, dynamic>.from(bp);
      final rawSys = bpMap['systolic'];
      final rawDia = bpMap['diastolic'];
      systolic = rawSys is num ? rawSys.toInt() : int.tryParse('$rawSys');
      diastolic = rawDia is num ? rawDia.toInt() : int.tryParse('$rawDia');
    }

    final symptoms = monitoring['symptoms'];
    final latestSymptoms = symptoms is List
        ? symptoms
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : <Map<String, dynamic>>[];

    final recordedAtRaw = monitoring['recordedAt']?.toString();
    final recordedAt = recordedAtRaw == null
        ? null
        : DateTime.tryParse(recordedAtRaw);

    final medicationIntake = await _medicationIntakeDao.getAllIntakeForUser(
      user.id!,
    );
    final foodIntake = await _foodIntakeDao.getAllFoodForUser(user.id!);
    final activity = await _physicalActivityDao.getAllActivityForUser(user.id!);
    final activityMinutes7d = activity
        .where((record) => _isWithinLastDays(record.exerciseDate, 7))
        .fold<int>(0, (sum, record) => sum + record.durationMinutes);
    final measurements = await _bodyMeasurementDao.getMeasurementsByUserId(
      user.id!,
    );

    final bmi = measurements.isNotEmpty ? measurements.first.bmi : null;
    final fasting = monitoring['fastingGlucose'];
    final random = monitoring['randomGlucose'];
    final hba1c = monitoring['hba1c'];

    final systolic7d = bpHistory
        .where((record) => _isWithinLastDays(record.dateTakenOn, 7))
        .map((record) => record.systolic)
        .toList();
    final diastolic7d = bpHistory
        .where((record) => _isWithinLastDays(record.dateTakenOn, 7))
        .map((record) => record.diastolic)
        .toList();
    final avgSystolic7d = _averageInt(systolic7d);
    final avgDiastolic7d = _averageInt(diastolic7d);

    final glucose7d = sugarHistory
        .where((record) => _isWithinLastDays(record.dateTakenOn, 7))
        .where((record) => !_isHbA1cMeasurement(record.typeMeasurement))
        .map((record) => record.level)
        .toList();
    final avgGlucose7d = _averageDouble(glucose7d);

    final hba1c7d = sugarHistory
        .where((record) => _isWithinLastDays(record.dateTakenOn, 30))
        .where((record) => _isHbA1cMeasurement(record.typeMeasurement))
        .map((record) => record.level)
        .toList();
    final avgHba1c7d = _averageDouble(hba1c7d);

    final daysMedicationTaken7d = medicationIntake
        .where((record) => _isWithinLastDays(record.intakeDate, 7))
        .map((record) => record.intakeDate)
        .whereType<String>()
        .toSet();
    final medicationAdherenceRate7d = daysMedicationTaken7d.isEmpty
        ? 0.0
        : (daysMedicationTaken7d.length / 7).clamp(0.0, 1.0);

    final daysDietLogged7d = foodIntake
        .where((record) => _isWithinLastDays(record.intakeDate, 7))
        .map((record) => record.intakeDate)
        .whereType<String>()
        .toSet();
    final dietLoggingRate7d = daysDietLogged7d.isEmpty
        ? 0.0
        : (daysDietLogged7d.length / 7).clamp(0.0, 1.0);

    final riskScore = _computeRiskScore(
      fastingGlucose:
          avgGlucose7d ?? (fasting is num ? fasting.toDouble() : null),
      randomGlucose: random is num ? random.toDouble() : null,
      hba1c: avgHba1c7d ?? (hba1c is num ? hba1c.toDouble() : null),
      systolic: avgSystolic7d?.round() ?? systolic,
      diastolic: avgDiastolic7d?.round() ?? diastolic,
      bmi: bmi,
      medicationAdherenceRate7d: medicationAdherenceRate7d,
      activityMinutes7d: activityMinutes7d,
      dietLoggingRate7d: dietLoggingRate7d,
      symptoms: latestSymptoms,
    );
    final riskLevel = _riskLevelForScore(riskScore);

    if (!mounted) return;
    setState(() {
      _fastingGlucose = fasting is num ? fasting.toDouble() : null;
      _randomGlucose = random is num ? random.toDouble() : null;
      _hba1c = hba1c is num ? hba1c.toDouble() : null;
      _avgGlucose7d = avgGlucose7d;
      _systolic = systolic;
      _diastolic = diastolic;
      _avgSystolic7d = avgSystolic7d;
      _avgDiastolic7d = avgDiastolic7d;
      _bmi = bmi;
      _medicationAdherenceRate7d = medicationAdherenceRate7d;
      _activityMinutes7d = activityMinutes7d > 0 ? activityMinutes7d : null;
      _dietLoggingRate7d = dietLoggingRate7d;
      _riskScore = riskScore;
      _riskLevel = riskLevel;
      _lastRecordedAt = recordedAt;
      _symptoms = latestSymptoms;
      _isIndicatorsLoading = false;
    });
  }

  int _computeRiskScore({
    required double? fastingGlucose,
    required double? randomGlucose,
    required double? hba1c,
    required int? systolic,
    required int? diastolic,
    required double? bmi,
    required double medicationAdherenceRate7d,
    required int activityMinutes7d,
    required double dietLoggingRate7d,
    required List<Map<String, dynamic>> symptoms,
  }) {
    var score = 0;

    if (fastingGlucose != null) {
      if (fastingGlucose >= 180) {
        score += 30;
      } else if (fastingGlucose >= 130) {
        score += 20;
      } else if (fastingGlucose < 70) {
        score += 20;
      }
    } else if (randomGlucose != null) {
      if (randomGlucose >= 250) {
        score += 30;
      } else if (randomGlucose >= 180) {
        score += 20;
      } else if (randomGlucose < 70) {
        score += 20;
      }
    }

    if (hba1c != null) {
      if (hba1c >= 9) {
        score += 25;
      } else if (hba1c >= 7) {
        score += 15;
      }
    }

    if (systolic != null || diastolic != null) {
      final sys = systolic ?? 0;
      final dia = diastolic ?? 0;
      if (sys >= 160 || dia >= 100) {
        score += 20;
      } else if (sys >= 140 || dia >= 90) {
        score += 15;
      } else if (sys >= 130 || dia >= 80) {
        score += 10;
      }
    }

    if (bmi != null) {
      if (bmi >= 35) {
        score += 20;
      } else if (bmi >= 30) {
        score += 15;
      } else if (bmi >= 25) {
        score += 10;
      }
    }

    if (medicationAdherenceRate7d < 0.5) {
      score += 12;
    } else if (medicationAdherenceRate7d < 0.85) {
      score += 6;
    }

    if (dietLoggingRate7d < 0.4) {
      score += 6;
    } else if (dietLoggingRate7d < 0.7) {
      score += 3;
    }

    if (activityMinutes7d < 60) {
      score += 8;
    } else if (activityMinutes7d < 150) {
      score += 4;
    }

    if (symptoms.isNotEmpty) {
      score += 10;
      final severityScore = symptoms.fold<int>(0, (sum, record) {
        final severity = record['severity']?.toString().toLowerCase() ?? '';
        if (severity.contains('severe') || severity.contains('high'))
          return sum + 10;
        if (severity.contains('moderate') || severity.contains('medium')) {
          return sum + 6;
        }
        return sum + 3;
      });
      score += severityScore.clamp(0, 15);
    }

    return score.clamp(0, 100);
  }

  bool _isWithinLastDays(String? dateString, int days) {
    if (dateString == null || dateString.trim().isEmpty) return false;
    final date = DateTime.tryParse(dateString.trim());
    if (date == null) return false;
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
    final normalized = DateTime(date.year, date.month, date.day);
    return !normalized.isBefore(start);
  }

  bool _isHbA1cMeasurement(String? type) {
    final lower = (type ?? '').toLowerCase();
    return lower.contains('hba1c') ||
        lower.contains('h1ac') ||
        lower.contains('hba1');
  }

  double? _averageInt(List<int> values) {
    if (values.isEmpty) return null;
    final sum = values.fold<int>(0, (a, b) => a + b);
    return sum / values.length;
  }

  double? _averageDouble(List<double> values) {
    if (values.isEmpty) return null;
    final sum = values.fold<double>(0, (a, b) => a + b);
    return sum / values.length;
  }

  String _riskLevelForScore(int score) {
    if (score < 30) return 'Low';
    if (score < 60) return 'Moderate';
    return 'High';
  }

  Color _riskColorForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String _riskMessageForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return "Great direction. Maintain your routines and keep logging your indicators.";
      case 'moderate':
        return "You're doing okay. Focus on improving the indicators that are above target.";
      case 'high':
        return "Some indicators look concerning. Consider discussing your results with a clinician.";
      default:
        return "Keep logging your indicators to understand your trends.";
    }
  }

  Future<void> _syncData() async {
    final user = ref.read(authProvider);
    if (user == null) return;

    await ref.read(syncProvider.notifier).syncNow(user.id ?? 1);

    final syncState = ref.read(syncProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            syncState.status == SyncStatus.success
                ? "Sync completed!"
                : syncState.status == SyncStatus.error
                ? "Sync failed: ${syncState.errorMessage}"
                : "Syncing...",
          ),
          backgroundColor: syncState.status == SyncStatus.success
              ? Colors.green
              : syncState.status == SyncStatus.error
              ? Colors.red
              : Colors.blue,
        ),
      );
    }
  }

  String _formatLastSync(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return "just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final syncState = ref.watch(syncProvider);
    return Focus(
      autofocus: true,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _loadIndicators();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 40,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "DiaCare Dashboard",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const ProfileIcon(),
                          IconButton(
                            icon: syncState.status == SyncStatus.syncing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.notifications_none,
                                    color: Colors.white,
                                  ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: () async {
                              await ref.read(authProvider.notifier).logout();
                              if (mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/Login',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hello, ${user?.nickname ?? 'User'}!",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20).copyWith(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildRiskSection(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildHealthGrid(),
                    const SizedBox(height: 16),
                    _buildMetricsGrid(),
                    const SizedBox(height: 24),
                    _buildWeeklyProgress(),
                    const SizedBox(height: 16),
                    _buildDailySummary(),
                    const SizedBox(height: 24),
                    _buildCDRIComponents(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskSection() {
    final riskColor = _riskColorForLevel(_riskLevel);
    final progressValue = _isIndicatorsLoading
        ? null
        : (_riskScore.clamp(0, 100) / 100);
    final lastUpdateLabel = _lastRecordedAt == null
        ? 'No recent logs'
        : _formatLastSync(_lastRecordedAt!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Indicators Summary",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isIndicatorsLoading ? "Loading..." : _riskLevel,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isIndicatorsLoading
                      ? "Reading your latest logs..."
                      : _riskMessageForLevel(_riskLevel),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(riskColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    _isIndicatorsLoading ? "--" : _riskScore.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "/100",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Last update",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.grey, size: 20),
                  SizedBox(width: 4),
                  Text(
                    lastUpdateLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "based on your logs",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/AIRecommendations');
            },
            icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
            label: const Text(
              "AI Recommendations",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/HealthAnalysis');
            },
            icon: const Icon(Icons.timeline, color: Colors.white),
            label: const Text(
              "View Health Analysis",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthGrid() {
    final bpLabel = (_systolic != null && _diastolic != null)
        ? '${_systolic!}/${_diastolic!}'
        : '--';
    final bpStatus = (_systolic == null || _diastolic == null)
        ? 'No logs'
        : (_systolic! >= 140 || _diastolic! >= 90)
        ? 'High'
        : (_systolic! >= 130 || _diastolic! >= 80)
        ? 'Elevated'
        : 'Normal';
    final bpColor = (_systolic == null || _diastolic == null)
        ? Colors.grey
        : (_systolic! >= 140 || _diastolic! >= 90)
        ? Colors.red
        : (_systolic! >= 130 || _diastolic! >= 80)
        ? Colors.orange
        : Colors.green;

    final glucose = _fastingGlucose ?? _randomGlucose;
    final glucoseUnit = 'mg/dL';
    final glucoseLabel = glucose == null ? '--' : glucose.toStringAsFixed(0);
    final glucoseStatus = glucose == null
        ? 'No logs'
        : glucose < 70
        ? 'Low'
        : glucose <= 140
        ? 'In range'
        : 'High';
    final glucoseColor = glucose == null
        ? Colors.grey
        : glucose < 70
        ? Colors.red
        : glucose <= 140
        ? Colors.green
        : Colors.orange;

    final hba1cLabel = _hba1c == null ? '--' : _hba1c!.toStringAsFixed(1);
    final hba1cStatus = _hba1c == null
        ? 'No logs'
        : _hba1c! < 7
        ? 'On target'
        : _hba1c! < 8
        ? 'Above target'
        : 'High';
    final hba1cColor = _hba1c == null
        ? Colors.grey
        : _hba1c! < 7
        ? Colors.green
        : _hba1c! < 8
        ? Colors.orange
        : Colors.red;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _HealthMetricCard(
          title: 'Heart Rate',
          value: '--',
          unit: 'bpm',
          icon: Icons.favorite_border,
          color: Colors.grey,
          trend: 'No log',
          trendColor: Colors.grey,
        ),
        _HealthMetricCard(
          title: 'Blood Pressure',
          value: bpLabel,
          unit: 'mmHg',
          icon: Icons.water_drop,
          color: bpColor,
          trend: bpStatus,
          trendColor: bpColor,
        ),
        _HealthMetricCard(
          title: 'Blood Glucose',
          value: glucoseLabel,
          unit: glucoseUnit,
          icon: Icons.local_drink,
          color: glucoseColor,
          trend: glucoseStatus,
          trendColor: glucoseColor,
        ),
        _HealthMetricCard(
          title: 'HbA1c',
          value: hba1cLabel,
          unit: '%',
          icon: Icons.percent,
          color: hba1cColor,
          trend: hba1cStatus,
          trendColor: hba1cColor,
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    final medicationRate = _medicationAdherenceRate7d;
    final medicationValue = medicationRate == null
        ? '--'
        : '${(medicationRate * 100).round()}';
    final medicationStatus = medicationRate == null
        ? 'No logs'
        : medicationRate >= 0.85
        ? 'Good'
        : medicationRate >= 0.6
        ? 'Needs work'
        : 'Poor';
    final medicationColor = medicationRate == null
        ? Colors.grey
        : medicationRate >= 0.85
        ? Colors.green
        : medicationRate >= 0.6
        ? Colors.orange
        : Colors.red;

    final dietRate = _dietLoggingRate7d;
    final dietValue = dietRate == null ? '--' : '${(dietRate * 100).round()}';
    final dietStatus = dietRate == null
        ? 'No logs'
        : dietRate >= 0.85
        ? 'Good'
        : dietRate >= 0.6
        ? 'Needs work'
        : 'Poor';
    final dietColor = dietRate == null
        ? Colors.grey
        : dietRate >= 0.85
        ? Colors.green
        : dietRate >= 0.6
        ? Colors.orange
        : Colors.red;

    final activityMinutes7d = _activityMinutes7d;
    final activityValue = activityMinutes7d == null
        ? '--'
        : activityMinutes7d.toString();
    final activityStatus = activityMinutes7d == null
        ? 'No log'
        : activityMinutes7d >= 150
        ? 'Good'
        : activityMinutes7d >= 60
        ? 'Some'
        : 'Low';
    final activityColor = activityMinutes7d == null
        ? Colors.grey
        : activityMinutes7d >= 150
        ? Colors.green
        : activityMinutes7d >= 60
        ? Colors.orange
        : Colors.red;

    final bmiLabel = _bmi == null ? '--' : _bmi!.toStringAsFixed(1);
    final bmiStatus = _bmi == null
        ? 'No logs'
        : _bmi! < 25
        ? 'Healthy'
        : _bmi! < 30
        ? 'Overweight'
        : 'Obese';
    final bmiColor = _bmi == null
        ? Colors.grey
        : _bmi! < 25
        ? Colors.green
        : _bmi! < 30
        ? Colors.orange
        : Colors.red;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _HealthMetricCard(
          title: 'Medication Adherence',
          value: medicationValue,
          unit: '%',
          icon: Icons.medication_liquid,
          color: medicationColor,
          trend: medicationStatus,
          trendColor: medicationColor,
        ),
        _HealthMetricCard(
          title: 'Diet Compliance',
          value: dietValue,
          unit: '%',
          icon: Icons.restaurant,
          color: dietColor,
          trend: dietStatus,
          trendColor: dietColor,
        ),
        _HealthMetricCard(
          title: 'Physical Activity',
          value: activityValue,
          unit: 'min/wk',
          icon: Icons.directions_run,
          color: activityColor,
          trend: activityStatus,
          trendColor: activityColor,
        ),
        _HealthMetricCard(
          title: 'BMI',
          value: bmiLabel,
          unit: 'kg/m²',
          icon: Icons.person,
          color: bmiColor,
          trend: bmiStatus,
          trendColor: bmiColor,
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Last 7 Days',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: _WeeklyActivityChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildDailySummary() {
    return Row(
      children: [
        Expanded(
          child: _DailySummaryCard(
            icon: Icons.directions_walk,
            iconColor: Colors.green,
            value: '5.2 km',
            label: 'Distance Walked This Week',
            bgColor: Colors.green[50]!,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DailySummaryCard(
            icon: Icons.timer,
            iconColor: Colors.orange,
            value: '1h 15m',
            label: 'Total Activity This Week',
            bgColor: Colors.orange[50]!,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DailySummaryCard(
            icon: Icons.water_drop,
            iconColor: Colors.purple,
            value: '7',
            label: 'Logs This Week (All Metrics)',
            bgColor: Colors.purple[50]!,
          ),
        ),
      ],
    );
  }

  Widget _buildCDRIComponents() {
    final riskColor = _riskColorForLevel(_riskLevel);
    final glucose = _avgGlucose7d ?? _fastingGlucose ?? _randomGlucose;
    final glucosePercent = glucose == null
        ? 0.5
        : glucose < 70
        ? 0.4
        : glucose <= 140
        ? 0.85
        : glucose <= 180
        ? 0.65
        : 0.45;
    final sys = _avgSystolic7d?.round() ?? _systolic;
    final dia = _avgDiastolic7d?.round() ?? _diastolic;
    final bpPercent = (sys == null || dia == null)
        ? 0.5
        : (sys >= 160 || dia >= 100)
        ? 0.4
        : (sys >= 140 || dia >= 90)
        ? 0.55
        : (sys >= 130 || dia >= 80)
        ? 0.7
        : 0.9;
    final bmiPercent = _bmi == null
        ? 0.5
        : _bmi! < 25
        ? 0.9
        : _bmi! < 30
        ? 0.7
        : 0.5;
    final medicationRate = _medicationAdherenceRate7d;
    final medicationPercent = medicationRate == null
        ? 0.5
        : (medicationRate >= 0.85
              ? 0.9
              : medicationRate >= 0.6
                  ? 0.7
                  : 0.45);
    final activityMinutes7d = _activityMinutes7d;
    final activityPercent = activityMinutes7d == null
        ? 0.5
        : (activityMinutes7d >= 150
              ? 0.85
              : activityMinutes7d >= 60
                  ? 0.65
                  : 0.45);
    final dietRate = _dietLoggingRate7d;
    final dietPercent = dietRate == null
        ? 0.5
        : (dietRate >= 0.85
              ? 0.8
              : dietRate >= 0.6
                  ? 0.65
                  : 0.5);
    final symptomsPercent = _symptoms.isEmpty ? 0.85 : 0.55;
    final riskFactorsPercent = (100 - _riskScore).clamp(0, 100) / 100;

    final components = [
      {
        'icon': Icons.bloodtype,
        'label': 'Glucose Control',
        'color': Colors.orange,
        'percent': glucosePercent,
      },
      {
        'icon': Icons.medication_liquid,
        'label': 'Medication Adherence',
        'color': Colors.blue,
        'percent': medicationPercent,
      },
      {
        'icon': Icons.fitness_center,
        'label': 'Physical Activity',
        'color': Colors.green,
        'percent': activityPercent,
      },
      {
        'icon': Icons.health_and_safety,
        'label': 'Symptoms',
        'color': Colors.grey,
        'percent': symptomsPercent,
      },
      {
        'icon': Icons.apple,
        'label': 'Diet',
        'color': Colors.green,
        'percent': dietPercent,
      },
      {
        'icon': Icons.favorite,
        'label': 'Blood Pressure',
        'color': Colors.green,
        'percent': bpPercent,
      },
      {
        'icon': Icons.person,
        'label': 'BMI',
        'color': Colors.orange,
        'percent': bmiPercent,
      },
      {
        'icon': Icons.warning,
        'label': 'Overall Risk Factors',
        'color': riskColor,
        'percent': riskFactorsPercent,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Indicator Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See Details',
                  style: TextStyle(color: Color(0xFF4CAF50)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...components.expand((component) {
            final percent = (component['percent'] as double).clamp(0.0, 1.0);
            final value = '${(percent * 100).round()}/100';
            return [
              _CDRIComponent(
                icon: component['icon'] as IconData,
                label: component['label'] as String,
                value: value,
                color: component['color'] as Color,
                percent: percent,
              ),
              const SizedBox(height: 12),
            ];
          }).toList(),
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

class _HealthMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String trend;
  final Color trendColor;

  const _HealthMetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              trend,
              style: TextStyle(
                fontSize: 9,
                color: trendColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityChart extends StatelessWidget {
  const _WeeklyActivityChart();

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Mon';
                    break;
                  case 1:
                    text = 'Tue';
                    break;
                  case 2:
                    text = 'Wed';
                    break;
                  case 3:
                    text = 'Thu';
                    break;
                  case 4:
                    text = 'Fri';
                    break;
                  case 5:
                    text = 'Sat';
                    break;
                  case 6:
                    text = 'Sun';
                    break;
                  default:
                    text = '';
                    break;
                }
                return SideTitleWidget(
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  key: ValueKey(meta),
                  space: 8,
                  axisSide: meta.axisSide,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == 0 || value == 33 || value == 66 || value == 100) {
                  return SideTitleWidget(
                    key: ValueKey(meta),
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                    space: 8,
                    axisSide: meta.axisSide,
                    child: Text(
                      '${value.toInt()}',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [4, 4],
            );
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 48,
                color: const Color(0xFF4CAF50),
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 55,
                color: const Color(0xFF4CAF50),
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 42,
                color: const Color(0xFF4CAF50),
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: 62,
                color: const Color(0xFF4CAF50),
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(
                toY: 50,
                color: const Color(0xFF4CAF50),
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 5,
            barRods: [
              BarChartRodData(
                toY: 58,
                color: const Color(0xFF4CAF50),
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          BarChartGroupData(
            x: 6,
            barRods: [
              BarChartRodData(
                toY: 64,
                color: const Color(0xFF4CAF50),
                width: 12,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color bgColor;

  const _DailySummaryCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CDRIComponent extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double percent;

  const _CDRIComponent({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
