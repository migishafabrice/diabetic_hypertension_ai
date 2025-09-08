import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthapp/database/databaseService.dart';
import 'package:healthapp/widgets/components.dart';
import 'package:postgres/postgres.dart';

final exerciseProvider =
    StateNotifierProvider<ExerciseProvider, List<NewExerciseEntry>>((ref) {
      return ExerciseProvider();
    });

class ExerciseProvider extends StateNotifier<List<NewExerciseEntry>> {
  ExerciseProvider() : super([]);
  Future<bool> addExerciseEntry(NewExerciseEntry entry) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        await con.execute(
          Sql.named(
            'INSERT INTO health_db.exercises(userid, exercise_type, duration, intensity, note, date_taken_on, time_taken_on)'
            ' VALUES (@userId, @exercise_type, @duration, @intensity, @note, @date_taken_on, @time_taken_on)',
          ),
          parameters: {
            'userId': entry.userId,
            'exercise_type': entry.exerciseType,
            'duration': entry.duration,
            'intensity': entry.intensity,
            'note': entry.note,
            'date_taken_on': entry.entryDate,
            'time_taken_on': entry.entryTime.toString(),
          },
        );

        // Refresh the list after adding new entry
        bool exercise = await getExerciseEntries(entry.userId);
        if (exercise) {
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

  Future<void> deleteExerciseEntry(int entryId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        await con.execute(
          Sql.named('DELETE FROM health_db.exercises WHERE id = @entryId'),
          parameters: {'entryId': entryId},
        );

        // Refresh the list after deleting entry
        await getExerciseEntries(entryId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getExerciseEntries(int userId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        List<List<dynamic>> results = await con.execute(
          Sql.named(
            'SELECT id, exercise_type, duration, intensity, note, date_taken_on, time_taken_on'
            ' FROM health_db.exercises WHERE userid = @userId ORDER BY date_taken_on DESC, time_taken_on DESC',
          ),
          parameters: {'userId': userId},
        );

        state = results.map((row) {
          return NewExerciseEntry(
            id: row[0] as int,
            userId: userId,
            exerciseType: safeParseString(row[1]),
            duration: safeParseInt(row[2]),
            intensity: safeParseString(row[3]),
            note: row[4] as String? ?? '',
            entryDate: row[5] as DateTime,
            entryTime: postgresStringToTimeOfDay(safeParseString([6])),
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

class NewExerciseEntry {
  final int? id;
  final int userId;
  final String? exerciseType;
  final int? duration;
  final String? intensity;
  final String? note;
  final DateTime entryDate;
  final TimeOfDay entryTime;

  NewExerciseEntry({
    this.id,
    required this.userId,
    required this.exerciseType,
    this.duration,
    this.intensity,
    required this.note,
    required this.entryDate,
    required this.entryTime,
  });
}
