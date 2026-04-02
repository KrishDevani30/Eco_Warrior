import 'package:hive/hive.dart';

part 'waste_log_model.g.dart';

@HiveType(typeId: 1)
class WasteLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category; // e.g. 'Organic', 'Plastic', 'E-Waste'

  @HiveField(2)
  final double quantity;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final bool isSynced;

  @HiveField(5)
  final String? imagePath;

  @HiveField(6)
  final String userId;

  @HiveField(7)
  final String pickupStatus; // 'Not Requested', 'Requested', 'Approved', 'Completed', 'Rejected'

  @HiveField(8)
  final String location; // 'GPS: Lat, Lng'

  WasteLogModel({
    required this.id,
    required this.category,
    required this.quantity,
    required this.date,
    this.isSynced = false,
    this.imagePath,
    required this.userId,
    this.pickupStatus = 'Not Requested',
    this.location = 'Unknown',
  });

  WasteLogModel copyWith({
    String? id,
    String? category,
    double? quantity,
    DateTime? date,
    bool? isSynced,
    String? imagePath,
    String? userId,
    String? pickupStatus,
    String? location,
  }) {
    return WasteLogModel(
      id: id ?? this.id,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      isSynced: isSynced ?? this.isSynced,
      imagePath: imagePath ?? this.imagePath,
      userId: userId ?? this.userId,
      pickupStatus: pickupStatus ?? this.pickupStatus,
      location: location ?? this.location,
    );
  }
}
