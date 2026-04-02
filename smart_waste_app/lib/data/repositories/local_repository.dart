import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/waste_log_model.dart';
import '../models/pickup_request_model.dart';

final localRepositoryProvider = Provider<LocalRepository>((ref) {
  return LocalRepository();
});

class LocalRepository {
  static const String _wasteBox = 'waste_logs';
  static const String _pickupBox = 'pickup_requests';

  Future<void> init() async {
    Hive.registerAdapter(WasteLogModelAdapter());
    Hive.registerAdapter(PickupRequestModelAdapter());
    
    await Hive.openBox<WasteLogModel>(_wasteBox);
    await Hive.openBox<PickupRequestModel>(_pickupBox);
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
