import 'package:intl/intl.dart';

class AppDateUtils {
  static DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatDateWithDay(DateTime date) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return '${days[date.weekday - 1]}, ${formatDate(date)}';
  }

  static bool isToday(DateTime date) {
    final today = getToday();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = getToday().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = getToday().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  static String getRelativeDate(DateTime date) {
    if (isToday(date)) {
      return 'Bugün';
    } else if (isTomorrow(date)) {
      return 'Yarın';
    } else if (isYesterday(date)) {
      return 'Dün';
    } else {
      return formatDate(date);
    }
  }

  static List<DateTime> getNext7Days() {
    final today = getToday();
    return List.generate(7, (index) => today.add(Duration(days: index)));
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}
