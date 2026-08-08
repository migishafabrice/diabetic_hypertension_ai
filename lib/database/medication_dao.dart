import 'package:sqflite/sqflite.dart';
import '../models/local_medication.dart';
import 'localDatabaseService.dart';

class MedicationDao {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  Future<int> insertMedication(LocalMedication med) async {
    final db = await _dbService.database;
    return await db.insert(
      'medication_prescriptions',
      med.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalMedication>> getAllMedicationsForUser(int userid) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medication_prescriptions',
      where: 'userid = ? AND sync_status != ?',
      whereArgs: [userid, 2],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => LocalMedication.fromMap(maps[i]));
  }

  Future<int> updateMedication(LocalMedication med) async {
    final db = await _dbService.database;
    final updatedMed = med.copyWith(syncStatus: 0);
    return await db.update(
      'medication_prescriptions',
      updatedMed.toMap(),
      where: 'id = ?',
      whereArgs: [med.id],
    );
  }

  Future<int> deleteMedication(int id) async {
    final db = await _dbService.database;
    // Mark as deleted (sync_status = 2) instead of deleting immediately
    return await db.update(
      'medication_prescriptions',
      {'sync_status': 2},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LocalMedication>> getUnsyncedMedications() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medication_prescriptions',
      where: 'sync_status IN (?, ?)', // Include unsynced (0) and deleted (2)
      whereArgs: [0, 2],
    );
    return List.generate(maps.length, (i) => LocalMedication.fromMap(maps[i]));
  }
}
