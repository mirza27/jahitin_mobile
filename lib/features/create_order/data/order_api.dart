import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/api_service.dart';

class OrderApi {
  OrderApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl =>
      dotenv.env['API_URL'] ??
      (throw const ApiException('API_URL tidak ditemukan di .env'));

  Future<List<Map<String, dynamic>>> getOrders({String? token}) async {
    final response = await _request(
      method: 'GET',
      path: '/orders',
      token: token,
    );

    final data = response['data'] ?? response['orders'] ?? response;
    if (data is! List) {
      throw const ApiException('Format daftar order tidak valid');
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> getOrder(String orderId, {String? token}) {
    return _request(method: 'GET', path: '/orders/$orderId', token: token);
  }

  Future<Map<String, dynamic>> createOrder({
    required Map<String, dynamic> payload,
    String? token,
  }) {
    return _request(
      method: 'POST',
      path: '/orders',
      payload: payload,
      token: token,
    );
  }

  Future<Map<String, dynamic>> updateOrder({
    required String orderId,
    required Map<String, dynamic> payload,
    String? token,
  }) {
    return _request(
      method: 'PUT',
      path: '/orders/$orderId',
      payload: payload,
      token: token,
    );
  }

  Future<void> deleteOrder(String orderId, {String? token}) async {
    await _request(method: 'DELETE', path: '/orders/$orderId', token: token);
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String path,
    Map<String, dynamic>? payload,
    String? token,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('$_baseUrl$path');

    final response = switch (method) {
      'GET' =>
        await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15)),
      'POST' =>
        await _client
            .post(uri, headers: headers, body: jsonEncode(payload ?? {}))
            .timeout(const Duration(seconds: 15)),
      'PUT' =>
        await _client
            .put(uri, headers: headers, body: jsonEncode(payload ?? {}))
            .timeout(const Duration(seconds: 15)),
      'DELETE' =>
        await _client
            .delete(uri, headers: headers)
            .timeout(const Duration(seconds: 15)),
      _ => throw ArgumentError('HTTP method tidak didukung: $method'),
    };

    Map<String, dynamic> body = {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        body = Map<String, dynamic>.from(decoded);
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message =
        body['message'] as String? ??
        body['error'] as String? ??
        'Permintaan order gagal (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
