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
  Future<bool> addMedicationEntry(NewMedicationEntry entry) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      await con?.execute(
        Sql.named(
          'INSERT INTO health_db.medication(userid, medication_name,medication_type, dosage, frequency, note, active)'
          ' VALUES (@userId, @medication_name,@medication_type, @dosage, @frequency, @note, @active)',
        ),
        parameters: {
          'userId': entry.userId,
          'medication_name': entry.medicationName,
          'medication_type': entry.medicationType,
          'dosage': entry.dosage,
          'frequency': entry.frequency,
          'note': entry.note,
          'active': entry.active,
        },
      );

      // Refresh the list after adding new entry
      bool medication = await getMedicationEntries(entry.userId);
      if (medication) {
        return true;
      } else {
        return false;
      }
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

  Future<bool> getMedicationEntries(int userId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        List<List<dynamic>> results = await con.execute(
          Sql.named(
            'SELECT id, medication_name,medication_type, dosage, frequency, note, active'
            '  FROM health_db.medication WHERE userid = @userId ORDER BY created_at DESC',
          ),
          parameters: {'userId': userId},
        );

        state = results.map((row) {
          return NewMedicationEntry(
            id: row[0] as int,
            userId: userId,
            medicationName: safeParseString(row[1]),
            medicationType: safeParseString(row[2]),
            dosage: safeParseString(row[3]),
            frequency: safeParseInt(row[4]) ?? 1,
            note: row[5] as String? ?? '',
            active: row[6] as bool,
          );
        }).toList();
        if (state.isNotEmpty) {
          return true;
        } else {
          return false;
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}

class NewMedicationEntry {
  final int id;
  final int userId;
  final String medicationName;
  final String medicationType;
  final String dosage;
  final int frequency;
  final bool active;
  final String note;

  NewMedicationEntry({
    required this.id,
    required this.userId,
    required this.medicationName,
    required this.medicationType,
    required this.dosage,
    required this.frequency,
    required this.active,
    required this.note,
  });
}
