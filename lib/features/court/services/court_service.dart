import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../models/court.dart';
import '../models/court_availability.dart';

class CourtService {
  Future<List<Court>> getCourts() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.courts}'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(AppConstants.requestTimeout);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        
        List<dynamic> courtsList;
        
        // Backend'den gelen veri formatını kontrol et
        if (responseBody is List) {
          // Direkt array olarak geliyorsa
          courtsList = responseBody;
        } else if (responseBody is Map<String, dynamic>) {
          // Object içinde array olarak geliyorsa
          courtsList = responseBody['courts'] as List<dynamic>? ?? [];
        } else {
          // Beklenmeyen format
          courtsList = [];
        }
        
        return courtsList.map((courtJson) {
          try {
            return Court.fromJson(courtJson as Map<String, dynamic>);
          } catch (e) {
            print('Court parsing error: $e for data: $courtJson');
            // Hatalı court'u atla ve devam et
            return null;
          }
        }).where((court) => court != null).cast<Court>().toList();
      } else {
        throw Exception('Kortlar yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Backend error: $e');
      // Backend hatası durumunda mock data döndür
      return _getMockCourts();
    }
  }

  Future<List<Court>> getAvailableCourts(DateTime date) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.courts}?date=${date.toIso8601String()}'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(AppConstants.requestTimeout);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        
        List<dynamic> courtsList;
        
        // Backend'den gelen veri formatını kontrol et
        if (responseBody is List) {
          // Direkt array olarak geliyorsa
          courtsList = responseBody;
        } else if (responseBody is Map<String, dynamic>) {
          // Object içinde array olarak geliyorsa
          courtsList = responseBody['courts'] as List<dynamic>? ?? [];
        } else {
          // Beklenmeyen format
          courtsList = [];
        }
        
        return courtsList.map((courtJson) {
          try {
            return Court.fromJson(courtJson as Map<String, dynamic>);
          } catch (e) {
            print('Available court parsing error: $e for data: $courtJson');
            // Hatalı court'u atla ve devam et
            return null;
          }
        }).where((court) => court != null).cast<Court>().toList();
      } else {
        throw Exception('Müsait kortlar yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Müsait kortlar yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getCourtReservedSlots(String courtId, DateTime date) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.courtAvailability}?courtId=$courtId&date=${date.toIso8601String()}'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(AppConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reservations = data['reservations'] as List<dynamic>? ?? [];
        
        return reservations.cast<Map<String, dynamic>>();
      } else {
        // Backend'den veri alınamazsa boş liste döndür
        return [];
      }
    } catch (e) {
      // Hata durumunda boş liste döndür
      print('Court reserved slots error: $e');
      return [];
    }
  }

  Future<Court?> getCourtById(String courtId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.courts}/$courtId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(AppConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Court.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Mock data - Backend çalışmadığında kullanılacak
  List<Court> _getMockCourts() {
    return [
      Court(
        id: '1',
        name: 'Kort 1',
        location: 'Ana Spor Salonu',
        surfaceType: SurfaceType.hard,
        isAvailable: true,
        amenities: ['Işık', 'Çatı'],
        status: 'available',
        rating: 4.5,
        capacity: 4,
        hourlyRate: 50.0,
      ),
      Court(
        id: '2',
        name: 'Kort 2',
        location: 'Ana Spor Salonu',
        surfaceType: SurfaceType.clay,
        isAvailable: true,
        amenities: ['Işık'],
        status: 'available',
        rating: 4.3,
        capacity: 4,
        hourlyRate: 45.0,
      ),
      Court(
        id: '3',
        name: 'Kort 3',
        location: 'Yan Spor Salonu',
        surfaceType: SurfaceType.hard,
        isAvailable: false,
        amenities: ['Çatı'],
        status: 'maintenance',
        rating: 4.0,
        capacity: 4,
        hourlyRate: 40.0,
      ),
      Court(
        id: '4',
        name: 'Kort 4',
        location: 'Yan Spor Salonu',
        surfaceType: SurfaceType.grass,
        isAvailable: true,
        amenities: ['Işık', 'Çatı', 'Duş'],
        status: 'available',
        rating: 4.8,
        capacity: 4,
        hourlyRate: 60.0,
      ),
    ];
  }
}
