import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/local_repository.dart';
import '../../data/models/waste_log_model.dart';
import '../../data/models/pickup_request_model.dart';

final wasteLogsProvider = StateNotifierProvider<WasteLogNotifier, List<WasteLogModel>>((ref) {
  return WasteLogNotifier(ref.watch(localRepositoryProvider));
});

class WasteLogNotifier extends StateNotifier<List<WasteLogModel>> {
  final LocalRepository _repository;

  WasteLogNotifier(this._repository) : super([]) {
    _loadLogs();
  }

  void _loadLogs() {
    state = _repository.getWasteLogs();
  }

  Future<void> addLog(WasteLogModel log) async {
    await _repository.addWasteLog(log);
    _loadLogs(); // Refresh state
  }
}

final pickupRequestsProvider = StateNotifierProvider<PickupRequestNotifier, List<PickupRequestModel>>((ref) {
  return PickupRequestNotifier(ref.watch(localRepositoryProvider));
});

class PickupRequestNotifier extends StateNotifier<List<PickupRequestModel>> {
  final LocalRepository _repository;

  PickupRequestNotifier(this._repository) : super([]) {
    _loadRequests();
  }

  void _loadRequests() {
    state = _repository.getPickups();
  }

  Future<void> addRequest(PickupRequestModel request) async {
    await _repository.addPickup(request);
    _loadRequests();
  }
}

final userPointsProvider = StateProvider<int>((ref) {
  // Simple mock points calculation based on items logged + pickups scheduled
  final logs = ref.watch(wasteLogsProvider);
  final pickups = ref.watch(pickupRequestsProvider);
  return (logs.length * 10) + (pickups.length * 50);
});
