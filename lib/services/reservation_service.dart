import '../models/reservation.dart';
import '../models/court.dart';
import '../config/app_config.dart';
import 'api_service.dart';

class ReservationService {
  final ApiService _apiService = ApiService();

  Future<Reservation> createReservation({
    required String userId,
    required Court court,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        AppConfig.reservations,
        body: {
          'courtId': court.id,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'notes': notes,
        },
      );

      final responseData = _apiService.handleResponse(response);
      return Reservation.fromJson(responseData);
    } catch (e) {
      throw Exception('Error creating reservation: $e');
    }
  }

  Future<List<Reservation>> getUserReservations(String userId) async {
    try {
      // Backend'deki /reservations endpoint'ini kullan (JWT token'dan user ID alınıyor)
      final response = await _apiService.get(
        AppConfig.reservations,
      );
      final responseData = _apiService.handleResponse(response);

      // Handle different response formats
      List<dynamic> reservationsList;
      if (responseData is List) {
        reservationsList = responseData as List<dynamic>;
      } else if (responseData is Map && responseData.containsKey('data') && responseData['data'] is List) {
        reservationsList = responseData['data'] as List<dynamic>;
      } else if (responseData is Map && responseData.containsKey('reservations') && responseData['reservations'] is List) {
        reservationsList = responseData['reservations'] as List<dynamic>;
      } else {
        throw Exception('Unexpected response format: $responseData');
      }

      return reservationsList.map((json) => Reservation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching reservations: $e');
    }
  }

  Future<Reservation> updateReservationStatus(
    String reservationId,
    String status,
  ) async {
    try {
      final response = await _apiService.put(
        '${AppConfig.reservations}/$reservationId',
        body: {'status': status},
      );

      final responseData = _apiService.handleResponse(response);
      return Reservation.fromJson(responseData);
    } catch (e) {
      throw Exception('Error updating reservation: $e');
    }
  }

  Future<Reservation> cancelReservation(String reservationId, {String? cancellationReason}) async {
    try {
      final response = await _apiService.patch(
        '${AppConfig.reservations}/$reservationId/cancel',
        body: {
          'cancellationReason': cancellationReason,
        },
      );

      final responseData = _apiService.handleResponse(response);
      return Reservation.fromJson(responseData);
    } catch (e) {
      throw Exception('Error canceling reservation: $e');
    }
  }
}