import 'package:flutter/material.dart';
import 'date_utils.dart';

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String displayText;
  final bool isAvailable;
  final String? notes;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.displayText,
    this.isAvailable = true,
    this.notes,
  });

  // Zaman slot'unu DateTime'a çevir (belirli bir tarih için)
  DateTime getStartDateTime(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
  }

  DateTime getEndDateTime(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );
  }

  // Slot süresini dakika cinsinden döndür
  int get durationInMinutes => 90; // 1.5 saat = 90 dakika

  // Slot süresini saat cinsinden döndür
  double get durationInHours => 1.5;

  @override
  String toString() => displayText;
}

class TimeSlotGenerator {
  // Saat 08:00'dan 23:00'a kadar 1.5 saatlik slotlar oluştur
  static List<TimeSlot> generateTimeSlots() {
    final List<TimeSlot> slots = [];
    
    // Sabah 08:00'dan akşam 23:00'a kadar (1.5 saatlik slotlar)
    for (int hour = 8; hour < 23; hour++) {
      final startTime = TimeOfDay(hour: hour, minute: 0);
      final endTime = TimeOfDay(hour: hour + 1, minute: 30);
      
      slots.add(TimeSlot(
        startTime: startTime,
        endTime: endTime,
        displayText: _formatTimeSlot(startTime, endTime),
      ));
    }
    
    return slots;
  }

  // Başlangıç zamanından 1.5 saat sonrasını hesapla (artık kullanılmıyor ama eski kod için bırakıyoruz)
  static TimeOfDay _calculateEndTime(TimeOfDay startTime) {
    int totalMinutes = startTime.hour * 60 + startTime.minute + 90; // 1.5 saat = 90 dakika
    
    int endHour = totalMinutes ~/ 60;
    int endMinute = totalMinutes % 60;
    
    // 24 saat formatında tutmak için
    if (endHour >= 24) {
      endHour = endHour % 24;
    }
    
    return TimeOfDay(hour: endHour, minute: endMinute);
  }

  // Zaman slot'unu güzel formatta göster
  static String _formatTimeSlot(TimeOfDay startTime, TimeOfDay endTime) {
    final startStr = _formatTimeOfDay(startTime);
    final endStr = _formatTimeOfDay(endTime);
    
    // Saat aralığına göre etiket
    if (startTime.hour < 12) {
      return '$startStr - $endStr (Sabah)';
    } else if (startTime.hour < 18) {
      return '$startStr - $endStr (Öğleden Sonra)';
    } else {
      return '$startStr - $endStr (Akşam)';
    }
  }

  // TimeOfDay'ı string'e çevir
  static String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Belirli bir tarih için mevcut slotları filtrele
  static List<TimeSlot> getAvailableSlotsForDate(DateTime date) {
    final allSlots = generateTimeSlots();
    final now = AppDateUtils.getNow();
    
    // Eğer seçilen tarih bugünse, geçmiş saatleri filtrele
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return allSlots.where((slot) {
        final slotDateTime = slot.getStartDateTime(date);
        return slotDateTime.isAfter(now);
      }).toList();
    }
    
    return allSlots;
  }

  // Slot'u seçilen tarih ve saat ile birleştir
  static Map<String, dynamic> createReservationData({
    required TimeSlot selectedSlot,
    required DateTime selectedDate,
    required String courtId,
    String? notes,
  }) {
    final startDateTime = selectedSlot.getStartDateTime(selectedDate);
    final endDateTime = selectedSlot.getEndDateTime(selectedDate);
    
    return {
      'courtId': courtId,
      'startTime': startDateTime.toIso8601String(),
      'endTime': endDateTime.toIso8601String(),
      'notes': notes,
      'duration': selectedSlot.durationInMinutes,
    };
  }
}
