class LocalFoodIntake {
  final int? id;
  final int? cloudId;
  final int userid;
  final String foodDescription;
  final int? quantity;
  final int? calories;
  final String? mealType;
  final String intakeDate;
  final String? intakeTime;
  final String? note;
  final int syncStatus; // 0=unsynced, 1=synced, 2=deleted

  LocalFoodIntake({
    this.id,
    this.cloudId,
    required this.userid,
    required this.foodDescription,
    this.quantity,
    this.calories,
    this.mealType,
    required this.intakeDate,
    this.intakeTime,
    this.note,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cloud_id': cloudId,
      'userid': userid,
      'food_description': foodDescription,
      'quantity': quantity,
      'calories': calories,
      'meal_type': mealType,
      'intake_date': intakeDate,
      'intake_time': intakeTime,
      'note': note,
      'sync_status': syncStatus,
    };
  }

  factory LocalFoodIntake.fromMap(Map<String, dynamic> map) {
    return LocalFoodIntake(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      userid: map['userid'] as int,
      foodDescription: map['food_description'] as String,
      quantity: map['quantity'] as int?,
      calories: map['calories'] as int?,
      mealType: map['meal_type'] as String?,
      intakeDate: map['intake_date'] as String,
      intakeTime: map['intake_time'] as String?,
      note: map['note'] as String?,
      syncStatus: map['sync_status'] as int? ?? 0,
    );
  }

  LocalFoodIntake copyWith({
    int? id,
    int? cloudId,
    int? userid,
    String? foodDescription,
    int? quantity,
    int? calories,
    String? mealType,
    String? intakeDate,
    String? intakeTime,
    String? note,
    int? syncStatus,
  }) {
    return LocalFoodIntake(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      userid: userid ?? this.userid,
      foodDescription: foodDescription ?? this.foodDescription,
      quantity: quantity ?? this.quantity,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      intakeDate: intakeDate ?? this.intakeDate,
      intakeTime: intakeTime ?? this.intakeTime,
      note: note ?? this.note,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
