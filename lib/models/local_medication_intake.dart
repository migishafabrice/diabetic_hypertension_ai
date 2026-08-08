class LocalMedicationIntake {
  final int? id;
  final int? cloudId;
  final int userid;
  final int medicationId;
  final String dosageTaken;
  final String session;
  final String? note;
  final String intakeDate;
  final String intakeTime;
  final int syncStatus; //0=unsynced,1=synced,2=deleted

  LocalMedicationIntake({
    this.id,
    this.cloudId,
    required this.userid,
    required this.medicationId,
    required this.dosageTaken,
    required this.session,
    this.note,
    required this.intakeDate,
    required this.intakeTime,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cloud_id': cloudId,
      'userid': userid,
      'medication_id': medicationId,
      'dosage_taken': dosageTaken,
      'session': session,
      'note': note,
      'intake_date': intakeDate,
      'intake_time': intakeTime,
      'sync_status': syncStatus,
    };
  }

  factory LocalMedicationIntake.fromMap(Map<String, dynamic> map) {
    return LocalMedicationIntake(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      userid: map['userid'] as int,
      medicationId: map['medication_id'] as int,
      dosageTaken: map['dosage_taken'] as String,
      session: map['session'] as String,
      note: map['note'] as String?,
      intakeDate: map['intake_date'] as String,
      intakeTime: map['intake_time'] as String,
      syncStatus: map['sync_status'] as int? ?? 0,
    );
  }

  LocalMedicationIntake copyWith({
    int? id,
    int? cloudId,
    int? userid,
    int? medicationId,
    String? dosageTaken,
    String? session,
    String? note,
    String? intakeDate,
    String? intakeTime,
    int? syncStatus,
  }) {
    return LocalMedicationIntake(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      userid: userid ?? this.userid,
      medicationId: medicationId ?? this.medicationId,
      dosageTaken: dosageTaken ?? this.dosageTaken,
      session: session ?? this.session,
      note: note ?? this.note,
      intakeDate: intakeDate ?? this.intakeDate,
      intakeTime: intakeTime ?? this.intakeTime,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
