import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diacare/database/body_measurement_dao.dart';
import 'package:diacare/models/local_body_measurement.dart';

// Provider for body measurements
final bodyMeasurementProvider =
    StateNotifierProvider<BodyMeasurementNotifier, List<LocalBodyMeasurement>>((
  ref,
) {
  return BodyMeasurementNotifier();
});

class BodyMeasurementNotifier extends StateNotifier<List<LocalBodyMeasurement>> {
  final BodyMeasurementDao _dao = BodyMeasurementDao();

  BodyMeasurementNotifier() : super([]);

  // Add a new body measurement entry
  Future<void> addBodyMeasurement(LocalBodyMeasurement measurement) async {
    try {
      await _dao.insertMeasurement(measurement);
      // Refresh the list
      await getBodyMeasurements(measurement.userid);
    } catch (e) {
      rethrow;
    }
  }

  // Get all body measurements for a specific user
  Future<void> getBodyMeasurements(int userId) async {
    try {
      final measurements = await _dao.getMeasurementsByUserId(userId);
      state = measurements;
    } catch (e) {
      rethrow;
    }
  }

  // Delete a body measurement entry
  Future<void> deleteBodyMeasurement(int entryId, int userId) async {
    try {
      await _dao.deleteMeasurement(entryId);
      // Refresh the list
      await getBodyMeasurements(userId);
    } catch (e) {
      rethrow;
    }
  }

  // Update a body measurement entry
  Future<void> updateBodyMeasurement(LocalBodyMeasurement measurement) async {
    try {
      await _dao.updateMeasurement(measurement);
      await getBodyMeasurements(measurement.userid);
    } catch (e) {
      rethrow;
    }
  }
}
