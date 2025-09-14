import 'package:flutter/foundation.dart';
import '../models/reservation.dart';
import '../models/court.dart';
import '../services/reservation_service.dart';

class ReservationProvider with ChangeNotifier {
  final ReservationService _reservationService = ReservationService();
  
  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _error;

  List<Reservation> get reservations => _reservations;
  List<Reservation> get userReservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserReservations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _reservationService.getUserReservations(userId);
    } catch (e) {
      _error = e.toString();
      _reservations = []; // Hata durumunda boş liste
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For now, we'll use empty list since we don't have a general reservations endpoint
      _reservations = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReservation({
    required String userId,
    required String courtId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get court from court provider or create a minimal court object
      final court = Court(
        id: courtId,
        name: 'Court $courtId', // This should be fetched from court service
        location: '',
        surfaceType: SurfaceType.hard,
        isAvailable: true,
        hourlyRate: 0.0,
      );
      
      final reservation = await _reservationService.createReservation(
        userId: userId,
        court: court,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );
      
      _reservations.add(reservation);
      notifyListeners();
      return true;
    } catch (e) {
      // Extract error message from ApiException
      String errorMessage = 'Rezervasyon oluşturulurken hata oluştu';
      if (e.toString().contains('ApiException:')) {
        // Extract message from ApiException
        final match = RegExp(r'ApiException: (.+) \(Status: \d+\)').firstMatch(e.toString());
        if (match != null) {
          errorMessage = match.group(1) ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }
      
      _error = errorMessage;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> cancelReservation(String reservationId, {String? cancellationReason}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Backend'e iptal isteği gönder
      final cancelledReservation = await _reservationService.cancelReservation(
        reservationId,
        cancellationReason: cancellationReason,
      );
      
      // Local listeyi güncelle
      final reservationIndex = _reservations.indexWhere((r) => r.id == reservationId);
      if (reservationIndex != -1) {
        _reservations[reservationIndex] = cancelledReservation;
      } else {
        // Eğer local'de yoksa ekle
        _reservations.add(cancelledReservation);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      // Extract error message from ApiException
      String errorMessage = 'Rezervasyon iptal edilirken hata oluştu';
      if (e.toString().contains('ApiException:')) {
        // Extract message from ApiException
        final match = RegExp(r'ApiException: (.+) \(Status: \d+\)').firstMatch(e.toString());
        if (match != null) {
          errorMessage = match.group(1) ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }
      
      _error = errorMessage;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Rezervasyon iptal edildiğinde availability'yi yeniden yükle
  void refreshAvailabilityAfterCancellation(String courtId, DateTime date) {
    // Bu metod AvailabilityProvider'da çağrılacak
    // AvailabilityProvider'ın loadCourtAvailability metodunu tetikler
  }
}
