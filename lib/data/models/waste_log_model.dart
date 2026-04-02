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

  WasteLogModel({
    required this.id,
    required this.category,
    required this.quantity,
    required this.date,
    this.isSynced = false,
    this.imagePath,
  });
}
