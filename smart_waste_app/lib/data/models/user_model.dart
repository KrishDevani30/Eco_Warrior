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

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.isAdmin = false,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
