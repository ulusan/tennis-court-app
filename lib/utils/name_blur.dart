class NameBlur {
  /// Kullanıcı adını blur'lar
  /// Örnek: "YUSUF EMRE" -> "YU**** EM***"
  static String blurName(String name) {
    if (name.isEmpty) return 'Bilinmeyen';
    
    final words = name.trim().split(' ');
    final blurredWords = words.map((word) => _blurWord(word)).toList();
    
    return blurredWords.join(' ');
  }
  
  /// Tek kelimeyi blur'lar
  /// Örnek: "YUSUF" -> "YU****", "EMRE" -> "EM***"
  static String _blurWord(String word) {
    if (word.length <= 2) {
      return word;
    }
    
    final firstTwo = word.substring(0, 2);
    final asterisks = '*' * (word.length - 2);
    
    return '$firstTwo$asterisks';
  }
  
  /// Email'i blur'lar
  /// Örnek: "yusuf@example.com" -> "yu***@example.com"
  static String blurEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;
    
    final parts = email.split('@');
    final localPart = parts[0];
    final domain = parts[1];
    
    if (localPart.length <= 2) {
      return email;
    }
    
    final firstTwo = localPart.substring(0, 2);
    final asterisks = '*' * (localPart.length - 2);
    
    return '$firstTwo$asterisks@$domain';
  }
}
