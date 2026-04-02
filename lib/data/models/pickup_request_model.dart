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

  @HiveField(6)
  final String userId;

  @HiveField(7)
  final String? wasteLogId; // Link to the specific waste entry

  PickupRequestModel({
    required this.id,
    required this.scheduledDate,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.userId,
    this.wasteLogId,
  });

  PickupRequestModel copyWith({
    String? id,
    DateTime? scheduledDate,
    String? address,
    double? latitude,
    double? longitude,
    String? status,
    String? userId,
    String? wasteLogId,
  }) {
    return PickupRequestModel(
      id: id ?? this.id,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      wasteLogId: wasteLogId ?? this.wasteLogId,
    );
  }
}
