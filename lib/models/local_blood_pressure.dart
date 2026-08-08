class LocalBloodPressure {
  final int? id;
  final int? cloudId;
  final int userid;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? note;
  final String? dateTakenOn;
  final String? timeTakenOn;
  final int syncStatus; //0=unsynced,1=synced,2=deleted

  LocalBloodPressure({
    this.id,
    this.cloudId,
    required this.userid,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.note,
    this.dateTakenOn,
    this.timeTakenOn,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cloud_id': cloudId,
      'userid': userid,
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'note': note,
      'date_taken_on': dateTakenOn,
      'time_taken_on': timeTakenOn,
      'sync_status': syncStatus,
    };
  }

  factory LocalBloodPressure.fromMap(Map<String, dynamic> map) {
    return LocalBloodPressure(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      userid: map['userid'] as int,
      systolic: map['systolic'] as int,
      diastolic: map['diastolic'] as int,
      pulse: map['pulse'] as int?,
      note: map['note'] as String?,
      dateTakenOn: map['date_taken_on'] as String?,
      timeTakenOn: map['time_taken_on'] as String?,
      syncStatus: map['sync_status'] as int? ?? 0,
    );
  }

  LocalBloodPressure copyWith({
    int? id,
    int? cloudId,
    int? userid,
    int? systolic,
    int? diastolic,
    int? pulse,
    String? note,
    String? dateTakenOn,
    String? timeTakenOn,
    int? syncStatus,
  }) {
    return LocalBloodPressure(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      userid: userid ?? this.userid,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      note: note ?? this.note,
      dateTakenOn: dateTakenOn ?? this.dateTakenOn,
      timeTakenOn: timeTakenOn ?? this.timeTakenOn,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
