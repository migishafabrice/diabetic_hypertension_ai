import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/blood_pressure_dao.dart';
import '../models/local_blood_pressure.dart';
import '../widgets/components.dart';

final bloodPressureProvider =
    StateNotifierProvider<BloodPressureNotifier, List<LocalBloodPressure>>((
      ref,
    ) {
      return BloodPressureNotifier();
    });

class BloodPressureNotifier extends StateNotifier<List<LocalBloodPressure>> {
  BloodPressureNotifier() : super([]);
  final BloodPressureDao _dao = BloodPressureDao();

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

  Future<void> addBloodPressureEntry(LocalBloodPressure entry) async {
    try {
      await _dao.insertBloodPressure(entry);
      await getBloodPressureEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getBloodPressureEntries(int userId) async {
    try {
      final entries = await _dao.getAllBloodPressureForUser(userId);
      state = entries;
    } catch (e) {
      rethrow;
    }
  }

  // Clear all entries
  void clearEntries() {
    state = [];
  }

  Future<void> deleteBloodPressureEntry(int entryId, int userId) async {
    try {
      await _dao.deleteBloodPressure(entryId);
      await getBloodPressureEntries(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBloodPressureEntry(LocalBloodPressure entry) async {
    try {
      await _dao.updateBloodPressure(entry);
      await getBloodPressureEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }
}