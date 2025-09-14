enum UserRole {
  customer,
  admin,
  manager,
}

class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.role = UserRole.customer,
    required this.createdAt,
    this.isActive = true,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.customer,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
    };
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager || role == UserRole.admin;
}
