import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../../../shared/services/google_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null && _token != null;
  bool get isInitialized => _isInitialized;

  // Initialize auth state
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _authService.getStoredUser();
        _token = await _authService.getToken();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      if (response.success) {
        _user = response.user;
        _token = response.token;
        _error = null;
        print('Login successful - User: ${_user?.name}, Token: ${_token != null ? 'Present' : 'Missing'}');
        notifyListeners(); // State değişikliğini bildir
        return true;
      } else {
        _error = response.message ?? 'Giriş başarısız';
        print('Login failed - Error: $_error');
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(String name, String email, String password, {String? phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      final response = await _authService.register(request);

      if (response.success) {
        _user = response.user;
        _token = response.token;
        _error = null;
        print('Register successful - User: ${_user?.name}, Token: ${_token != null ? 'Present' : 'Missing'}');
        notifyListeners(); // State değişikliğini bildir
        return true;
      } else {
        _error = response.message ?? 'Kayıt başarısız';
        print('Register failed - Error: $_error');
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _googleAuthService.signInWithGoogle();

      if (result.success) {
        _user = User.fromJson(result.user!);
        _token = result.token;
        _error = null;
        
        // Store user data locally
        await _authService.storeUserData(_user!, _token!);
        
        notifyListeners();
        return true;
      } else {
        _error = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Google'dan da çıkış yap
      await _googleAuthService.signOut();
      await _authService.logout();
      _user = null;
      _token = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? profileImageUrl,
  }) async {
    print('AuthProvider: Profil güncelleme başlatılıyor...');
    print('AuthProvider: Name: $name, Email: $email, Phone: $phone, ProfileImageUrl: $profileImageUrl');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );

      print('AuthProvider: Service response: ${response.success}');
      print('AuthProvider: Service message: ${response.message}');
      print('AuthProvider: Service user: ${response.user?.name}');

      if (response.success && response.user != null) {
        _user = response.user;
        _error = null;
        notifyListeners();
        print('AuthProvider: Profil başarıyla güncellendi');
        return true;
      } else {
        _error = response.message ?? 'Profil güncellenemedi';
        print('AuthProvider: Profil güncelleme hatası: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('AuthProvider: Profil güncelleme exception: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Test helper methods
  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Şifre değiştirilemedi';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final response = await _authService.refreshToken();
      
      if (response.success) {
        _user = response.user;
        _token = response.token;
        notifyListeners();
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }
}
