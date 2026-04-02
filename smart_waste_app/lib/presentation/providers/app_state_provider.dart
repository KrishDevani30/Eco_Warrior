import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/local_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/waste_log_model.dart';
import '../../data/models/pickup_request_model.dart';

class CurrentUserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;
  void set(UserModel? user) => state = user;
  
  Future<void> updateName(String newName) async {
    if (state == null) return;
    final updatedUser = state!.copyWith(name: newName);
    await ref.read(localRepositoryProvider).updateUserName(updatedUser);
    state = updatedUser;
  }
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

  Future<void> deleteRequest(String id) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    await ref.read(localRepositoryProvider).deletePickup(id);
    state = ref.read(localRepositoryProvider).getPickups().where((p) => p.userId == user.id).toList();
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    await ref.read(localRepositoryProvider).updatePickupStatus(id, newStatus);
    state = ref.read(localRepositoryProvider).getPickups().where((p) => p.userId == user.id).toList();
    
    // Also invalidate the global list if needed
    ref.invalidate(allPickupRequestsProvider);
  }
}

// Admin Providers
final allPickupRequestsProvider = Provider<List<PickupRequestModel>>((ref) {
  return ref.watch(localRepositoryProvider).getPickups();
});

final allWasteLogsProvider = Provider<List<WasteLogModel>>((ref) {
  return ref.watch(localRepositoryProvider).getWasteLogs();
});

final userPointsProvider = Provider<int>((ref) {
  final logs = ref.watch(wasteLogsProvider);
  final pickups = ref.watch(pickupRequestsProvider);
  return (logs.length * 10) + (pickups.length * 50);
});
