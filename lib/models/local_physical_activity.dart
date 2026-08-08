class LocalPhysicalActivity {
  final int? id;
  final int? cloudId;
  final int userid;
  final String exerciseType;
  final int durationMinutes; // in minutes
  final String? intensity;
  final int? caloriesBurned;
  final String exerciseDate;
  final String exerciseTime;
  final String? note;
  final int syncStatus; //0=unsynced,1=synced,2=deleted

  LocalPhysicalActivity({
    this.id,
    this.cloudId,
    required this.userid,
    required this.exerciseType,
    required this.durationMinutes,
    this.intensity,
    this.caloriesBurned,
    required this.exerciseDate,
    required this.exerciseTime,
    this.note,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cloud_id': cloudId,
      'userid': userid,
      'exercise_type': exerciseType,
      'intensity_level': intensity,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'exercise_date': exerciseDate,
      'exercise_time': exerciseTime,
      'note': note,
      'sync_status': syncStatus,
    };
  }

  factory LocalPhysicalActivity.fromMap(Map<String, dynamic> map) {
    return LocalPhysicalActivity(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      userid: map['userid'] as int,
      exerciseType: map['exercise_type'] as String,
      durationMinutes: map['duration_minutes'] as int,
      intensity: map['intensity_level'] as String?,
      caloriesBurned: map['calories_burned'] as int?,
      exerciseDate: map['exercise_date'] as String,
      exerciseTime: map['exercise_time'] as String,
      note: map['note'] as String?,
      syncStatus: map['sync_status'] as int? ?? 0,
    );
  }

  LocalPhysicalActivity copyWith({
    int? id,
    int? cloudId,
    int? userid,
    String? exerciseType,
    int? durationMinutes,
    String? intensity,
    int? caloriesBurned,
    String? exerciseDate,
    String? exerciseTime,
    String? note,
    int? syncStatus,
  }) {
    return LocalPhysicalActivity(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      userid: userid ?? this.userid,
      exerciseType: exerciseType ?? this.exerciseType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      exerciseDate: exerciseDate ?? this.exerciseDate,
      exerciseTime: exerciseTime ?? this.exerciseTime,
      note: note ?? this.note,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
