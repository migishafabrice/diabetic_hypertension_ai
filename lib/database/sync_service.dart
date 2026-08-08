import '../models/local_blood_sugar.dart';
import '../models/local_blood_pressure.dart';
import '../models/local_food_intake.dart';
import '../models/local_physical_activity.dart';
import '../models/local_medication.dart';
import '../models/local_medication_intake.dart';
import 'databaseService.dart';
import 'user_dao.dart';
import 'blood_pressure_dao.dart';
import 'blood_sugar_dao.dart';
import 'physical_activity_dao.dart';
import 'food_intake_dao.dart';
import 'medication_dao.dart';
import 'medication_intake_dao.dart';
import '../services/api_service.dart';

class SyncService {
  final UserDao _userDao = UserDao();
  final BloodPressureDao _bloodPressureDao = BloodPressureDao();
  final BloodSugarDao _bloodSugarDao = BloodSugarDao();
  final PhysicalActivityDao _physicalActivityDao = PhysicalActivityDao();
  final FoodIntakeDao _foodIntakeDao = FoodIntakeDao();
  final MedicationDao _medicationDao = MedicationDao();
  final MedicationIntakeDao _medicationIntakeDao = MedicationIntakeDao();
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> syncAll(int userId) async {
    try {
      final syncPayload = await _buildSyncPayload(userId);
      final response = await _apiService.syncData(syncPayload);

      if (response['success'] == true) {
        await _processServerData(response['server_data'], userId);
        await _markAsSynced(response['synced_ids']);
      }

      return response;
    } catch (e) {
      print("Error during sync: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _buildSyncPayload(int userId) async {
    final unsyncedBloodSugar = await _bloodSugarDao.getUnsyncedBloodSugar();
    final unsyncedBloodPressure = await _bloodPressureDao
        .getUnsyncedBloodPressure();

    return {
      'user_id': userId,
      'blood_sugar': unsyncedBloodSugar
          .map((e) => _bloodSugarToJson(e))
          .toList(),
      'blood_pressure': unsyncedBloodPressure
          .map((e) => _bloodPressureToJson(e))
          .toList(),
      'food_intake': [],
      'exercises': [],
      'medication_prescriptions': [],
      'medication_dosages': [],
      'appointments': [],
    };
  }

  Map<String, dynamic> _bloodSugarToJson(LocalBloodSugar bs) {
    return {
      'id': bs.cloudId,
      'local_id': bs.id,
      'user_id': bs.userid,
      'blood_sugar_level': bs.level,
      'blood_measurement_unit': bs.unit,
      'blood_measurement_context': bs.mealRelation,
      'blood_measurement_time': bs.dateTakenOn != null
          ? '${bs.dateTakenOn}T${bs.timeTakenOn}'
          : null,
      'notes': bs.note,
    };
  }

  Map<String, dynamic> _bloodPressureToJson(LocalBloodPressure bp) {
    return {
      'id': bp.cloudId,
      'local_id': bp.id,
      'user_id': bp.userid,
      'systolic': bp.systolic,
      'diastolic': bp.diastolic,
      'pulse': bp.pulse,
      'blood_pressure_time': bp.dateTakenOn != null
          ? '${bp.dateTakenOn}T${bp.timeTakenOn}'
          : null,
      'note': bp.note,
    };
  }

  Future<void> _processServerData(
    Map<String, dynamic> serverData,
    int userId,
  ) async {
    // Process blood sugar
    if (serverData['blood_sugar'] != null) {
      for (var item in serverData['blood_sugar']) {
        final bs = LocalBloodSugar(
          cloudId: item['id'],
          userid: userId,
          level: item['blood_sugar_level']?.toDouble() ?? 0.0,
          unit: item['blood_measurement_unit'],
          mealRelation: item['blood_measurement_context'],
          dateTakenOn: item['blood_measurement_time']?.split('T').first,
          timeTakenOn: item['blood_measurement_time']?.split('T').last,
          note: item['notes'],
          syncStatus: 1,
        );
        await _bloodSugarDao.insertBloodSugar(bs);
      }
    }

    // Process blood pressure
    if (serverData['blood_pressure'] != null) {
      for (var item in serverData['blood_pressure']) {
        final bp = LocalBloodPressure(
          cloudId: item['id'],
          userid: userId,
          systolic: item['systolic'],
          diastolic: item['diastolic'],
          pulse: item['pulse'],
          dateTakenOn: item['blood_pressure_time']?.split('T').first,
          timeTakenOn: item['blood_pressure_time']?.split('T').last,
          note: item['note'],
          syncStatus: 1,
        );
        await _bloodPressureDao.insertBloodPressure(bp);
      }
    }
  }

  Future<void> _markAsSynced(Map<String, dynamic> syncedIds) async {
    // Mark blood sugar as synced
    if (syncedIds['blood_sugar'] != null) {
      for (var id in syncedIds['blood_sugar']) {
        final bsList = await _bloodSugarDao.getAllBloodSugarForUser(
          1,
        ); // TODO: use actual user id
        for (var bs in bsList) {
          if (bs.id == id || bs.cloudId == id) {
            final updatedBs = bs.copyWith(syncStatus: 1);
            await _bloodSugarDao.updateBloodSugar(updatedBs);
          }
        }
      }
    }

    // Mark blood pressure as synced
    if (syncedIds['blood_pressure'] != null) {
      for (var id in syncedIds['blood_pressure']) {
        final bpList = await _bloodPressureDao.getAllBloodPressureForUser(
          1,
        ); // TODO: use actual user id
        for (var bp in bpList) {
          if (bp.id == id || bp.cloudId == id) {
            final updatedBp = bp.copyWith(syncStatus: 1);
            await _bloodPressureDao.updateBloodPressure(updatedBp);
          }
        }
      }
    }
  }
}
