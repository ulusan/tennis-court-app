import 'package:flutter/material.dart';
import 'court.dart';

enum AvailabilityStatus {
  available,
  reserved,
  maintenance,
  closed,
}

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final AvailabilityStatus status;
  final String? reservedBy;
  final String? notes;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.status,
    this.reservedBy,
    this.notes,
  });

  bool get isAvailable => status == AvailabilityStatus.available;
  bool get isReserved => status == AvailabilityStatus.reserved;
  bool get isMaintenance => status == AvailabilityStatus.maintenance;
  bool get isClosed => status == AvailabilityStatus.closed;

  String get statusText {
    switch (status) {
      case AvailabilityStatus.available:
        return 'Müsait';
      case AvailabilityStatus.reserved:
        return 'Rezerve';
      case AvailabilityStatus.maintenance:
        return 'Bakım';
      case AvailabilityStatus.closed:
        return 'Kapalı';
    }
  }

  String get statusColor {
    switch (status) {
      case AvailabilityStatus.available:
        return '#4CAF50'; // Green
      case AvailabilityStatus.reserved:
        return '#F44336'; // Red
      case AvailabilityStatus.maintenance:
        return '#FF9800'; // Orange
      case AvailabilityStatus.closed:
        return '#9E9E9E'; // Grey
    }
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
      status: AvailabilityStatus.values.firstWhere(
        (e) => e.toString() == 'AvailabilityStatus.${json['status']}',
        orElse: () => AvailabilityStatus.available,
      ),
      reservedBy: json['reservedBy'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'status': status.toString().split('.').last,
      'reservedBy': reservedBy,
      'notes': notes,
    };
  }
}

class CourtAvailability {
  final String courtId;
  final String courtName;
  final DateTime date;
  final List<TimeSlot> timeSlots;
  final bool isAvailable;

  CourtAvailability({
    required this.courtId,
    required this.courtName,
    required this.date,
    required this.timeSlots,
    required this.isAvailable,
  });

  List<TimeSlot> get availableSlots => 
      timeSlots.where((slot) => slot.isAvailable).toList();
  
  List<TimeSlot> get reservedSlots => 
      timeSlots.where((slot) => slot.isReserved).toList();

  factory CourtAvailability.fromJson(Map<String, dynamic> json) {
    return CourtAvailability(
      courtId: json['courtId'],
      courtName: json['courtName'],
      date: DateTime.parse(json['date']),
      timeSlots: (json['timeSlots'] as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
      isAvailable: json['isAvailable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courtId': courtId,
      'courtName': courtName,
      'date': date.toIso8601String(),
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
      'isAvailable': isAvailable,
    };
  }
}
