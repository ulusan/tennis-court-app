// App Constants
class AppConstants {
  // API Timeout settings
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
  
  // Retry settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // UI Constants
  static const double borderRadius = 16.0;
  static const double smallBorderRadius = 12.0;
  static const double largeBorderRadius = 24.0;
  
  // Colors
  static const int primaryColor = 0xFF10B981;
  static const int secondaryColor = 0xFF059669;
  static const int accentColor = 0xFF047857;
  static const int errorColor = 0xFFEF4444;
  static const int warningColor = 0xFFFF9800;
  static const int successColor = 0xFF4CAF50;
}
