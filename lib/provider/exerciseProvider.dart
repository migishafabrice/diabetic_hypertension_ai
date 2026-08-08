import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/physical_activity_dao.dart';
import '../models/local_physical_activity.dart';
import '../widgets/components.dart';

final exerciseProvider =
    StateNotifierProvider<ExerciseProvider, List<LocalPhysicalActivity>>((ref) {
      return ExerciseProvider();
    });

class ExerciseProvider extends StateNotifier<List<LocalPhysicalActivity>> {
  ExerciseProvider() : super([]);
  final PhysicalActivityDao _dao = PhysicalActivityDao();

  TimeOfDay stringToTimeOfDay(String timeString) {
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

  String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> addExerciseEntry(LocalPhysicalActivity entry) async {
    try {
      await _dao.insertPhysicalActivity(entry);
      await getExerciseEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getExerciseEntries(int userid) async {
    try {
      final entries = await _dao.getAllActivityForUser(userid);
      state = entries;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExerciseEntry(int entryId, int userid) async {
    try {
      await _dao.deletePhysicalActivity(entryId);
      await getExerciseEntries(userid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateExerciseEntry(LocalPhysicalActivity entry) async {
    try {
      await _dao.updatePhysicalActivity(entry);
      await getExerciseEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  void clearEntries() {
    state = [];
  }
}
