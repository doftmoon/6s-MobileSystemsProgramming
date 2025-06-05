enum UserRole { regular, admin }

class UserModel {
  final String id;
  final String name;
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.regular,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.toString().split('.').last,
    };
  }
}
