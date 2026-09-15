import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static String get _baseUrl =>
      dotenv.env['API_URL'] ??
      (throw ApiException('API_URL tidak ditemukan di .env'));

  // ============================================= AUTH =============================================
  static Future<Map<String, dynamic>> registerLocal({
    required String name,
    required String deviceId,
  }) async {
    final uri = Uri.parse('$_baseUrl/user/register/local');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name, 'device_id': deviceId}),
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message =
        body['message'] as String? ??
        body['error'] as String? ??
        'Registrasi gagal (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  static Future<Map<String, dynamic>> loginLocal({
    required String deviceId,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login/local');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'device_id': deviceId}),
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message =
        body['error'] as String? ?? 'Login gagal (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  static Future<Map<String, dynamic>> loginAccount({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login/account');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message =
        body['error'] as String? ?? 'Login gagal (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  static Future<Map<String, dynamic>> userSession({
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/session');

    final response = await http
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message =
        body['error'] as String? ??
        'Gagal mengambil sesi user (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
