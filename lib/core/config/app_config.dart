import 'dart:io';

class AppConfig {
  // Backend API URL - Platform bazlı
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android Emulator için
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      // iOS Simulator için
      return 'http://localhost:3000';
    } else {
      // Web veya diğer platformlar için
      return 'http://localhost:3000';
    }
  }
  
  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authProfile = '/auth/profile';
  static const String authUpdateProfile = '/auth/profile';
  static const String authChangePassword = '/auth/change-password';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  
  // User endpoints
  static String userProfile(String userId) => '/users/$userId';
  
  // Court endpoints
  static const String courts = '/courts';
  static const String courtAvailability = '/courts/availability';
  
  // Reservation endpoints
  static const String reservations = '/reservations';
  static String userReservations(String userId) => '/reservations/user/$userId';
  static const String reservationAvailability = '/reservations/availability';
  static String courtReservations(String courtId) => '/reservations/court/$courtId';
}
