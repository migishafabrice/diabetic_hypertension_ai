import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/sync_service.dart';

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(SyncService());
});

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncState {
  final SyncStatus status;
  final String? errorMessage;
  final DateTime? lastSyncTime;

  SyncState({
    this.status = SyncStatus.idle,
    this.errorMessage,
    this.lastSyncTime,
  });

  SyncState copyWith({
    SyncStatus? status,
    String? errorMessage,
    DateTime? lastSyncTime,
  }) {
    return SyncState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final SyncService _syncService;

  SyncNotifier(this._syncService) : super(SyncState());

  Future<void> syncNow(int userId) async {
    if (state.status == SyncStatus.syncing) return;

    state = state.copyWith(status: SyncStatus.syncing);

    try {
      final result = await _syncService.syncAll(userId);
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncTime: DateTime.now(),
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void resetState() {
    state = SyncState(status: SyncStatus.idle);
  }
}
