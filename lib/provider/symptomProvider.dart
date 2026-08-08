
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/symptom_dao.dart';
import '../models/local_symptom.dart';
import '../widgets/components.dart';

final symptomProvider =
    StateNotifierProvider<SymptomNotifier, List<LocalSymptom>>((
  ref,
) {
  return SymptomNotifier();
});

class SymptomNotifier extends StateNotifier<List<LocalSymptom>> {
  SymptomNotifier() : super([]);
  final SymptomDao _dao = SymptomDao();

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

  Future<void> addSymptomEntry(LocalSymptom entry) async {
    try {
      await _dao.insertSymptom(entry);
      await getSymptomEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getSymptomEntries(int userId) async {
    try {
      final entries = await _dao.getAllSymptomsForUser(userId);
      state = entries;
    } catch (e) {
      rethrow;
    }
  }

  void clearEntries() {
    state = [];
  }

  Future<void> deleteSymptomEntry(int entryId, int userId) async {
    try {
      await _dao.deleteSymptom(entryId);
      await getSymptomEntries(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSymptomEntry(LocalSymptom entry) async {
    try {
      await _dao.updateSymptom(entry);
      await getSymptomEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }
}
