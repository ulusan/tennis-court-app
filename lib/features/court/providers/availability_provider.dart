import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/court_availability.dart';
import '../services/court_service.dart';
import '../../../core/utils/name_blur.dart';

class AvailabilityProvider with ChangeNotifier {
  final CourtService _courtService = CourtService();

  CourtAvailability? _currentAvailability;
  List<Map<String, dynamic>> _reservedSlots = [];
  bool _isLoading = false;
  String? _error;

  CourtAvailability? get currentAvailability => _currentAvailability;
  List<Map<String, dynamic>> get reservedSlots => _reservedSlots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCourtAvailability(String courtId, DateTime date) async {
    // Input validation
    if (courtId.isEmpty) {
      _error = 'Geçersiz kort ID';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Backend'den sadece rezerve edilmiş saatleri al
      _reservedSlots = await _courtService.getCourtReservedSlots(courtId, date);
      
      // Backend verilerini doğrula
      _reservedSlots = _validateAndCleanReservedSlots(_reservedSlots);
      
      // Tüm saatleri açık olarak oluştur (TimeSlotGenerator ile)
      _currentAvailability = _createAvailabilityWithAllSlotsOpen(courtId, date);
    } catch (e) {
      // Hata durumunda boş availability oluştur
      _reservedSlots = [];
      _currentAvailability = _createEmptyAvailability(courtId, date);
      _error = 'Kort müsaitlik bilgileri yüklenirken hata oluştu: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Backend'den gelen rezervasyon verilerini doğrula ve temizle
  List<Map<String, dynamic>> _validateAndCleanReservedSlots(List<Map<String, dynamic>> reservedSlots) {
    final cleanSlots = <Map<String, dynamic>>[];
    
    for (final slot in reservedSlots) {
      try {
        // Her slot'u doğrula
        if (_validateReservationData(slot)) {
          cleanSlots.add(slot);
        }
      } catch (e) {
        // Geçersiz slot'u atla
        continue;
      }
    }
    
    return cleanSlots;
  }

  // Tüm saatleri açık olarak oluştur ve rezerve edilmiş saatleri kapat
  CourtAvailability _createAvailabilityWithAllSlotsOpen(
    String courtId,
    DateTime date,
  ) {
    // TimeSlotGenerator'dan tüm saatleri al
    final allTimeSlots = _generateAllTimeSlots();

    // Rezerve edilmiş saatleri kapat - GÜÇLENDİRİLMİŞ VERSİYON
    final timeSlots = allTimeSlots.map((slot) {
      final isReserved = _isSlotReserved(slot, _reservedSlots);
      return TimeSlot(
        startTime: slot.startTime,
        endTime: slot.endTime,
        status: isReserved
            ? AvailabilityStatus.reserved
            : AvailabilityStatus.available,
        reservedBy: isReserved ? _getReservedBy(slot, _reservedSlots) : null,
        notes: isReserved ? _getReservedNotes(slot, _reservedSlots) : null,
      );
    }).toList();

    return CourtAvailability(
      courtId: courtId,
      courtName: 'Kort $courtId', // Bu bilgi court service'den alınabilir
      date: date,
      isAvailable: timeSlots.any((slot) => slot.isAvailable),
      timeSlots: timeSlots,
    );
  }

  // Tüm saatleri oluştur (08:00'dan başlayarak 1.5 saatlik slotlar)
  List<TimeSlot> _generateAllTimeSlots() {
    final slots = <TimeSlot>[];
    
    // 08:00'dan başlayıp 00:30'a kadar 1.5 saatlik aralıklarla ilerle
    final startMinutes = 8 * 60; // 08:00 = 480 dakika
    final endMinutes = 24 * 60 + 30;  // 00:30'a kadar (gece yarısını geçer)
    const slotDuration = 90; // 1.5 saat = 90 dakika

    for (int minutes = startMinutes; minutes < endMinutes; minutes += slotDuration) {
      final startHour = minutes ~/ 60;
      final startMinute = minutes % 60;
      final endMinutesTotal = minutes + slotDuration;
      final endHour = endMinutesTotal ~/ 60;
      final endMinute = endMinutesTotal % 60;

      // Gece yarısını geçen saatler için 00:00 kullan (24:00 yerine)
      final adjustedEndHour = endHour >= 24 ? 0 : endHour;

      final startTime = TimeOfDay(hour: startHour, minute: startMinute);
      final endTime = TimeOfDay(hour: adjustedEndHour, minute: endMinute);

      slots.add(
        TimeSlot(
          startTime: startTime,
          endTime: endTime,
          status: AvailabilityStatus.available,
        ),
      );
    }

    return slots;
  }

  // Bir slot'un rezerve edilip edilmediğini kontrol et - GÜÇLENDİRİLMİŞ VERSİYON
  bool _isSlotReserved(
    TimeSlot slot,
    List<Map<String, dynamic>> reservedSlots,
  ) {
    // Input validation
    if (reservedSlots.isEmpty) {
      return false;
    }

    for (final reserved in reservedSlots) {
      try {
        // Güvenli veri doğrulama
        if (!_validateReservationData(reserved)) {
          continue; // Geçersiz veri varsa atla
        }
        
        // Status kontrolü - güçlendirilmiş versiyon
        final statusString = _parseReservationStatus(reserved);
        if (statusString != 'confirmed') {
          continue;
        }

        // Tarih kontrolü - rezervasyon bugün mü?
        if (!_isReservationForToday(reserved)) {
          continue;
        }

        // Zaman parsing - güvenli versiyon
        final reservedStart = _parseTimeStringSafe(reserved['startTime']);
        final reservedEnd = _parseTimeStringSafe(reserved['endTime']);

        if (reservedStart == null || reservedEnd == null) {
          continue; // Zaman parse edilemezse atla
        }

        // Çakışma kontrolü - güçlendirilmiş versiyon
        if (_hasTimeConflict(slot, reservedStart, reservedEnd)) {
          return true;
        }
      } catch (e) {
        // Hata durumunda log et ve devam et
        print('ERROR - Reservation validation error: $e');
        continue;
      }
    }
    return false;
  }

  // Rezervasyon verilerinin geçerliliğini kontrol et
  bool _validateReservationData(Map<String, dynamic> reserved) {
    // Gerekli alanları kontrol et
    if (!reserved.containsKey('startTime') || !reserved.containsKey('endTime')) {
      return false;
    }
    
    // startTime ve endTime null olmamalı
    if (reserved['startTime'] == null || reserved['endTime'] == null) {
      return false;
    }
    
    // String olmalı
    if (reserved['startTime'] is! String || reserved['endTime'] is! String) {
      return false;
    }
    
    return true;
  }

  // Rezervasyon status'unu güvenli şekilde parse et
  String _parseReservationStatus(Map<String, dynamic> reserved) {
    final status = reserved['status'];
    
    if (status == null) {
      // Status null ise, rezervasyonu aktif kabul et (backend'de default confirmed olabilir)
      return 'confirmed';
    } else if (status is String) {
      return status.toLowerCase().trim();
    } else if (status is Map && status.containsKey('name')) {
      // Status object olarak geliyorsa
      return status['name']?.toString().toLowerCase().trim() ?? 'unknown';
    } else {
      return status.toString().toLowerCase().trim();
    }
  }

  // Rezervasyonun bugün için olup olmadığını kontrol et
  bool _isReservationForToday(Map<String, dynamic> reserved) {
    try {
      final startTimeStr = reserved['startTime'] as String;
      final dateTime = DateTime.parse(startTimeStr);
      final today = DateTime.now();
      
      return dateTime.year == today.year &&
             dateTime.month == today.month &&
             dateTime.day == today.day;
    } catch (e) {
      return false;
    }
  }

  // Güvenli zaman parsing
  TimeOfDay? _parseTimeStringSafe(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return null;
    }

    try {
      DateTime dateTime;
      
      // Farklı formatları handle et
      if (timeString.contains('T')) {
        // ISO 8601 format: "2024-01-15T10:00:00.000Z"
        dateTime = DateTime.parse(timeString);
      } else if (timeString.contains(' ')) {
        // PostgreSQL timestamp format: "2025-09-14 23:00:00"
        dateTime = DateTime.parse(timeString);
      } else {
        // Diğer formatlar
        dateTime = DateTime.parse(timeString);
      }
      
      // Saat ve dakika geçerliliğini kontrol et
      if (dateTime.hour < 0 || dateTime.hour > 23 || 
          dateTime.minute < 0 || dateTime.minute > 59) {
        return null;
      }
      
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      return null;
    }
  }

  // Çakışma kontrolü - güçlendirilmiş versiyon
  bool _hasTimeConflict(TimeSlot slot, TimeOfDay reservedStart, TimeOfDay reservedEnd) {
    final slotStart = _timeOfDayToMinutes(slot.startTime);
    final slotEnd = _timeOfDayToMinutes(slot.endTime);
    final reservedStartMinutes = _timeOfDayToMinutes(reservedStart);
    final reservedEndMinutes = _timeOfDayToMinutes(reservedEnd);

    // Gece yarısını geçen rezervasyon kontrolü
    if (reservedEndMinutes < reservedStartMinutes) {
      // Rezervasyon gece yarısını geçiyor (örn: 23:00-00:30)
      // Slot rezervasyonun başlangıcından sonra başlıyor mu? (23:00'dan sonra)
      // VEYA slot rezervasyonun bitişinden önce bitiyor mu? (00:30'dan önce)
      return slotStart >= reservedStartMinutes || slotEnd <= reservedEndMinutes;
    } else {
      // Normal rezervasyon (aynı gün içinde)
      return slotStart < reservedEndMinutes && slotEnd > reservedStartMinutes;
    }
  }

  // Rezerve eden kişiyi getir (blur'lanmış isim) - GÜÇLENDİRİLMİŞ VERSİYON
  String? _getReservedBy(
    TimeSlot slot,
    List<Map<String, dynamic>> reservedSlots,
  ) {
    for (final reserved in reservedSlots) {
      try {
        // Güvenli veri doğrulama
        if (!_validateReservationData(reserved)) {
          continue;
        }
        
        // Status kontrolü
        final statusString = _parseReservationStatus(reserved);
        if (statusString != 'confirmed') {
          continue;
        }

        // Tarih kontrolü
        if (!_isReservationForToday(reserved)) {
          continue;
        }

        // Zaman parsing
        final reservedStart = _parseTimeStringSafe(reserved['startTime']);
        final reservedEnd = _parseTimeStringSafe(reserved['endTime']);

        if (reservedStart == null || reservedEnd == null) {
          continue;
        }

        // Çakışma kontrolü
        if (_hasTimeConflict(slot, reservedStart, reservedEnd)) {
          final userName = reserved['userName']?.toString() ?? 
                          reserved['userId']?.toString() ?? 
                          'Bilinmeyen';
          return NameBlur.blurName(userName);
        }
      } catch (e) {
        continue; // Hata durumunda atla
      }
    }
    return null;
  }

  // Rezerve notlarını getir - GÜÇLENDİRİLMİŞ VERSİYON
  String? _getReservedNotes(
    TimeSlot slot,
    List<Map<String, dynamic>> reservedSlots,
  ) {
    for (final reserved in reservedSlots) {
      try {
        // Güvenli veri doğrulama
        if (!_validateReservationData(reserved)) {
          continue;
        }
        
        // Status kontrolü
        final statusString = _parseReservationStatus(reserved);
        if (statusString != 'confirmed') {
          continue;
        }

        // Tarih kontrolü
        if (!_isReservationForToday(reserved)) {
          continue;
        }

        // Zaman parsing
        final reservedStart = _parseTimeStringSafe(reserved['startTime']);
        final reservedEnd = _parseTimeStringSafe(reserved['endTime']);

        if (reservedStart == null || reservedEnd == null) {
          continue;
        }

        // Çakışma kontrolü
        if (_hasTimeConflict(slot, reservedStart, reservedEnd)) {
          return reserved['notes']?.toString();
        }
      } catch (e) {
        continue; // Hata durumunda atla
      }
    }
    return null;
  }

  // TimeOfDay'ı dakikaya çevir
  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  CourtAvailability _createEmptyAvailability(String courtId, DateTime date) {
    // Create empty availability when backend is unavailable
    return CourtAvailability(
      courtId: courtId,
      courtName: 'Kort $courtId',
      date: date,
      isAvailable: false,
      timeSlots: [],
    );
  }

  void clearAvailability() {
    _currentAvailability = null;
    _error = null;
    notifyListeners();
  }

  // Rezervasyon iptal edildiğinde availability'yi yeniden yükle
  Future<void> refreshAfterCancellation(String courtId, DateTime date) async {
    if (_currentAvailability != null && 
        _currentAvailability!.courtId == courtId &&
        _currentAvailability!.date.year == date.year &&
        _currentAvailability!.date.month == date.month &&
        _currentAvailability!.date.day == date.day) {
      // Aynı kort ve tarih için availability'yi yeniden yükle
      await loadCourtAvailability(courtId, date);
    }
  }

  List<TimeSlot> getAvailableSlots() {
    if (_currentAvailability == null) return [];
    return _currentAvailability!.availableSlots;
  }

  List<TimeSlot> getReservedSlots() {
    if (_currentAvailability == null) return [];
    return _currentAvailability!.reservedSlots;
  }

  int getAvailableSlotsCount() {
    return getAvailableSlots().length;
  }

  int getReservedSlotsCount() {
    return getReservedSlots().length;
  }

  double getAvailabilityPercentage() {
    if (_currentAvailability == null ||
        _currentAvailability!.timeSlots.isEmpty) {
      return 0.0;
    }

    final totalSlots = _currentAvailability!.timeSlots.length;
    final availableSlots = getAvailableSlots().length;

    return (availableSlots / totalSlots) * 100;
  }
}
