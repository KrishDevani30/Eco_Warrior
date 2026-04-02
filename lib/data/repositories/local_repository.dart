import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/waste_log_model.dart';
import '../models/pickup_request_model.dart';

final localRepositoryProvider = Provider<LocalRepository>((ref) {
  return LocalRepository();
});

class LocalRepository {
  static const String _wasteBox = 'waste_logs';
  static const String _pickupBox = 'pickup_requests';
  static const String _userBox = 'users';

  Future<void> init() async {
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(WasteLogModelAdapter());
    Hive.registerAdapter(PickupRequestModelAdapter());
    
    // Ensure boxes are open (Persistence is maintained)
    await Hive.openBox<UserModel>(_userBox);
    await Hive.openBox<WasteLogModel>(_wasteBox);
    await Hive.openBox<PickupRequestModel>(_pickupBox);
  }

  Future<void> updateUserName(UserModel user) async {
    final box = Hive.box<UserModel>(_userBox);
    await box.put(user.id, user);
  }

  // Auth Users
  Future<UserModel> loginOrCreateUser(String email) async {
    final box = Hive.box<UserModel>(_userBox);
    final existingUsers = box.values.where((u) => u.email.toLowerCase() == email.toLowerCase());
    
    if (existingUsers.isNotEmpty) {
      return existingUsers.first;
    }
    
    // Create dummy user
    final newUser = UserModel(
      id: const Uuid().v4(),
      email: email,
      name: email.split('@')[0], // Generate dummy name from email
      isAdmin: email.toLowerCase() == 'admin@eco.com',
    );
    
    await box.put(newUser.id, newUser);
    return newUser;
  }

  Future<void> updateWasteLogStatus(String id, String newStatus) async {
    final box = Hive.box<WasteLogModel>(_wasteBox);
    final log = box.get(id);
    if (log != null) {
      await box.put(id, log.copyWith(pickupStatus: newStatus));
    }
  }

  Future<void> updateUserPoints(String userId, double additionalPoints) async {
    final box = Hive.box<UserModel>(_userBox);
    final user = box.get(userId);
    if (user != null) {
      await box.put(userId, user.copyWith(points: user.points + additionalPoints));
    }
  }

  // Waste Logs
  List<WasteLogModel> getWasteLogs() {
    final box = Hive.box<WasteLogModel>(_wasteBox);
    return box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addWasteLog(WasteLogModel log) async {
    final box = Hive.box<WasteLogModel>(_wasteBox);
    await box.put(log.id, log);
  }

  // Pickups
  List<PickupRequestModel> getPickups() {
    final box = Hive.box<PickupRequestModel>(_pickupBox);
    return box.values.toList()..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  Future<void> addPickup(PickupRequestModel request) async {
    final box = Hive.box<PickupRequestModel>(_pickupBox);
    await box.put(request.id, request);
    
    // Workflow: Update linked waste log status
    if (request.wasteLogId != null) {
      await updateWasteLogStatus(request.wasteLogId!, 'Requested');
    }
  }

  Future<void> deletePickup(String id) async {
    final box = Hive.box<PickupRequestModel>(_pickupBox);
    final request = box.get(id);
    if (request != null && request.wasteLogId != null) {
      // Revert waste log status if pickup is cancelled/deleted
      await updateWasteLogStatus(request.wasteLogId!, 'Not Requested');
    }
    await box.delete(id);
  }

  Future<void> updatePickupStatus(String id, String newStatus) async {
    final box = Hive.box<PickupRequestModel>(_pickupBox);
    final request = box.get(id);
    if (request != null) {
      final oldStatus = request.status;
      await box.put(id, request.copyWith(status: newStatus));
      
      // Sync with Waste Log
      if (request.wasteLogId != null) {
        await updateWasteLogStatus(request.wasteLogId!, newStatus);
      }

      // Reward points ONLY if transitioning TO Completed for the first time
      if (newStatus == 'Completed' && oldStatus != 'Completed') {
        final wasteBox = Hive.box<WasteLogModel>(_wasteBox);
        final log = wasteBox.get(request.wasteLogId);
        if (log != null) {
          double pointsToAdd = log.quantity * 10;
          await updateUserPoints(request.userId, pointsToAdd);
        }
      }
    }
  }
  
  // Dashboard stats
  double getTotalWasteCollected() {
    final logs = getWasteLogs();
    double total = 0;
    for (var log in logs) {
      total += log.quantity;
    }
    return total;
  }
}
