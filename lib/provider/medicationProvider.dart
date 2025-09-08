import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthapp/database/databaseService.dart';
import 'package:healthapp/widgets/components.dart';
import 'package:postgres/postgres.dart';

final medicationProvider =
    StateNotifierProvider<MedicationProvider, List<NewMedicationEntry>>((ref) {
      return MedicationProvider();
    });

class MedicationProvider extends StateNotifier<List<NewMedicationEntry>> {
  MedicationProvider() : super([]);
  Future<void> addMedicationEntry(NewMedicationEntry entry) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      await con?.execute(
        Sql.named(
          'INSERT INTO health_db.medication(userid, medication_name, dosage, frequency, note, date_taken_on, time_taken_on) VALUES (@userId, @medication_name, @dosage, @frequency, @note, @date_taken_on, @time_taken_on)',
        ),
        parameters: {
          'userId': entry.userId,
          'medication_name': entry.medicationName,
          'dosage': entry.dosage,
          'frequency': entry.frequency,
          'note': entry.note,
          'date_taken_on': entry.entryDate,
          'time_taken_on': entry.entryTime.toString(),
        },
      );

      // Refresh the list after adding new entry
      await getMedicationEntries(entry.userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMedicationEntry(int entryId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        await con.execute(
          Sql.named('DELETE FROM health_db.medication WHERE id = @entryId'),
          parameters: {'entryId': entryId},
        );

        // Refresh the list after deleting entry
        await getMedicationEntries(state.first.userId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getMedicationEntries(int userId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        List<List<dynamic>> results = await con.execute(
          'SELECT id, medication_name, dosage, frequency, note, date_taken_on, time_taken_on FROM health_db.medication WHERE userid = @userId ORDER BY date_taken_on DESC, time_taken_on DESC',
          parameters: {'userId': userId},
        );

        state = results.map((row) {
          return NewMedicationEntry(
            id: row[0] as int,
            userId: userId,
            medicationName: row[1] as String,
            dosage: row[2] as String,
            frequency: row[3] as String,
            note: row[4] as String? ?? '',
            entryDate: row[5] as DateTime,
            entryTime: postgresStringToTimeOfDay(row[6] as String),
          );
        }).toList();
      }
    } catch (e) {
      rethrow;
    }
  }
}

class NewMedicationEntry {
  final int id;
  final int userId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String note;
  final DateTime entryDate;
  final TimeOfDay entryTime;

  NewMedicationEntry({
    required this.id,
    required this.userId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.note,
    required this.entryDate,
    required this.entryTime,
  });
}
