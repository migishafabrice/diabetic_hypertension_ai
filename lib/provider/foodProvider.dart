import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthapp/database/databaseService.dart';
import 'package:healthapp/widgets/components.dart';
import 'package:postgres/postgres.dart';

final foodProvider = StateNotifierProvider<FoodProvider, List<NewFoodEntry>>((
  ref,
) {
  return FoodProvider();
});

class FoodProvider extends StateNotifier<List<NewFoodEntry>> {
  FoodProvider() : super([]);
  Future<bool> addFoodEntry(NewFoodEntry entry) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        print('Userid: ${entry.userId}');
        await con.execute(
          Sql.named(
            'INSERT INTO health_db.meal(userid, food_description, note, date_taken_on, time_taken_on)'
            ' VALUES (@userId, @food_description,@note, @date_taken_on, @time_taken_on)',
          ),
          parameters: {
            'userId': entry.userId,
            'food_description': entry.food_description,
            'note': entry.note,
            'date_taken_on': entry.entryDate,
            'time_taken_on': timeOfDayToPostgresString(entry.entryTime),
          },
        );
        bool food = await getFoodEntries(entry.userId);
        if (food) {
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

  Future<bool> getFoodEntries(int userId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        List<List<dynamic>> results = await con.execute(
          Sql.named(
            'SELECT id, userid, food_description, note, date_taken_on, time_taken_on'
            ' FROM health_db.meal WHERE userid = @userId ORDER BY date_taken_on DESC, time_taken_on DESC',
          ),
          parameters: {'userId': userId},
        );

        state = results.map((row) {
          return NewFoodEntry(
            id: row[0] as int,
            userId: userId,
            food_description: safeParseString(row[2]),
            note: safeParseString(row[3]),
            entryDate: safeParseDateTime(row[4]),
            entryTime: postgresStringToTimeOfDay(safeParseString(row[5])),
          );
        }).toList();
        if (state.isNotEmpty) {
          return true;
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFoodEntry(int entryId) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        await con.execute(
          Sql.named('DELETE FROM health_db.meal WHERE id = @entryId'),
          parameters: {'entryId': entryId},
        );

        // Refresh the list after deleting entry
        await getFoodEntries(state.first.userId);
      }
    } catch (e) {
      rethrow;
    }
  }
}

class NewFoodEntry {
  final int? id;
  final int userId;
  final String food_description;
  final String note;
  final DateTime entryDate;
  final TimeOfDay entryTime;

  NewFoodEntry({
    this.id,
    required this.userId,
    required this.food_description,
    this.note = '',
    required this.entryDate,
    required this.entryTime,
  });
}
