import 'package:sqflite/sqflite.dart';
import '../models/local_blood_pressure.dart';
import 'localDatabaseService.dart';

class BloodPressureDao {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  Future<int> insertBloodPressure(LocalBloodPressure bp) async {
    final db = await _dbService.database;
    return await db.insert('bloodpressure', bp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LocalBloodPressure>> getAllBloodPressureForUser(int userid) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bloodpressure',
      where: 'userid = ? AND sync_status != ?',
      whereArgs: [userid, 2],
      orderBy: 'date_taken_on DESC, time_taken_on DESC',
    );
    return List.generate(maps.length, (i) => LocalBloodPressure.fromMap(maps[i]));
  }

  Future<int> updateBloodPressure(LocalBloodPressure bp) async {
    final db = await _dbService.database;
    final updatedBp = bp.copyWith(syncStatus: 0);
    return await db.update(
      'bloodpressure',
      updatedBp.toMap(),
      where: 'id = ?',
      whereArgs: [bp.id],
    );
  }

  Future<int> deleteBloodPressure(int id) async {
    final db = await _dbService.database;
    // Mark as deleted (sync_status = 2) instead of deleting immediately
    return await db.update(
      'bloodpressure',
      {'sync_status': 2},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LocalBloodPressure>> getUnsyncedBloodPressure() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bloodpressure',
      where: 'sync_status IN (?, ?)', // Include unsynced (0) and deleted (2)
      whereArgs: [0, 2],
    );
    return List.generate(maps.length, (i) => LocalBloodPressure.fromMap(maps[i]));
  }
}
