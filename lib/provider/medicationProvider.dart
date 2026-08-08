import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/medication_dao.dart';
import '../models/local_medication.dart';

final medicationProvider =
    StateNotifierProvider<MedicationProvider, List<LocalMedication>>((ref) {
      return MedicationProvider();
    });

class MedicationProvider extends StateNotifier<List<LocalMedication>> {
  MedicationProvider() : super([]);
  final MedicationDao _dao = MedicationDao();

  Future<void> addMedicationEntry(LocalMedication entry) async {
    try {
      await _dao.insertMedication(entry);
      await getMedicationEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getMedicationEntries(int userid) async {
    try {
      final entries = await _dao.getAllMedicationsForUser(userid);
      state = entries;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMedicationEntry(int entryId, int userid) async {
    try {
      await _dao.deleteMedication(entryId);
      await getMedicationEntries(userid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMedicationEntry(LocalMedication entry) async {
    try {
      await _dao.updateMedication(entry);
      await getMedicationEntries(entry.userid);
    } catch (e) {
      rethrow;
    }
  }

  void clearEntries() {
    state = [];
  }
}
