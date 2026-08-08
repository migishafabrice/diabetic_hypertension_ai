import 'package:sqflite/sqflite.dart';
import '../models/local_medication_intake.dart';
import 'localDatabaseService.dart';

class MedicationIntakeDao {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  Future<int> insertMedicationIntake(LocalMedicationIntake intake) async {
    final db = await _dbService.database;
    return await db.insert(
      'medication_intake',
      intake.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalMedicationIntake>> getAllIntakeForUser(int userid) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medication_intake',
      where: 'userid = ? AND sync_status != ?',
      whereArgs: [userid, 2],
      orderBy: 'intake_date DESC',
    );
    return List.generate(
      maps.length,
      (i) => LocalMedicationIntake.fromMap(maps[i]),
    );
  }

  Future<List<LocalMedicationIntake>> getIntakeForMedication(int medId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medication_intake',
      where: 'medication_id = ? AND sync_status != ?',
      whereArgs: [medId, 2],
      orderBy: 'intake_date DESC',
    );
    return List.generate(
      maps.length,
      (i) => LocalMedicationIntake.fromMap(maps[i]),
    );
  }

  Future<int> updateMedicationIntake(LocalMedicationIntake intake) async {
    final db = await _dbService.database;
    final updatedIntake = intake.copyWith(syncStatus: 0);
    return await db.update(
      'medication_intake',
      updatedIntake.toMap(),
      where: 'id = ?',
      whereArgs: [intake.id],
    );
  }

  Future<int> deleteMedicationIntake(int id) async {
    final db = await _dbService.database;
    // Mark as deleted (sync_status = 2) instead of deleting immediately
    return await db.update(
      'medication_intake',
      {'sync_status': 2},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LocalMedicationIntake>> getUnsyncedIntake() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medication_intake',
      where: 'sync_status IN (?, ?)', // Include unsynced (0) and deleted (2)
      whereArgs: [0, 2],
    );
    return List.generate(
      maps.length,
      (i) => LocalMedicationIntake.fromMap(maps[i]),
    );
  }
}
