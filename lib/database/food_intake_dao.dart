import 'package:sqflite/sqflite.dart';
import '../models/local_food_intake.dart';
import 'localDatabaseService.dart';

class FoodIntakeDao {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  Future<int> insertFoodIntake(LocalFoodIntake food) async {
    final db = await _dbService.database;
    return await db.insert(
      'food_intake',
      food.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalFoodIntake>> getAllFoodForUser(int userId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_intake',
      where: 'userid = ? AND sync_status != ?',
      whereArgs: [userId, 2],
      orderBy: 'intake_date DESC',
    );
    return List.generate(maps.length, (i) => LocalFoodIntake.fromMap(maps[i]));
  }

  Future<int> updateFoodIntake(LocalFoodIntake food) async {
    final db = await _dbService.database;
    final updatedFood = food.copyWith(syncStatus: 0);
    return await db.update(
      'food_intake',
      updatedFood.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<int> deleteFoodIntake(int id) async {
    final db = await _dbService.database;
    // Mark as deleted (sync_status = 2) instead of deleting immediately
    return await db.update(
      'food_intake',
      {'sync_status': 2},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LocalFoodIntake>> getUnsyncedFoodIntake() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_intake',
      where: 'sync_status IN (?, ?)', // Include unsynced (0) and deleted (2)
      whereArgs: [0, 2],
    );
    return List.generate(maps.length, (i) => LocalFoodIntake.fromMap(maps[i]));
  }
}
