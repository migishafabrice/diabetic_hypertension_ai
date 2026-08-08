class LocalBodyMeasurement {
  final int? id;
  final int? cloudId;
  final int userid;
  final double heightCm;
  final double weightKg;
  final double bmi;
  final String measurementDate;
  final String measurementTime;
  final String? note;
  final int syncStatus; // 0=unsynced, 1=synced, 2=deleted

  LocalBodyMeasurement({
    this.id,
    this.cloudId,
    required this.userid,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    required this.measurementDate,
    required this.measurementTime,
    this.note,
    this.syncStatus = 0,
  });

  // Calculate BMI from height and weight
  static double calculateBMI(double heightCm, double weightKg) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cloud_id': cloudId,
      'userid': userid,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bmi': bmi,
      'measurement_date': measurementDate,
      'measurement_time': measurementTime,
      'note': note,
      'sync_status': syncStatus,
    };
  }

  factory LocalBodyMeasurement.fromMap(Map<String, dynamic> map) {
    return LocalBodyMeasurement(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      userid: map['userid'] as int,
      heightCm: map['height_cm'] as double,
      weightKg: map['weight_kg'] as double,
      bmi: map['bmi'] as double,
      measurementDate: map['measurement_date'] as String,
      measurementTime: map['measurement_time'] as String,
      note: map['note'] as String?,
      syncStatus: map['sync_status'] as int? ?? 0,
    );
  }

  LocalBodyMeasurement copyWith({
    int? id,
    int? cloudId,
    int? userid,
    double? heightCm,
    double? weightKg,
    double? bmi,
    String? measurementDate,
    String? measurementTime,
    String? note,
    int? syncStatus,
  }) {
    return LocalBodyMeasurement(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      userid: userid ?? this.userid,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bmi: bmi ?? this.bmi,
      measurementDate: measurementDate ?? this.measurementDate,
      measurementTime: measurementTime ?? this.measurementTime,
      note: note ?? this.note,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
