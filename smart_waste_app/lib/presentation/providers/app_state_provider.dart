import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/local_repository.dart';
import '../../data/models/waste_log_model.dart';
import '../../data/models/pickup_request_model.dart';

final wasteLogsProvider = NotifierProvider<WasteLogNotifier, List<WasteLogModel>>(() {
  return WasteLogNotifier();
});

class WasteLogNotifier extends Notifier<List<WasteLogModel>> {
  @override
  List<WasteLogModel> build() {
    return ref.watch(localRepositoryProvider).getWasteLogs();
  }

  Future<void> addLog(WasteLogModel log) async {
    await ref.read(localRepositoryProvider).addWasteLog(log);
    state = [...ref.read(localRepositoryProvider).getWasteLogs()];
  }
}

final pickupRequestsProvider = NotifierProvider<PickupRequestNotifier, List<PickupRequestModel>>(() {
  return PickupRequestNotifier();
});

class PickupRequestNotifier extends Notifier<List<PickupRequestModel>> {
  @override
  List<PickupRequestModel> build() {
    return ref.watch(localRepositoryProvider).getPickups();
  }

  Future<void> addRequest(PickupRequestModel request) async {
    await ref.read(localRepositoryProvider).addPickup(request);
    state = [...ref.read(localRepositoryProvider).getPickups()];
  }
}

final userPointsProvider = Provider<int>((ref) {
  final logs = ref.watch(wasteLogsProvider);
  final pickups = ref.watch(pickupRequestsProvider);
  return (logs.length * 10) + (pickups.length * 50);
});
