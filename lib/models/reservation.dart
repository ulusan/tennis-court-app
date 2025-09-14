import 'court.dart';

enum ReservationStatus {
  confirmed,
  cancelled,
}

class Reservation {
  final String id;
  final String userId;
  final Court court;
  final DateTime startTime;
  final DateTime endTime;
  final ReservationStatus status;
  final DateTime createdAt;
  final String? notes;
  final String? cancellationReason;
  final DateTime? cancelledAt;

  String get courtName => court.name;
  String get location => court.location;
  String get courtLocation => court.location;
  DateTime get dateTime => startTime;
  Duration get duration => endTime.difference(startTime);
  int get durationInMinutes => endTime.difference(startTime).inMinutes;
  bool get isCancelled => status == ReservationStatus.cancelled;

  Reservation({
    required this.id,
    required this.userId,
    required this.court,
    required this.startTime,
    required this.endTime,
    this.status = ReservationStatus.confirmed,
    required this.createdAt,
    this.notes,
    this.cancellationReason,
    this.cancelledAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      court: Court.fromJson(json['court'] ?? {}),
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime']).toLocal()
          : DateTime.now().toLocal(),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime']).toLocal()
          : DateTime.now().toLocal().add(const Duration(hours: 1)),
      status: _parseReservationStatus(json['status']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now().toLocal(),
      notes: json['notes'],
      cancellationReason: json['cancellationReason'],
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'court': court.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'cancellationReason': cancellationReason,
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  int get durationInHours => duration.inHours;

  // Helper method to parse reservation status from backend
  static ReservationStatus _parseReservationStatus(dynamic status) {
    if (status == null) return ReservationStatus.confirmed;
    
    final statusString = status.toString().toLowerCase();
    switch (statusString) {
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.confirmed;
    }
  }
}
