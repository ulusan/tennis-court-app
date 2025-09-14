import 'package:flutter/foundation.dart';
import '../models/court.dart';
import '../services/court_service.dart';

class CourtProvider with ChangeNotifier {
  final CourtService _courtService = CourtService();

  List<Court> _courts = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  List<Court> get courts => _courts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadCourts() async {
    if (_disposed) return;
    
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      if (!_disposed) {
        _courts = await _courtService.getCourts();
      }
    } catch (e) {
      if (!_disposed) {
        _error = e.toString();
      }
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> loadAvailableCourts(DateTime date) async {
    if (_disposed) return;
    
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      if (!_disposed) {
        _courts = await _courtService.getAvailableCourts(date);
      }
    } catch (e) {
      if (!_disposed) {
        _error = e.toString();
      }
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Court? getCourtById(String id) {
    try {
      return _courts.firstWhere((court) => court.id == id);
    } catch (e) {
      return null;
    }
  }
}
