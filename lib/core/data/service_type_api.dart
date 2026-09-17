import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../../features/detail_order/model/update_detail_order.dart';

class ServiceTypeApi {
  ServiceTypeApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl =>
      dotenv.env['API_URL'] ??
      (throw const ApiException('API_URL tidak ditemukan di .env'));

  /// Mengambil daftar jenis layanan dari API (/service/list).
  Future<List<ServiceTypeModel>> getServiceTypes({String? token}) async {
    final uri = Uri.parse('$_baseUrl/service/list');
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
              .map((item) => ServiceTypeModel.fromJson(
                  Map<String, dynamic>.from(item)))
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
        'Gagal mengambil daftar jenis layanan (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }
}

final serviceTypeApiProvider = Provider<ServiceTypeApi>((ref) {
  return ServiceTypeApi();
});
