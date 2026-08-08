class LocalBloodSugar {
  final int? id;
  final int? cloudId;
  final int userid;
  final String? typeMeasurement;
  final String? mealRelation;
  final double level;
  final String? dateTakenOn;
  final String? timeTakenOn;
  final String? note;
  final String? unit;
  final int syncStatus; // 0=unsynced,1=synced,2=deleted

  LocalBloodSugar({
    this.id,
    this.cloudId,
    required this.userid,
    this.typeMeasurement,
    this.mealRelation,
    required this.level,
    this.dateTakenOn,
    this.timeTakenOn,
    this.note,
    this.unit,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cloud_id': cloudId,
      'userid': userid,
      'type_measurement': typeMeasurement,
      'meal_relation': mealRelation,
      'level': level,
      'date_taken_on': dateTakenOn,
      'time_taken_on': timeTakenOn,
      'note': note,
      'unit': unit,
      'sync_status': syncStatus,
    };
  }

  factory LocalBloodSugar.fromMap(Map<String, dynamic> map) {
    return LocalBloodSugar(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      userid: map['userid'] as int,
      typeMeasurement: map['type_measurement'] as String?,
      mealRelation: map['meal_relation'] as String?,
      level: map['level'] as double,
      dateTakenOn: map['date_taken_on'] as String?,
      timeTakenOn: map['time_taken_on'] as String?,
      note: map['note'] as String?,
      unit: map['unit'] as String?,
      syncStatus: map['sync_status'] as int? ?? 0,
    );
  }

  LocalBloodSugar copyWith({
    int? id,
    int? cloudId,
    int? userid,
    String? typeMeasurement,
    String? mealRelation,
    double? level,
    String? dateTakenOn,
    String? timeTakenOn,
    String? note,
    String? unit,
    int? syncStatus,
  }) {
    return LocalBloodSugar(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      userid: userid ?? this.userid,
      typeMeasurement: typeMeasurement ?? this.typeMeasurement,
      mealRelation: mealRelation ?? this.mealRelation,
      level: level ?? this.level,
      dateTakenOn: dateTakenOn ?? this.dateTakenOn,
      timeTakenOn: timeTakenOn ?? this.timeTakenOn,
      note: note ?? this.note,
      unit: unit ?? this.unit,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
