import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/medication_intake_dao.dart';
import '../models/local_medication_intake.dart';

final medicationIntakeProvider =
    StateNotifierProvider<
      MedicationIntakeProvider,
      List<LocalMedicationIntake>
    >((ref) {
      return MedicationIntakeProvider();
    });

class MedicationIntakeProvider
    extends StateNotifier<List<LocalMedicationIntake>> {
  MedicationIntakeProvider() : super([]);
  final MedicationIntakeDao _dao = MedicationIntakeDao();

  Future<void> addMedicationIntakeEntry(LocalMedicationIntake entry) async {
    try {
      await _dao.insertMedicationIntake(entry);
      await getMedicationIntakeEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getMedicationIntakeEntries(int userid) async {
    try {
      final entries = await _dao.getAllIntakeForUser(userid);
      state = entries;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMedicationIntakeEntry(int entryId, int userid) async {
    try {
      await _dao.deleteMedicationIntake(entryId);
      await getMedicationIntakeEntries(userid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMedicationIntakeEntry(LocalMedicationIntake entry) async {
    try {
      await _dao.updateMedicationIntake(entry);
      await getMedicationIntakeEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  void clearEntries() {
    state = [];
  }
}
