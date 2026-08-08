import 'package:sqflite/sqflite.dart';
import '../models/local_body_measurement.dart';
import 'localDatabaseService.dart';

class BodyMeasurementDao {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  Future<int> insertMeasurement(LocalBodyMeasurement measurement) async {
    final db = await _dbService.database;
    return await db.insert(
      'body_measurements',
      measurement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalBodyMeasurement>> getAllMeasurements() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('body_measurements');
    return List.generate(maps.length, (i) => LocalBodyMeasurement.fromMap(maps[i]));
  }

  Future<List<LocalBodyMeasurement>> getMeasurementsByUserId(int userId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'body_measurements',
      where: 'userid = ? AND sync_status != ?',
      whereArgs: [userId, 2],
      orderBy: 'measurement_date DESC, measurement_time DESC',
    );
    return List.generate(maps.length, (i) => LocalBodyMeasurement.fromMap(maps[i]));
  }

  Future<LocalBodyMeasurement?> getMeasurementById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'body_measurements',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return LocalBodyMeasurement.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMeasurement(LocalBodyMeasurement measurement) async {
    final db = await _dbService.database;
    final updatedMeasurement = measurement.copyWith(syncStatus: 0);
    return await db.update(
      'body_measurements',
      updatedMeasurement.toMap(),
      where: 'id = ?',
      whereArgs: [measurement.id],
    );
  }

  Future<int> deleteMeasurement(int id) async {
    final db = await _dbService.database;
    // Mark as deleted (sync_status = 2) instead of deleting immediately
    return await db.update(
      'body_measurements',
      {'sync_status': 2},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LocalBodyMeasurement>> getUnsyncedMeasurements() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'body_measurements',
      where: 'sync_status IN (?, ?)', // Include unsynced (0) and deleted (2)
      whereArgs: [0, 2],
    );
    return List.generate(maps.length, (i) => LocalBodyMeasurement.fromMap(maps[i]));
  }
}
