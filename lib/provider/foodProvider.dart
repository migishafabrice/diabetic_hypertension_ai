import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/food_intake_dao.dart';
import '../models/local_food_intake.dart';

final foodProvider =
    StateNotifierProvider<FoodProvider, List<LocalFoodIntake>>((ref) {
  return FoodProvider();
});

class FoodProvider extends StateNotifier<List<LocalFoodIntake>> {
  FoodProvider() : super([]);
  final FoodIntakeDao _dao = FoodIntakeDao();

  Future<void> addFoodEntry(LocalFoodIntake entry) async {
    try {
      await _dao.insertFoodIntake(entry);
      await getFoodEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getFoodEntries(int userId) async {
    try {
      final entries = await _dao.getAllFoodForUser(userId);
      state = entries;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFoodEntry(int entryId, int userId) async {
    try {
      await _dao.deleteFoodIntake(entryId);
      await getFoodEntries(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFoodEntry(LocalFoodIntake entry) async {
    try {
      await _dao.updateFoodIntake(entry);
      await getFoodEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  void clearEntries() {
    state = [];
  }
}