import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static const String _tokenKey = 'auth_token';

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Store token
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(String endpoint, {bool includeAuth = true}) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    
    return http.get(url, headers: headers);
  }

  // POST request
  Future<http.Response> post(String endpoint, {Object? body, bool includeAuth = true}) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    
    return http.post(
      url,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  // PUT request
  Future<http.Response> put(String endpoint, {Object? body, bool includeAuth = true}) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    
    print('PUT Request to: $url');
    print('Headers: $headers');
    print('Body: ${body != null ? json.encode(body) : null}');
    
    final response = await http.put(
      url,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    
    print('PUT Response status: ${response.statusCode}');
    print('PUT Response body: ${response.body}');
    
    return response;
  }

  // PATCH request
  Future<http.Response> patch(String endpoint, {Object? body, bool includeAuth = true}) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    
    print('PATCH Request to: $url');
    print('Headers: $headers');
    print('Body: ${body != null ? json.encode(body) : null}');
    
    final response = await http.patch(
      url,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    
    print('PATCH Response status: ${response.statusCode}');
    print('PATCH Response body: ${response.body}');
    
    return response;
  }

  // DELETE request
  Future<http.Response> delete(String endpoint, {bool includeAuth = true}) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    
    return http.delete(url, headers: headers);
  }

  // Handle API response and errors
  dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseBody = response.body;
        return json.decode(responseBody);
      } catch (e) {
        throw ApiException(
          message: 'Response parse hatası: $e',
          statusCode: response.statusCode,
        );
      }
    } else {
      throw ApiException(
        message: _getErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  String _getErrorMessage(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      return errorData['message'] ?? 'Bir hata oluştu';
    } catch (e) {
      switch (response.statusCode) {
        case 400:
          return 'Geçersiz istek';
        case 401:
          return 'Yetkisiz erişim';
        case 403:
          return 'Erişim reddedildi';
        case 404:
          return 'Kaynak bulunamadı';
        case 500:
          return 'Sunucu hatası';
        default:
          return 'Bilinmeyen hata';
      }
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
