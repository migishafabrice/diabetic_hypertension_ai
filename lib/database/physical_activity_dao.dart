import 'package:sqflite/sqflite.dart';
import '../models/local_physical_activity.dart';
import 'localDatabaseService.dart';

class PhysicalActivityDao {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  Future<int> insertPhysicalActivity(LocalPhysicalActivity activity) async {
    final db = await _dbService.database;
    return await db.insert(
      'physical_activity',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalPhysicalActivity>> getAllActivityForUser(int userid) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'physical_activity',
      where: 'userid = ? AND sync_status != ?',
      whereArgs: [userid, 2],
      orderBy: 'exercise_date DESC, exercise_time DESC',
    );
    return List.generate(
      maps.length,
      (i) => LocalPhysicalActivity.fromMap(maps[i]),
    );
  }

  Future<int> updatePhysicalActivity(LocalPhysicalActivity activity) async {
    final db = await _dbService.database;
    final updatedActivity = activity.copyWith(syncStatus: 0);
    return await db.update(
      'physical_activity',
      updatedActivity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deletePhysicalActivity(int id) async {
    final db = await _dbService.database;
    // Mark as deleted (sync_status = 2) instead of deleting immediately
    return await db.update(
      'physical_activity',
      {'sync_status': 2},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LocalPhysicalActivity>> getUnsyncedActivity() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'physical_activity',
      where: 'sync_status IN (?, ?)', // Include unsynced (0) and deleted (2)
      whereArgs: [0, 2],
    );
    return List.generate(
      maps.length,
      (i) => LocalPhysicalActivity.fromMap(maps[i]),
    );
  }
}
