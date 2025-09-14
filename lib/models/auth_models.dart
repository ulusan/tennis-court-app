// User Role enum - Backend ile uyumlu
enum UserRole {
  customer('customer'),
  admin('admin'),
  manager('manager');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.customer,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final UserRole? role;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role?.value,
    };
  }
}

class AuthResponse {
  final bool success;
  final String? token;
  final User? user;
  final String? message;

  AuthResponse({
    required this.success,
    this.token,
    this.user,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'] ?? '',
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.role = UserRole.customer,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImageUrl: json['profileImageUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now().toLocal(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']).toLocal()
          : DateTime.now().toLocal(),
      isActive: json['isActive'] ?? true,
      role: UserRole.fromString(json['role'] ?? 'customer'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'role': role.value,
    };
  }

  // Helper methods
  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager;
  bool get isCustomer => role == UserRole.customer;
}
