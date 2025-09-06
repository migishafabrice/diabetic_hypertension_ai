import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthapp/database/databaseService.dart';
import 'package:postgres/postgres.dart';

final bloodSugarProvider =
    StateNotifierProvider<BloodSugarProvider, List<newBloodSugarEntry>>((ref) {
      return BloodSugarProvider();
    });

class BloodSugarProvider extends StateNotifier<List<newBloodSugarEntry>> {
  BloodSugarProvider() : super([]);

  // Helper method to convert TimeOfDay to PostgreSQL time string
  String timeOfDayToPostgresString(TimeOfDay timeOfDay) {
    return "${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}";
  }

  // Helper method to convert PostgreSQL time string to TimeOfDay
  TimeOfDay postgresStringToTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
      return TimeOfDay.now();
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  Future<bool> addBloodSugarEntry(newBloodSugarEntry entry) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        await con.execute(
          Sql.named(
            'INSERT INTO health_db.bloodsugar(userid,type_measurement,meal_realation, level, note, date_taken_on, time_taken_on, unit)'
            'VALUES (@userId,@type_measurement,@meal_relation, @level, @note, @date_taken_on, @time_taken_on, @unit)',
          ),
          parameters: {
            'userId': entry.userId,
            'type_measurement': entry.type,
            'meal_relation': entry.mealRelation,
            'level': entry.sugarLevel,
            'note': entry.note,
            'date_taken_on': entry.entryDate,
            'time_taken_on': timeOfDayToPostgresString(entry.entryTime),
            'unit': entry.unit,
          },
        );

        // Refresh the list after adding new entry
        return await getBloodSugarEntries(entry.userId);
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getBloodSugarEntries(int userId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        List<List<dynamic>> results = await con.execute(
          Sql.named(
            'SELECT id, userid,type_measurement, meal_realation, level, date_taken_on, time_taken_on,note, unit'
            ' FROM health_db.bloodsugar WHERE userid = @userId date_taken_on DESC, time_taken_on DESC',
          ),

          parameters: {'userId': userId},
        );

        state = results.map((row) {
          return newBloodSugarEntry(
            id: row[0] as int,
            userId: row[1] as int,
            type: row[2] as String,
            mealRelation: row[3] as String,
            sugarLevel: row[4] as double,
            note: row[7] as String?,
            entryDate: row[5] as DateTime,
            entryTime: postgresStringToTimeOfDay(row[6] as String),
            unit: row[9] as String,
          );
        }).toList();
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteBloodSugarEntry(int entryId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        await con.execute(
          Sql.named('DELETE FROM health_db.bloodsugar WHERE id = @entryId'),
          parameters: {'entryId': entryId},
        );
        return true;
        // Optionally, refresh the list after deletion
        // await getBloodSugarEntries(userId); // You might need to pass userId here
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}

class newBloodSugarEntry {
  final int? id;
  final int userId;
  final String type;
  final String mealRelation;
  final double sugarLevel;
  final String? note;
  final DateTime entryDate;
  final TimeOfDay entryTime;
  final String unit;

  newBloodSugarEntry({
    this.id,
    required this.userId,
    required this.type,
    required this.mealRelation,
    required this.sugarLevel,
    this.note,
    required this.entryDate,
    required this.entryTime,
    required this.unit,
  });
}
