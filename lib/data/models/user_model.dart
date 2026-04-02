import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 3)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final bool isAdmin;

  @HiveField(4)
  final double points;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.isAdmin = false,
    this.points = 0.0,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    bool? isAdmin,
    double? points,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      points: points ?? this.points,
    );
  }
}
