import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthapp/database/databaseService.dart';
import 'package:postgres/postgres.dart';

final bloodPressureProvider =
    StateNotifierProvider<BloodPressureNotifier, List<NewBloodPressureEntry>>((
      ref,
    ) {
      return BloodPressureNotifier();
    });

class BloodPressureNotifier extends StateNotifier<List<NewBloodPressureEntry>> {
  BloodPressureNotifier() : super([]);

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

  Future<void> addBloodPressureEntry(NewBloodPressureEntry entry) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        await con.execute(
          Sql.named(
            'INSERT INTO health_db.bloodpressure(userid, systolic, diastolic, pulse, note, date_taken_on, time_taken_on) VALUES (@userId, @systolic, @diastolic, @pulse, @note, @date_taken_on, @time_taken_on)',
          ),
          parameters: {
            'userId': entry.userId,
            'systolic': entry.systolic,
            'diastolic': entry.diastolic,
            'pulse': entry.pulse,
            'note': entry.note,
            'date_taken_on': entry.entryDate,
            'time_taken_on': timeOfDayToPostgresString(entry.entryTime),
          },
        );

        // Refresh the list after adding new entry
        await getBloodPressureEntries(entry.userId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getBloodPressureEntries(int userId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        final result = await con.execute(
          Sql.named(
            'SELECT * FROM health_db.bloodpressure WHERE userid = @userId ORDER BY date_taken_on DESC, time_taken_on DESC',
          ),
          parameters: {'userId': userId},
        );

        final entries = result.map((row) {
          return NewBloodPressureEntry(
            id: _safeParseInt(row[0]),
            userId: _safeParseInt(row[7]) ?? 0, // Provide default if null
            systolic: _safeParseInt(row[1]) ?? 0,
            diastolic: _safeParseInt(row[2]) ?? 0,
            pulse: _safeParseInt(row[3]) ?? 0,
            note: _safeParseString(row[4]),
            entryDate: _safeParseDateTime(row[5]),
            entryTime: postgresStringToTimeOfDay(_safeParseString(row[6])),
          );
        }).toList();

        state = entries;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Safe type conversion helpers
  int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    if (value is bool) return value ? 1 : 0;
    return null;
  }

  String _safeParseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  DateTime _safeParseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // Clear all entries
  void clearEntries() {
    state = [];
  }

  Future<void> deleteBloodPressureEntry(int entryId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        await con.execute(
          Sql.named('DELETE FROM health_db.bloodpressure WHERE id = @entryId'),
          parameters: {'entryId': entryId},
        );

        // Refresh the list after deleting
        await getBloodPressureEntries(state[0].userId);
      }
    } catch (e) {
      rethrow;
    }
  }
}

class NewBloodPressureEntry {
  final int? id;
  final int userId;
  final int systolic;
  final int diastolic;
  final int pulse;
  final String note;
  final DateTime entryDate;
  final TimeOfDay entryTime;

  NewBloodPressureEntry({
    this.id,
    required this.userId,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.note,
    required this.entryDate,
    required this.entryTime,
  });

  @override
  String toString() {
    return 'BloodPressureEntry(id: $id, systolic: $systolic, diastolic: $diastolic, pulse: $pulse)';
  }
}
