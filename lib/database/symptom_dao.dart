
import 'package:sqflite/sqflite.dart';
import '../models/local_symptom.dart';
import 'localDatabaseService.dart';

class SymptomDao {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  Future<int> insertSymptom(LocalSymptom symptom) async {
    final db = await _dbService.database;
    return await db.insert('symptoms', symptom.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LocalSymptom>> getAllSymptomsForUser(int userid) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'symptoms',
      where: 'userid = ? AND sync_status != ?',
      whereArgs: [userid, 2],
      orderBy: 'recorded_date DESC, recorded_time DESC',
    );
    return List.generate(maps.length, (i) => LocalSymptom.fromMap(maps[i]));
  }

  Future<int> updateSymptom(LocalSymptom symptom) async {
    final db = await _dbService.database;
    final updatedSymptom = symptom.copyWith(syncStatus: 0);
    return await db.update(
      'symptoms',
      updatedSymptom.toMap(),
      where: 'id = ?',
      whereArgs: [symptom.id],
    );
  }

  Future<int> deleteSymptom(int id) async {
    final db = await _dbService.database;
    return await db.update(
      'symptoms',
      {'sync_status': 2},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LocalSymptom>> getUnsyncedSymptoms() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'symptoms',
      where: 'sync_status IN (?, ?)',
      whereArgs: [0, 2],
    );
    return List.generate(maps.length, (i) => LocalSymptom.fromMap(maps[i]));
  }
}
