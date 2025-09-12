import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthapp/database/databaseService.dart';
import 'package:healthapp/widgets/components.dart';
import 'package:postgres/postgres.dart';

final medicationIntakeProvider =
    StateNotifierProvider<
      MedicationIntakeProvider,
      List<NewMedicationIntakeEntry>
    >((ref) {
      return MedicationIntakeProvider();
    });

class MedicationIntakeProvider
    extends StateNotifier<List<NewMedicationIntakeEntry>> {
  MedicationIntakeProvider() : super([]);
  Future<bool> addNewMedicationIntakeEntry(
    NewMedicationIntakeEntry entry,
  ) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        await con.execute(
          Sql.named(
            "insert into health_db.medication_intake(userid,medication_id,note,date_taken_on,time_taken_on,session) "
            "values(@userId,@medication_id,@note,@entryDate,@entryTime,@session)",
          ),
          parameters: {
            "userId": entry.userId,
            "medication_id": entry.medicationId,
            "note": entry.note,
            "entryDate": entry.entryDate,
            "entryTime": timeOfDayToPostgresString(entry.entryTime),
            "session": entry.session,
          },
        );
        bool intake = await getMedicationIntakeEntries(entry.userId);
        intake ? true : false;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getMedicationIntakeEntries(int userId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        // Join medication_intake and medication tables
        List<List<dynamic>> results = await con.execute(
          Sql.named('''
          SELECT mi.id, mi.userid , mi.medication_name, m.medication_type, m.dosage,
           m.frequency, mi.note, mi.date_taken_on, mi.time_taken, mi.session, mi.active
          FROM health_db.medication_intake mi
          JOIN health_db.medication m ON mi.medication_id = m.id
          WHERE mi.user_id = @userId
          ORDER BY mi.date_taken_on DESC, mi.time_taken_on DESC
          '''),
          parameters: {'userId': userId},
        );

        state = NewMedicationIntakeEntry.listFromDB(results);
        return state.isNotEmpty;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}

class NewMedicationIntakeEntry {
  final int id;
  final int userId;
  final int medicationId;
  final String dosageTaken;
  final String note;
  final DateTime entryDate;
  final TimeOfDay entryTime;
  final String session;

  NewMedicationIntakeEntry({
    required this.id,
    required this.userId,
    required this.medicationId,
    required this.dosageTaken,
    required this.note,
    required this.entryDate,
    required this.entryTime,
    required this.session,
  });
  static List<NewMedicationIntakeEntry> listFromDB(
    List<List<dynamic>> results,
  ) {
    return results.map((row) {
      return NewMedicationIntakeEntry(
        id: safeParseInt(row[0])!,
        userId: safeParseInt(row[1])!,
        medicationId: safeParseInt(row[2])!,
        dosageTaken: row[4]?.toString() ?? '',
        note: row[6]?.toString() ?? '',
        entryDate: row[7] as DateTime,
        entryTime: row[8] != null
            ? postgresStringToTimeOfDay(row[8].toString())
            : const TimeOfDay(hour: 0, minute: 0),
        session: row[9]?.toString() ?? '',
      );
    }).toList();
  }
}
