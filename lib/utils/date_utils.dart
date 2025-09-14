import 'package:intl/intl.dart';

class AppDateUtils {
  /// Local timezone'da bugünün tarihini döndürür
  static DateTime getToday() {
    final now = DateTime.now();
    // Türkiye UTC+3 timezone'u için manuel hesaplama
    final turkeyOffset = const Duration(hours: 3);
    final turkeyTime = now.add(turkeyOffset);
    
    // Türkiye'deki bugünün başlangıcını al (saat 00:00:00)
    final localToday = DateTime(turkeyTime.year, turkeyTime.month, turkeyTime.day, 0, 0, 0);
    
    print('DEBUG - DateTime.now() (UTC): $now');
    print('DEBUG - Turkey time: $turkeyTime');
    print('DEBUG - Local today (Turkey): $localToday');
    print('DEBUG - Turkey date: ${turkeyTime.day}/${turkeyTime.month}/${turkeyTime.year}');
    return localToday;
  }

  /// Local timezone'da şu anki tarih ve saati döndürür
  static DateTime getNow() {
    final now = DateTime.now();
    // Türkiye UTC+3 timezone'u için manuel hesaplama
    final turkeyOffset = const Duration(hours: 3);
    return now.add(turkeyOffset);
  }

  /// Tarihi local timezone'da formatlar
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Tarihi Türkçe formatla (14 EYLÜL 2025 PAZAR)
  static String formatDateTurkish(DateTime date) {
    final months = [
      '', 'OCAK', 'ŞUBAT', 'MART', 'NİSAN', 'MAYIS', 'HAZİRAN',
      'TEMMUZ', 'AĞUSTOS', 'EYLÜL', 'EKİM', 'KASIM', 'ARALIK'
    ];
    
    final days = [
      'PAZAR', 'PAZARTESİ', 'SALI', 'ÇARŞAMBA', 
      'PERŞEMBE', 'CUMA', 'CUMARTESİ'
    ];
    
    final dayName = days[date.weekday % 7];
    final monthName = months[date.month];
    
    return '${date.day} $monthName ${date.year} $dayName';
  }

  /// Tarihi local timezone'da formatlar (gün/ay/yıl)
  static String formatDateShort(DateTime date) {
    return DateFormat('d/M/yyyy').format(date);
  }

  /// Saati local timezone'da formatlar
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Tarih ve saati local timezone'da formatlar
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// İki tarihin aynı gün olup olmadığını kontrol eder
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Tarihin bugün olup olmadığını kontrol eder
  static bool isToday(DateTime date) {
    return isSameDay(date, getToday());
  }

  /// Tarihin gelecekte olup olmadığını kontrol eder
  static bool isFuture(DateTime date) {
    return date.isAfter(getToday());
  }

  /// Tarihin geçmişte olup olmadığını kontrol eder
  static bool isPast(DateTime date) {
    return date.isBefore(getToday());
  }

  /// Debug için tarih bilgilerini yazdırır
  static void debugDate(DateTime date, String label) {
    print('DEBUG - $label: $date');
    print('DEBUG - $label formatted: ${formatDate(date)}');
    print('DEBUG - $label timezone offset: ${date.timeZoneOffset}');
    print('DEBUG - $label is today: ${isToday(date)}');
  }
}
