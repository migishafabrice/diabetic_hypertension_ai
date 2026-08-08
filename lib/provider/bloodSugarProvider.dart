import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/blood_sugar_dao.dart';
import '../models/local_blood_sugar.dart';

final bloodSugarProvider =
    StateNotifierProvider<BloodSugarProvider, List<LocalBloodSugar>>((ref) {
      return BloodSugarProvider();
    });

class BloodSugarProvider extends StateNotifier<List<LocalBloodSugar>> {
  BloodSugarProvider() : super([]);
  final BloodSugarDao _dao = BloodSugarDao();

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

  Future<void> addBloodSugarEntry(LocalBloodSugar entry) async {
    try {
      await _dao.insertBloodSugar(entry);
      await getBloodSugarEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getBloodSugarEntries(int userId) async {
    try {
      final entries = await _dao.getAllBloodSugarForUser(userId);
      state = entries;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBloodSugarEntry(int entryId, int userId) async {
    try {
      await _dao.deleteBloodSugar(entryId);
      await getBloodSugarEntries(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBloodSugarEntry(LocalBloodSugar entry) async {
    try {
      await _dao.updateBloodSugar(entry);
      await getBloodSugarEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  void clearEntries() {
    state = [];
  }
}
