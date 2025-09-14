import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../config/app_config.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  static const String _userKey = 'user_data';

  // Get stored user
  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  // Store auth data
  Future<void> _storeAuthData(String token, User user) async {
    await _apiService.setToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Clear auth data
  Future<void> clearAuthData() async {
    await _apiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Login
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.authLogin,
        body: request.toJson(),
        includeAuth: false,
      );

      final responseData = _apiService.handleResponse(response);
      
      if (responseData['success'] == true) {
        final user = User.fromJson(responseData['user']);
        final token = responseData['token'];
        
        await _storeAuthData(token, user);
        
        return AuthResponse(
          success: true,
          token: token,
          user: user,
          message: responseData['message'] ?? 'Giriş başarılı',
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Giriş başarısız',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e is ApiException ? e.message : 'Bağlantı hatası: $e',
      );
    }
  }

  // Register
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.authRegister,
        body: request.toJson(),
        includeAuth: false,
      );

      final responseData = _apiService.handleResponse(response);
      
      if (responseData['success'] == true) {
        final user = User.fromJson(responseData['user']);
        final token = responseData['token'];
        
        await _storeAuthData(token, user);
        
        return AuthResponse(
          success: true,
          token: token,
          user: user,
          message: responseData['message'] ?? 'Kayıt başarılı',
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Kayıt başarısız',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e is ApiException ? e.message : 'Bağlantı hatası: $e',
      );
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      // Try to call logout endpoint (optional)
      try {
        await _apiService.post(AppConfig.authLogout);
      } catch (e) {
        // Ignore logout API errors
      }
      
      await clearAuthData();
      return true;
    } catch (e) {
      // Even if API call fails, clear local data
      await clearAuthData();
      return true;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    final user = await getStoredUser();
    return token != null && user != null;
  }

  // Refresh token
  Future<AuthResponse> refreshToken() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        return AuthResponse(success: false, message: 'Token bulunamadı');
      }

      final response = await _apiService.post(AppConfig.authRefresh);
      final responseData = _apiService.handleResponse(response);
      
      if (responseData['success'] == true) {
        final user = User.fromJson(responseData['user']);
        final newToken = responseData['token'];
        
        await _storeAuthData(newToken, user);
        
        return AuthResponse(
          success: true,
          token: newToken,
          user: user,
          message: responseData['message'] ?? 'Token yenilendi',
        );
      } else {
        await clearAuthData();
        return AuthResponse(success: false, message: 'Token yenileme başarısız');
      }
    } catch (e) {
      await clearAuthData();
      return AuthResponse(
        success: false, 
        message: e is ApiException ? e.message : 'Bağlantı hatası: $e'
      );
    }
  }

  // Update profile
  Future<AuthResponse> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? profileImageUrl,
  }) async {
    print('AuthService: Profil güncelleme başlatılıyor...');
    print('AuthService: Endpoint: ${AppConfig.authUpdateProfile}');
    
    try {
      final updateData = {
        'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      };

      print('AuthService: Update data: $updateData');

      final response = await _apiService.put(
        AppConfig.authUpdateProfile,
        body: updateData,
      );

      print('AuthService: Response status: ${response.statusCode}');
      print('AuthService: Response body: ${response.body}');

      final responseData = _apiService.handleResponse(response);
      
      print('AuthService: Parsed response: $responseData');
      
      if (responseData['success'] == true || response.statusCode == 200) {
        final updatedUser = User.fromJson(responseData['user'] ?? responseData);
        
        // Update stored user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(updatedUser.toJson()));

        print('AuthService: Profil başarıyla güncellendi');
        return AuthResponse(
          success: true,
          user: updatedUser,
          message: responseData['message'] ?? 'Profil başarıyla güncellendi',
        );
      } else {
        print('AuthService: Profil güncelleme başarısız: ${responseData['message']}');
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Profil güncellenemedi',
        );
      }
    } catch (e) {
      print('AuthService: Profil güncelleme exception: $e');
      return AuthResponse(
        success: false,
        message: e is ApiException ? e.message : 'Bağlantı hatası: $e',
      );
    }
  }

  // Change password
  Future<AuthResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final changePasswordData = {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };

      final response = await _apiService.put(
        AppConfig.authChangePassword,
        body: changePasswordData,
      );

      final responseData = _apiService.handleResponse(response);
      
      if (responseData['success'] == true || response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: responseData['message'] ?? 'Şifre başarıyla değiştirildi',
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Şifre değiştirilemedi',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e is ApiException ? e.message : 'Bağlantı hatası: $e',
      );
    }
  }

  // Get user profile
  Future<AuthResponse> getProfile() async {
    try {
      final response = await _apiService.get(AppConfig.authProfile);
      final responseData = _apiService.handleResponse(response);
      
      if (responseData['success'] == true || response.statusCode == 200) {
        final user = User.fromJson(responseData);
        
        // Update stored user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(user.toJson()));

        return AuthResponse(
          success: true,
          user: user,
          message: 'Profil bilgileri alındı',
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Profil bilgileri alınamadı',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e is ApiException ? e.message : 'Bağlantı hatası: $e',
      );
    }
  }
}
