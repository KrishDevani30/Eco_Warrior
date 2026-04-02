import 'package:hive/hive.dart';

part 'pickup_request_model.g.dart';

@HiveType(typeId: 2)
class PickupRequestModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime scheduledDate;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final String status; // 'Pending', 'Assigned', 'Completed'

  PickupRequestModel({
    required this.id,
    required this.scheduledDate,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
  });
}
