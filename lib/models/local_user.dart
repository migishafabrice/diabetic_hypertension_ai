class LocalUser {
  final int? id;
  final int? cloudId;
  final String username;
  final String? nickname;
  final String password;
  final String? function;
  final String? address;
  final String? dob;
  final String? sex;
  final String? firstDiagnosisDate;
  final String? smokingStatus;
  final String? alcoholConsumption;
  final String? createdAt;
  final int isSynced;

  LocalUser({
    this.id,
    this.cloudId,
    required this.username,
    this.nickname,
    required this.password,
    this.function,
    this.address,
    this.dob,
    this.sex,
    this.firstDiagnosisDate,
    this.smokingStatus,
    this.alcoholConsumption,
    this.createdAt,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cloud_id': cloudId,
      'username': username,
      'nickname': nickname,
      'password': password,
      'function': function,
      'address': address,
      'dob': dob,
      'sex': sex,
      'first_diagnosis_date': firstDiagnosisDate,
      'smoking_status': smokingStatus,
      'alcohol_consumption': alcoholConsumption,
      'created_at': createdAt,
      'sync_status': isSynced,
    };
  }

  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      username: map['username'] as String,
      nickname: map['nickname'] as String?,
      password: map['password'] as String,
      function: map['function'] as String?,
      address: map['address'] as String?,
      dob: map['dob'] as String?,
      sex: map['sex'] as String?,
      firstDiagnosisDate: map['first_diagnosis_date'] as String?,
      smokingStatus: map['smoking_status'] as String?,
      alcoholConsumption: map['alcohol_consumption'] as String?,
      createdAt: map['created_at'] as String?,
      isSynced: map['sync_status'] as int? ?? map['is_synced'] as int? ?? 0,
    );
  }

  LocalUser copyWith({
    int? id,
    int? cloudId,
    String? username,
    String? nickname,
    String? password,
    String? function,
    String? address,
    String? dob,
    String? sex,
    String? firstDiagnosisDate,
    String? smokingStatus,
    String? alcoholConsumption,
    String? createdAt,
    int? isSynced,
  }) {
    return LocalUser(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      password: password ?? this.password,
      function: function ?? this.function,
      address: address ?? this.address,
      dob: dob ?? this.dob,
      sex: sex ?? this.sex,
      firstDiagnosisDate: firstDiagnosisDate ?? this.firstDiagnosisDate,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      alcoholConsumption: alcoholConsumption ?? this.alcoholConsumption,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
