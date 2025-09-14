import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      print('AuthService: Login request starting...');
      print('AuthService: URL: ${AppConfig.baseUrl}${AppConfig.authLogin}');
      print('AuthService: Request body: ${jsonEncode(request.toJson())}');
      
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.authLogin}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(AppConstants.requestTimeout);

      print('AuthService: Response status code: ${response.statusCode}');
      print('AuthService: Response body: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(data);
        print('AuthService: Parsed authResponse success: ${authResponse.success}');
        print('AuthService: Parsed authResponse message: ${authResponse.message}');
        print('AuthService: Parsed authResponse token: ${authResponse.token != null ? 'Present' : 'Missing'}');
        print('AuthService: Parsed authResponse user: ${authResponse.user?.name}');
        
        if (authResponse.success && authResponse.token != null) {
          await _saveAuthData(authResponse.token!, authResponse.user);
          print('AuthService: Auth data saved successfully');
        }
        
        return authResponse;
      } else {
        print('AuthService: Login failed with status code: ${response.statusCode}');
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Giriş başarısız',
        );
      }
    } catch (e) {
      print('AuthService: Login exception: $e');
      return AuthResponse(
        success: false,
        message: 'Bağlantı hatası: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.authRegister}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(AppConstants.requestTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.success && authResponse.token != null) {
          await _saveAuthData(authResponse.token!, authResponse.user);
        }
        
        return authResponse;
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Kayıt başarısız',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Bağlantı hatası: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResponse(
          success: false,
          message: 'Oturum süresi dolmuş',
        );
      }

      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.authUpdateProfile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'profileImageUrl': profileImageUrl,
        }),
      ).timeout(AppConstants.requestTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.success && authResponse.user != null) {
          await _saveUserData(authResponse.user!);
        }
        
        return authResponse;
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Profil güncellenemedi',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Bağlantı hatası: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResponse(
          success: false,
          message: 'Oturum süresi dolmuş',
        );
      }

      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.authChangePassword}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(AppConstants.requestTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      return AuthResponse(
        success: response.statusCode == 200,
        message: data['message'] ?? (response.statusCode == 200 ? 'Şifre güncellendi' : 'Şifre güncellenemedi'),
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Bağlantı hatası: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> refreshToken() async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResponse(
          success: false,
          message: 'Token bulunamadı',
        );
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.authRefresh}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.requestTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.success && authResponse.token != null) {
          await _saveToken(authResponse.token!);
        }
        
        return authResponse;
      } else {
        return AuthResponse(
          success: false,
          message: 'Token yenilenemedi',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Bağlantı hatası: ${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${AppConfig.baseUrl}${AppConfig.authLogout}'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ).timeout(AppConstants.requestTimeout);
      }
    } catch (e) {
      // Logout hatası önemli değil, local temizlik yap
    } finally {
      await _clearAuthData();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  Future<void> _saveAuthData(String token, User? user) async {
    await _saveToken(token);
    if (user != null) {
      await _saveUserData(user);
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Google auth için kullanılacak metod
  Future<void> storeUserData(User user, String token) async {
    await _saveAuthData(token, user);
  }
}
