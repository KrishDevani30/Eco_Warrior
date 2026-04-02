import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/local_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/waste_log_model.dart';
import '../../data/models/pickup_request_model.dart';

class CurrentUserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;
  void set(UserModel? user) => state = user;
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, UserModel?>(() => CurrentUserNotifier());

final wasteLogsProvider = NotifierProvider<WasteLogNotifier, List<WasteLogModel>>(() {
  return WasteLogNotifier();
});

class WasteLogNotifier extends Notifier<List<WasteLogModel>> {
  @override
  List<WasteLogModel> build() {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];
    return ref.watch(localRepositoryProvider).getWasteLogs().where((l) => l.userId == user.id).toList();
  }

  Future<void> addLog(WasteLogModel log) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    await ref.read(localRepositoryProvider).addWasteLog(log);
    state = ref.read(localRepositoryProvider).getWasteLogs().where((l) => l.userId == user.id).toList();
  }
}

final pickupRequestsProvider = NotifierProvider<PickupRequestNotifier, List<PickupRequestModel>>(() {
  return PickupRequestNotifier();
});

class PickupRequestNotifier extends Notifier<List<PickupRequestModel>> {
  @override
  List<PickupRequestModel> build() {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];
    return ref.watch(localRepositoryProvider).getPickups().where((p) => p.userId == user.id).toList();
  }

  Future<void> addRequest(PickupRequestModel request) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    await ref.read(localRepositoryProvider).addPickup(request);
    state = ref.read(localRepositoryProvider).getPickups().where((p) => p.userId == user.id).toList();
  }
}

final userPointsProvider = Provider<int>((ref) {
  final logs = ref.watch(wasteLogsProvider);
  final pickups = ref.watch(pickupRequestsProvider);
  return (logs.length * 10) + (pickups.length * 50);
});
