class NameBlur {
  static String blurName(String name) {
    if (name.isEmpty) return 'Bilinmeyen';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      // Tek kelime ise sadece ilk harfi göster
      return '${words[0][0]}***';
    } else if (words.length == 2) {
      // İki kelime ise ilk harfleri göster
      return '${words[0][0]}*** ${words[1][0]}***';
    } else {
      // Birden fazla kelime ise ilk ve son kelimenin ilk harflerini göster
      return '${words[0][0]}*** ${words[words.length - 1][0]}***';
    }
  }

  static String blurEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return '***@***';
    
    final parts = email.split('@');
    if (parts.length != 2) return '***@***';
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '***@$domain';
    }
    
    final blurredUsername = '${username[0]}***${username[username.length - 1]}';
    return '$blurredUsername@$domain';
  }

  static String blurPhone(String phone) {
    if (phone.isEmpty) return '*** *** ** **';
    
    // Sadece rakamları al
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length < 4) return '*** *** ** **';
    
    // Son 4 haneyi göster, geri kalanını blur'la
    final visibleDigits = digits.substring(digits.length - 4);
    final blurredDigits = '*' * (digits.length - 4);
    
    return '$blurredDigits $visibleDigits';
  }
}
