
class LocalSymptom {
  final int? id;
  final int? cloudId;
  final int userid;
  final String symptomName;
  final int? severity; // 1-5
  final String? note;
  final String? recordedDate;
  final String? recordedTime;
  final int syncStatus; // 0=unsynced, 1=synced, 2=deleted

  LocalSymptom({
    this.id,
    this.cloudId,
    required this.userid,
    required this.symptomName,
    this.severity,
    this.note,
    this.recordedDate,
    this.recordedTime,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cloud_id': cloudId,
      'userid': userid,
      'symptom_name': symptomName,
      'severity': severity,
      'note': note,
      'recorded_date': recordedDate,
      'recorded_time': recordedTime,
      'sync_status': syncStatus,
    };
  }

  factory LocalSymptom.fromMap(Map<String, dynamic> map) {
    return LocalSymptom(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      userid: map['userid'] as int,
      symptomName: map['symptom_name'] as String,
      severity: map['severity'] as int?,
      note: map['note'] as String?,
      recordedDate: map['recorded_date'] as String?,
      recordedTime: map['recorded_time'] as String?,
      syncStatus: map['sync_status'] as int? ?? 0,
    );
  }

  LocalSymptom copyWith({
    int? id,
    int? cloudId,
    int? userid,
    String? symptomName,
    int? severity,
    String? note,
    String? recordedDate,
    String? recordedTime,
    int? syncStatus,
  }) {
    return LocalSymptom(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      userid: userid ?? this.userid,
      symptomName: symptomName ?? this.symptomName,
      severity: severity ?? this.severity,
      note: note ?? this.note,
      recordedDate: recordedDate ?? this.recordedDate,
      recordedTime: recordedTime ?? this.recordedTime,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
