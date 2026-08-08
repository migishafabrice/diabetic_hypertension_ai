class LocalMedication {
  final int? id;
  final int? cloudId;
  final int userid;
  final String medicationName;
  final String medicationType;
  final String dosage;
  final int frequency;
  final String? note;
  final bool active;
  final int syncStatus; //0=unsynced,1=synced,2=deleted

  LocalMedication({
    this.id,
    this.cloudId,
    required this.userid,
    required this.medicationName,
    required this.medicationType,
    required this.dosage,
    required this.frequency,
    this.note,
    this.active = true,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cloud_id': cloudId,
      'userid': userid,
      'medication_name': medicationName,
      'medication_type': medicationType,
      'dosage': dosage,
      'frequency': frequency,
      'note': note,
      'active': active ? 1 : 0,
      'sync_status': syncStatus,
    };
  }

  factory LocalMedication.fromMap(Map<String, dynamic> map) {
    return LocalMedication(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      userid: map['userid'] as int,
      medicationName: map['medication_name'] as String,
      medicationType: map['medication_type'] as String,
      dosage: map['dosage'] as String,
      frequency: map['frequency'] as int,
      note: map['note'] as String?,
      active: (map['active'] as int?) == 1,
      syncStatus: map['sync_status'] as int? ?? 0,
    );
  }

  LocalMedication copyWith({
    int? id,
    int? cloudId,
    int? userid,
    String? medicationName,
    String? medicationType,
    String? dosage,
    int? frequency,
    String? note,
    bool? active,
    int? syncStatus,
  }) {
    return LocalMedication(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      userid: userid ?? this.userid,
      medicationName: medicationName ?? this.medicationName,
      medicationType: medicationType ?? this.medicationType,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      note: note ?? this.note,
      active: active ?? this.active,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
