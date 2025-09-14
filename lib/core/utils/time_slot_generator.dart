import 'package:flutter/material.dart';

class TimeSlotGenerator {
  static List<TimeOfDay> generateTimeSlots({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int slotDurationMinutes,
  }) {
    final List<TimeOfDay> timeSlots = [];
    
    int currentHour = startTime.hour;
    int currentMinute = startTime.minute;
    
    while (true) {
      final currentTime = TimeOfDay(hour: currentHour, minute: currentMinute);
      
      // Eğer mevcut zaman bitiş zamanından büyük veya eşitse döngüyü sonlandır
      if (currentTime.hour > endTime.hour || 
          (currentTime.hour == endTime.hour && currentTime.minute >= endTime.minute)) {
        break;
      }
      
      timeSlots.add(currentTime);
      
      // Sonraki slot için dakikaları ekle
      currentMinute += slotDurationMinutes;
      
      // Saat taşması durumunda
      if (currentMinute >= 60) {
        currentHour += currentMinute ~/ 60;
        currentMinute = currentMinute % 60;
      }
    }
    
    return timeSlots;
  }
  
  static String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  static TimeOfDay parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
  
  static bool isTimeSlotAvailable(
    TimeOfDay timeSlot,
    List<TimeOfDay> unavailableSlots,
  ) {
    return !unavailableSlots.any((unavailable) => 
      unavailable.hour == timeSlot.hour && unavailable.minute == timeSlot.minute
    );
  }
  
  static List<TimeOfDay> getAvailableTimeSlots({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int slotDurationMinutes,
    required List<TimeOfDay> unavailableSlots,
  }) {
    final allSlots = generateTimeSlots(
      startTime: startTime,
      endTime: endTime,
      slotDurationMinutes: slotDurationMinutes,
    );
    
    return allSlots.where((slot) => isTimeSlotAvailable(slot, unavailableSlots)).toList();
  }
}
