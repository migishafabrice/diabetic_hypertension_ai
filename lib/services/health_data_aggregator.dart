import '../models/local_blood_pressure.dart';
import '../models/local_blood_sugar.dart';
import '../models/local_body_measurement.dart';
import '../models/local_food_intake.dart';
import '../models/local_medication_intake.dart';
import '../models/local_physical_activity.dart';
import '../models/local_symptom.dart';
import '../models/local_user.dart';
import '../models/ai_analysis_models.dart';
import '../database/blood_pressure_dao.dart';
import '../database/blood_sugar_dao.dart';
import '../database/body_measurement_dao.dart';
import '../database/food_intake_dao.dart';
import '../database/medication_intake_dao.dart';
import '../database/physical_activity_dao.dart';
import '../database/symptom_dao.dart';

class HealthDataAggregator {
  final BloodPressureDao _bloodPressureDao = BloodPressureDao();
  final BloodSugarDao _bloodSugarDao = BloodSugarDao();
  final BodyMeasurementDao _bodyMeasurementDao = BodyMeasurementDao();
  final FoodIntakeDao _foodIntakeDao = FoodIntakeDao();
  final PhysicalActivityDao _physicalActivityDao = PhysicalActivityDao();
  final MedicationIntakeDao _medicationIntakeDao = MedicationIntakeDao();
  final SymptomDao _symptomDao = SymptomDao();

  Future<AiAnalysisRequest> buildRequest(
    LocalUser user, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = user.id!;
    final bloodPressure = await _bloodPressureDao.getAllBloodPressureForUser(
      userId,
    );
    final bloodSugar = await _bloodSugarDao.getAllBloodSugarForUser(userId);
    final bodyMeasurements = await _bodyMeasurementDao.getMeasurementsByUserId(
      userId,
    );
    final foodIntake = await _foodIntakeDao.getAllFoodForUser(userId);
    final exercise = await _physicalActivityDao.getAllActivityForUser(userId);
    final medicationIntake = await _medicationIntakeDao.getAllIntakeForUser(
      userId,
    );
    final symptoms = await _symptomDao.getAllSymptomsForUser(userId);

    // Determine the date range for filtering
    final effectiveEndDate = endDate ?? DateTime.now();
    final effectiveStartDate = startDate ??
        effectiveEndDate.subtract(const Duration(days: 6));

    bool isInRange(String? dateString) {
      return _isWithinRange(
        dateString,
        effectiveStartDate,
        effectiveEndDate,
      );
    }

    final rangeDays = effectiveEndDate
            .difference(effectiveStartDate)
            .inDays +
        1;

    final bloodPressureWeek =
        bloodPressure.where((record) => isInRange(record.dateTakenOn)).toList();
    final bloodSugarWeek =
        bloodSugar.where((record) => isInRange(record.dateTakenOn)).toList();
    final bodyMeasurementsWeek = bodyMeasurements
        .where((record) => isInRange(record.measurementDate))
        .toList();
    final foodIntakeWeek = foodIntake
        .where((record) => isInRange(record.intakeDate))
        .toList();
    final exerciseWeek =
        exercise.where((record) => isInRange(record.exerciseDate)).toList();
    final medicationIntakeWeek = medicationIntake
        .where((record) => isInRange(record.intakeDate))
        .toList();
    final symptomsWeek = symptoms
        .where((record) => isInRange(record.recordedDate))
        .toList();

    final latestMeasurement = bodyMeasurements.isNotEmpty
        ? bodyMeasurements.first
        : null;
    final latestBloodPressure = bloodPressure.isNotEmpty
        ? bloodPressure.first
        : null;
    final latestFood = foodIntake.isNotEmpty ? foodIntake.first : null;
    final latestExercise = exercise.isNotEmpty ? exercise.first : null;

    return AiAnalysisRequest(
      patientProfile: _buildPatientProfile(
        user,
        bodyMeasurementsWeek.isNotEmpty ? bodyMeasurementsWeek.first : latestMeasurement,
      ),
      monitoring: _buildMonitoring(
        bloodSugar: bloodSugarWeek,
        bloodPressureWeek: bloodPressureWeek,
        latestBloodPressure:
            bloodPressureWeek.isNotEmpty ? bloodPressureWeek.first : latestBloodPressure,
        latestFood: foodIntakeWeek.isNotEmpty ? foodIntakeWeek.first : latestFood,
        latestExercise:
            exerciseWeek.isNotEmpty ? exerciseWeek.first : latestExercise,
        medicationIntakeWeek: medicationIntakeWeek,
        foodIntakeWeek: foodIntakeWeek,
        exerciseWeek: exerciseWeek,
        symptoms: symptomsWeek,
        rangeDays: rangeDays,
        startDate: effectiveStartDate,
        endDate: effectiveEndDate,
      ),
      history: _buildHistory(
        bloodSugar: bloodSugarWeek,
        bloodPressure: bloodPressureWeek,
        bodyMeasurements: bodyMeasurementsWeek,
        foodIntake: foodIntakeWeek,
        exercise: exerciseWeek,
        medicationIntake: medicationIntakeWeek,
        symptoms: symptomsWeek,
      ),
    );
  }

