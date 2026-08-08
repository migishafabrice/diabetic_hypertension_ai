import 'package:sqflite/sqflite.dart';
import '../models/local_blood_sugar.dart';
import 'localDatabaseService.dart';

class BloodSugarDao {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  Future<int> insertBloodSugar(LocalBloodSugar bs) async {
    final db = await _dbService.database;
    return await db.insert(
      'bloodsugar',
      bs.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalBloodSugar>> getAllBloodSugarForUser(int userid) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bloodsugar',
      where: 'userid = ? AND sync_status != ?',
      whereArgs: [userid, 2],
      orderBy: 'date_taken_on DESC, time_taken_on DESC',
    );
    return List.generate(maps.length, (i) => LocalBloodSugar.fromMap(maps[i]));
  }

  Future<int> updateBloodSugar(LocalBloodSugar bs) async {
    final db = await _dbService.database;
    final updatedBs = bs.copyWith(syncStatus: 0);
    return await db.update(
      'bloodsugar',
      updatedBs.toMap(),
      where: 'id = ?',
      whereArgs: [bs.id],
    );
  }

  Future<int> deleteBloodSugar(int id) async {
    final db = await _dbService.database;
    // Mark as deleted (sync_status = 2) instead of deleting immediately
    return await db.update(
      'bloodsugar',
      {'sync_status': 2},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LocalBloodSugar>> getUnsyncedBloodSugar() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bloodsugar',
      where: 'sync_status IN (?, ?)', // Include unsynced (0) and deleted (2)
      whereArgs: [0, 2],
    );
    return List.generate(maps.length, (i) => LocalBloodSugar.fromMap(maps[i]));
  }
}
