import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Google ile giriş yap
  Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return GoogleSignInResult(
          success: false,
          message: 'Google girişi iptal edildi',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Backend'e Google kullanıcı bilgilerini gönder
      final result = await _sendToBackend(
        googleId: googleUser.id,
        email: googleUser.email,
        firstName: googleUser.displayName?.split(' ').first ?? '',
        lastName: googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
        picture: googleUser.photoUrl ?? '',
      );

      if (result.success) {
        return GoogleSignInResult(
          success: true,
          message: result.message,
          user: result.user,
          token: result.token,
        );
      } else {
        // Google girişini iptal et
        await _googleSignIn.signOut();
        return GoogleSignInResult(
          success: false,
          message: result.message,
        );
      }
    } catch (error) {
      return GoogleSignInResult(
        success: false,
        message: 'Google girişi sırasında hata oluştu: ${error.toString()}',
      );
    }
  }

  /// Google hesabından çıkış yap
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Mevcut Google kullanıcısını kontrol et
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return await _googleSignIn.signInSilently();
  }

  /// Backend'e Google kullanıcı bilgilerini gönder
  Future<BackendAuthResult> _sendToBackend({
    required String googleId,
    required String email,
    required String firstName,
    required String lastName,
    required String picture,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/google'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'googleId': googleId,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'picture': picture,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return BackendAuthResult(
          success: true,
          message: data['message'] ?? 'Giriş başarılı',
          user: data['user'],
          token: data['token'],
        );
      } else {
        return BackendAuthResult(
          success: false,
          message: data['message'] ?? 'Sunucu hatası',
        );
      }
    } catch (error) {
      return BackendAuthResult(
        success: false,
        message: 'Sunucu ile bağlantı hatası: ${error.toString()}',
      );
    }
  }
}

class GoogleSignInResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? user;
  final String? token;

  GoogleSignInResult({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });
}

class BackendAuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? user;
  final String? token;

  BackendAuthResult({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });
}