  Map<String, dynamic> _buildPatientProfile(
    LocalUser user,
    LocalBodyMeasurement? latestMeasurement,
  ) {
    return {
      'age': _calculateAge(user.dob),
      'sex': user.sex,
      'bmi': latestMeasurement?.bmi,
      'smokingStatus': user.smokingStatus,
      'alcoholConsumption': user.alcoholConsumption,
    };
  }

  Map<String, dynamic> _buildMonitoring({
    required List<LocalBloodSugar> bloodSugar,
    required List<LocalBloodPressure> bloodPressureWeek,
    required LocalBloodPressure? latestBloodPressure,
    required LocalFoodIntake? latestFood,
    required LocalPhysicalActivity? latestExercise,
    required List<LocalMedicationIntake> medicationIntakeWeek,
    required List<LocalFoodIntake> foodIntakeWeek,
    required List<LocalPhysicalActivity> exerciseWeek,
    required List<LocalSymptom> symptoms,
    required int rangeDays,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final glucoseReadings = bloodSugar
        .where((record) => !_isHbA1cMeasurement(record.typeMeasurement))
        .map((record) => record.level)
        .toList();
    final glucoseAverage7d = _averageDouble(glucoseReadings);

    final fastingGlucose = _latestGlucoseByTypes(bloodSugar, const [
      'Fasting',
      'fasting',
    ]);
    final randomGlucose = _latestGlucoseByTypes(bloodSugar, const [
      'Random',
      'random',
    ]);
    final hba1c = _latestGlucoseByTypes(bloodSugar, const [
      'H1AC',
      'HbA1c',
      'HBA1C',
      'hba1c',
    ]);

    final systolicAvg7d = _averageInt(bloodPressureWeek.map((e) => e.systolic).toList());
    final diastolicAvg7d =
        _averageInt(bloodPressureWeek.map((e) => e.diastolic).toList());

    final notes = <String>[];
    for (final record in bloodSugar) {
      if (record.note != null && record.note!.isNotEmpty) {
        notes.add(record.note!);
      }
    }
    if (latestBloodPressure?.note != null &&
        latestBloodPressure!.note!.isNotEmpty) {
      notes.add(latestBloodPressure.note!);
    }

    final medicationAdherenceRate7d =
        _adherenceRateByDistinctDays(
          medicationIntakeWeek.map((e) => e.intakeDate),
          rangeDays,
        );
    final dietLoggingRate7d =
        _adherenceRateByDistinctDays(
          foodIntakeWeek.map((e) => e.intakeDate),
          rangeDays,
        );
    final activityMinutes7d = exerciseWeek.fold<int>(
      0,
      (sum, record) => sum + record.durationMinutes,
    );

    final latestSymptoms = symptoms
        .take(3)
        .map(
          (record) => {
            'symptomName': record.symptomName,
            'severity': record.severity,
            'notes': record.note,
            'recordedAt': _combineDateTime(
              record.recordedDate,
              record.recordedTime,
            ),
          },
        )
        .toList();

    return {
      'fastingGlucose': fastingGlucose,
      'randomGlucose': randomGlucose,
      'hba1c': hba1c,
      'analysisRange': {
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
        'days': rangeDays,
      },
      'weeklySummary': {
        'windowDays': rangeDays,
        'avgGlucose': glucoseAverage7d,
        'avgSystolic': systolicAvg7d,
        'avgDiastolic': diastolicAvg7d,
        'medicationAdherenceRate': medicationAdherenceRate7d,
        'dietLoggingRate': dietLoggingRate7d,
        'activityMinutes': activityMinutes7d,
        'symptomCount': symptoms.length,
      },
      'bloodPressure': latestBloodPressure == null
          ? null
          : {
              'systolic': latestBloodPressure.systolic,
              'diastolic': latestBloodPressure.diastolic,
            },
      'foodIntake': latestFood == null
          ? null
          : '${latestFood.foodDescription} (${latestFood.mealType ?? 'meal'})',
      'exercise': latestExercise == null
          ? null
          : '${latestExercise.exerciseType} for ${latestExercise.durationMinutes} minutes',
      'medicationAdherence': _hasRecentMedicationIntake(medicationIntakeWeek),
      'medicationAdherenceRate7d': medicationAdherenceRate7d,
      'dietLoggingRate7d': dietLoggingRate7d,
      'activityMinutes7d': activityMinutes7d,
      'symptoms': latestSymptoms,
      'notes': notes.isEmpty ? null : notes.join('; '),
      'recordedAt': _latestRecordedAt(
        bloodSugar: bloodSugar,
        bloodPressure: latestBloodPressure,
        food: latestFood,
        exercise: latestExercise,
      ),
    };
  }

  List<Map<String, dynamic>> _buildHistory({
    required List<LocalBloodSugar> bloodSugar,
    required List<LocalBloodPressure> bloodPressure,
    required List<LocalBodyMeasurement> bodyMeasurements,
    required List<LocalFoodIntake> foodIntake,
    required List<LocalPhysicalActivity> exercise,
    required List<LocalMedicationIntake> medicationIntake,
    required List<LocalSymptom> symptoms,
  }) {
    final history = <Map<String, dynamic>>[];

    for (final record in bloodSugar.take(25)) {
      history.add({
        'type': 'bloodSugar',
        'value': record.level,
        'measurementType': record.typeMeasurement,
        'context': record.mealRelation,
        'recordedAt': _combineDateTime(record.dateTakenOn, record.timeTakenOn),
        'notes': record.note,
      });
    }

    for (final record in bloodPressure.take(25)) {
      history.add({
        'type': 'bloodPressure',
        'systolic': record.systolic,
        'diastolic': record.diastolic,
        'recordedAt': _combineDateTime(record.dateTakenOn, record.timeTakenOn),
        'notes': record.note,
      });
    }

    for (final record in bodyMeasurements.take(10)) {
      history.add({
        'type': 'bodyMeasurement',
        'bmi': record.bmi,
        'weightKg': record.weightKg,
        'heightCm': record.heightCm,
        'recordedAt': _combineDateTime(
          record.measurementDate,
          record.measurementTime,
        ),
      });
    }

    for (final record in foodIntake.take(15)) {
      history.add({
        'type': 'foodIntake',
        'description': record.foodDescription,
        'mealType': record.mealType,
        'recordedAt': _combineDateTime(record.intakeDate, record.intakeTime),
      });
    }

    for (final record in exercise.take(15)) {
      history.add({
        'type': 'exercise',
        'exerciseType': record.exerciseType,
        'durationMinutes': record.durationMinutes,
        'recordedAt': _combineDateTime(
          record.exerciseDate,
          record.exerciseTime,
        ),
      });
    }

    for (final record in medicationIntake.take(20)) {
      history.add({
        'type': 'medicationIntake',
        'dosageTaken': record.dosageTaken,
        'session': record.session,
        'recordedAt': _combineDateTime(record.intakeDate, record.intakeTime),
      });
    }

    for (final record in symptoms.take(15)) {
      history.add({
        'type': 'symptom',
        'symptom': record.symptomName,
        'severity': record.severity,
        'notes': record.note,
        'recordedAt': _combineDateTime(
          record.recordedDate,
          record.recordedTime,
        ),
      });
    }

    history.sort((a, b) {
      final aDate =
          DateTime.tryParse(a['recordedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate =
          DateTime.tryParse(b['recordedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return history.take(30).toList();
  }

  int? _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return null;
    final birthDate = DateTime.tryParse(dob);
    if (birthDate == null) return null;

    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  double? _latestGlucoseByTypes(
    List<LocalBloodSugar> records,
    List<String> types,
  ) {
    final normalizedTypes = types.map((type) => type.toLowerCase()).toSet();
    for (final record in records) {
      final measurementType = record.typeMeasurement?.toLowerCase();
      if (measurementType != null &&
          normalizedTypes.contains(measurementType)) {
        return record.level;
      }
    }
    return null;
  }

  bool _hasRecentMedicationIntake(List<LocalMedicationIntake> intake) {
    if (intake.isEmpty) return false;

    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return intake.any((record) => record.intakeDate == todayString);
  }

  bool _isWithinLastDays(String? dateString, int days) {
    if (dateString == null || dateString.trim().isEmpty) return false;
    final parsed = DateTime.tryParse(dateString.trim());
    if (parsed == null) return false;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final normalized = DateTime(parsed.year, parsed.month, parsed.day);
    return !normalized.isBefore(start);
  }

  bool _isHbA1cMeasurement(String? type) {
    final lower = (type ?? '').toLowerCase();
    return lower.contains('hba1c') || lower.contains('h1ac') || lower.contains('hba1');
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

  double _adherenceRateByDistinctDays(
    Iterable<String?> dayStrings,
    int rangeDays,
  ) {
    final days = dayStrings
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    final divisor = rangeDays > 0 ? rangeDays : 7;
    return (days.length / divisor).clamp(0.0, 1.0);
  }

  bool _isWithinRange(
    String? dateString,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (dateString == null || dateString.trim().isEmpty) return false;
    final parsed = DateTime.tryParse(dateString.trim());
    if (parsed == null) return false;

    final normalized = DateTime(parsed.year, parsed.month, parsed.day);
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

    return !normalized.isBefore(normalizedStart) &&
        !normalized.isAfter(normalizedEnd);
  }

  String? _combineDateTime(String? date, String? time) {
    if (date == null || date.isEmpty) return null;
    if (time == null || time.isEmpty) return date;
    return '${date}T$time:00';
  }

  String? _latestRecordedAt({
    required List<LocalBloodSugar> bloodSugar,
    required LocalBloodPressure? bloodPressure,
    required LocalFoodIntake? food,
    required LocalPhysicalActivity? exercise,
  }) {
    final timestamps = <DateTime>[];

    if (bloodSugar.isNotEmpty) {
      final latest = bloodSugar.first;
      final parsed = DateTime.tryParse(
        _combineDateTime(latest.dateTakenOn, latest.timeTakenOn) ?? '',
      );
      if (parsed != null) timestamps.add(parsed);
    }

    if (bloodPressure != null) {
      final parsed = DateTime.tryParse(
        _combineDateTime(
              bloodPressure.dateTakenOn,
              bloodPressure.timeTakenOn,
            ) ??
            '',
      );
      if (parsed != null) timestamps.add(parsed);
    }

    if (food != null) {
      final parsed = DateTime.tryParse(
        _combineDateTime(food.intakeDate, food.intakeTime) ?? '',
      );
      if (parsed != null) timestamps.add(parsed);
    }

    if (exercise != null) {
      final parsed = DateTime.tryParse(
        _combineDateTime(exercise.exerciseDate, exercise.exerciseTime) ?? '',
      );
      if (parsed != null) timestamps.add(parsed);
    }

    if (timestamps.isEmpty) return DateTime.now().toIso8601String();
    timestamps.sort((a, b) => b.compareTo(a));
    return timestamps.first.toIso8601String();
  }
}
