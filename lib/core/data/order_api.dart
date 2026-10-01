import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class OrderApi {
  OrderApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl =>
      dotenv.env['API_URL'] ??
      (throw const ApiException('API_URL tidak ditemukan di .env'));

  Future<Map<String, dynamic>> createUserOrder(
    Map<String, dynamic> payload, {
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl/order/create');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await _client
        .post(
          uri,
          headers: headers,
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if (body is Map<String, dynamic>) {
        return body;
      }
      return {};
    }

    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};
    final message =
        body['message'] as String? ??
        body['error'] as String? ??
        'Gagal membuat pesanan (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  /// Mengambil daftar order user dari API.
  ///
  /// Jika [token] diberikan, akan ditambahkan ke header Authorization.
  /// Parameter opsional [status], [search], [page], dan [limit]
  /// digunakan sebagai query parameter.
  Future<List<Map<String, dynamic>>> getUserOrders({
    String? token,
    String? status,
    String? search,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      'page': (page ?? 1).toString(),
      'limit': (limit ?? 100).toString(),
    };

    final uri = Uri.parse(
      '$_baseUrl/order/list',
    ).replace(queryParameters: queryParams);

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await _client
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      return [];
    }

    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    final message =
        body['message'] as String? ??
        body['error'] as String? ??
        'Gagal mengambil daftar order (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> getUserOrderDetail(
    String orderId, {
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl/order/detail/$orderId');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await _client
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['data'] is Map) {
        return Map<String, dynamic>.from(body['data'] as Map);
      }
      return {};
    }

    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};
    final message =
        body['message'] as String? ??
        body['error'] as String? ??
        'Gagal mengambil detail order (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }

  /// Mengupdate data order secara penuh (/order/update/:order_id).
  Future<Map<String, dynamic>> updateOrder(
    String orderId,
    List<Map<String, dynamic>> payload, {
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl/order/update/$orderId');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await _client
        .put(
          uri,
          headers: headers,
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if (body is Map<String, dynamic>) {
        return body;
      }
      return {};
    }

    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};
    final message =
        body['message'] as String? ??
        body['error'] as String? ??
        'Gagal memperbarui pesanan (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }
}

final orderApiProvider = Provider<OrderApi>((ref) {
  return OrderApi();
});
