import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../models/reservation.dart';
import '../../court/models/court.dart';
import '../../auth/services/auth_service.dart';

class ReservationService {
  final AuthService _authService = AuthService();

  Future<List<Reservation>> getUserReservations(String userId) async {
    try {
      final token = await _authService.getToken();
      
      print('ReservationService: Getting user reservations...');
      print('ReservationService: User ID: $userId');
      
      // Önce basit /reservations endpoint'ini deneyelim
      final url = '${AppConfig.baseUrl}${AppConfig.reservations}';
      print('ReservationService: URL: $url');
      print('ReservationService: Token: ${token?.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.requestTimeout);

      print('ReservationService: Response status code: ${response.statusCode}');
      print('ReservationService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> reservationsList = [];
        
        // Response array ise direkt kullan, object ise içindeki array'i al
        if (data is List) {
          reservationsList = data;
        } else if (data is Map<String, dynamic>) {
          reservationsList = data['reservations'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
        }
        
        print('ReservationService: Found ${reservationsList.length} reservations');
        
        // User ID'ye göre filtrele (backend'de filtreleme yoksa)
        final userReservations = reservationsList.where((reservationJson) {
          final reservation = reservationJson as Map<String, dynamic>;
          return reservation['userId'] == userId || 
                 (reservation['user'] != null && reservation['user']['id'] == userId);
        }).toList();
        
        print('ReservationService: Found ${userReservations.length} reservations for user');
        
        return userReservations.map((reservationJson) => Reservation.fromJson(reservationJson)).toList();
      } else {
        throw Exception('Rezervasyonlar yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('ReservationService: Error getting reservations: $e');
      throw Exception('Rezervasyonlar yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  Future<Reservation> createReservation({
    required String userId, // Bu parametre artık kullanılmıyor ama interface uyumluluğu için bırakıyoruz
    required Court court,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      }

      final requestBody = {
        // userId'yi kaldırdık, backend token'dan alacak
        'courtId': court.id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'notes': notes,
      };

      print('ReservationService: Creating reservation...');
      print('ReservationService: URL: ${AppConfig.baseUrl}${AppConfig.reservations}');
      print('ReservationService: Request body: ${jsonEncode(requestBody)}');
      print('ReservationService: Token: ${token.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.reservations}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      ).timeout(AppConstants.requestTimeout);

      print('ReservationService: Response status code: ${response.statusCode}');
      print('ReservationService: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Reservation.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['message'] ?? 'Rezervasyon oluşturulamadı');
      }
    } catch (e) {
      throw Exception('Rezervasyon oluşturulurken hata oluştu: ${e.toString()}');
    }
  }

  Future<Reservation> cancelReservation(String reservationId, {String? cancellationReason}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      }

      print('ReservationService: Cancelling reservation...');
      print('ReservationService: Reservation ID: $reservationId');
      print('ReservationService: Cancellation reason: $cancellationReason');
      print('ReservationService: URL: ${AppConfig.baseUrl}${AppConfig.reservations}/$reservationId/cancel');
      print('ReservationService: Token: ${token.substring(0, 20)}...');

      final response = await http.patch(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.reservations}/$reservationId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'cancellationReason': cancellationReason,
        }),
      ).timeout(AppConstants.requestTimeout);

      print('ReservationService: Cancel response status code: ${response.statusCode}');
      print('ReservationService: Cancel response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('ReservationService: Reservation cancelled successfully');
        return Reservation.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        print('ReservationService: Cancel error: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Rezervasyon iptal edilemedi');
      }
    } catch (e) {
      print('ReservationService: Cancel exception: $e');
      throw Exception('Rezervasyon iptal edilirken hata oluştu: ${e.toString()}');
    }
  }

  Future<Reservation?> getReservationById(String reservationId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.reservations}/$reservationId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Reservation.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Belirli bir kort ve saat aralığı için rezervasyon durumunu kontrol eder
  Future<bool> isTimeSlotAvailable({
    required String courtId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      }

      print('ReservationService: Checking time slot availability...');
      print('ReservationService: Court ID: $courtId');
      print('ReservationService: Start Time: ${startTime.toIso8601String()}');
      print('ReservationService: End Time: ${endTime.toIso8601String()}');

      // Mevcut /reservations endpoint'ini kullan
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.reservations}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.requestTimeout);

      print('ReservationService: Availability response status: ${response.statusCode}');
      print('ReservationService: Availability response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> reservations = [];
        
        // Response array ise direkt kullan, object ise içindeki array'i al
        if (data is List) {
          reservations = data;
        } else if (data is Map<String, dynamic>) {
          reservations = data['reservations'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
        }
        
        print('ReservationService: Found ${reservations.length} total reservations');
        
        // Aynı kort için çakışan rezervasyonları kontrol et
        for (final reservationJson in reservations) {
          try {
            final reservation = Reservation.fromJson(reservationJson);
            
            // Aynı kort ve aktif rezervasyon mu?
            if (reservation.court.id == courtId && 
                reservation.status.toString().split('.').last == 'confirmed' &&
                _isTimeOverlapping(
                  startTime, endTime,
                  reservation.startTime, reservation.endTime
                )) {
              print('ReservationService: Time slot is NOT available - conflict found');
              return false;
            }
          } catch (e) {
            print('ReservationService: Error parsing reservation: $e');
            continue; // Bu rezervasyonu atla ve devam et
          }
        }
        
        print('ReservationService: Time slot is available');
        return true;
      } else {
        print('ReservationService: Error checking availability: ${response.statusCode}');
        // Hata durumunda müsait olarak işaretle (güvenli taraf)
        return true;
      }
    } catch (e) {
      print('ReservationService: Error checking time slot availability: $e');
      // Hata durumunda müsait olarak işaretle (güvenli taraf)
      return true;
    }
  }

  /// İki saat aralığının çakışıp çakışmadığını kontrol eder
  bool _isTimeOverlapping(
    DateTime start1, DateTime end1,
    DateTime start2, DateTime end2,
  ) {
    // Çakışma kontrolü: (start1 < end2) && (start2 < end1)
    return start1.isBefore(end2) && start2.isBefore(end1);
  }

  /// Belirli bir kort için tüm rezervasyonları getirir (saat aralığı kontrolü için)
  Future<List<Reservation>> getCourtReservations(String courtId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      }

      print('ReservationService: Getting court reservations...');
      print('ReservationService: Court ID: $courtId');

      // Mevcut /reservations endpoint'ini kullan
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.reservations}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.requestTimeout);

      print('ReservationService: Court reservations response status: ${response.statusCode}');
      print('ReservationService: Court reservations response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> reservationsList = [];
        
        // Response array ise direkt kullan, object ise içindeki array'i al
        if (data is List) {
          reservationsList = data;
        } else if (data is Map<String, dynamic>) {
          reservationsList = data['reservations'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
        }
        
        // Court ID'ye göre filtrele
        final courtReservations = reservationsList.where((reservationJson) {
          try {
            final reservation = reservationJson as Map<String, dynamic>;
            return reservation['courtId'] == courtId || 
                   (reservation['court'] != null && reservation['court']['id'] == courtId);
          } catch (e) {
            return false;
          }
        }).toList();
        
        print('ReservationService: Found ${courtReservations.length} court reservations');
        
        return courtReservations.map((reservationJson) => Reservation.fromJson(reservationJson)).toList();
      } else {
        throw Exception('Kort rezervasyonları yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('ReservationService: Error getting court reservations: $e');
      throw Exception('Kort rezervasyonları yüklenirken hata oluştu: ${e.toString()}');
    }
  }
}
