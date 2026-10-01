import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class CustomerApi {
  CustomerApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl =>
      dotenv.env['API_URL'] ??
      (throw const ApiException('API_URL tidak ditemukan di .env'));

  Future<Map<String, dynamic>> getUserCustomerContacts() async {
    return {};
  }

  Future<Map<String, dynamic>> syncUserCustomerContacts(
    List<Map<String, String>> contacts,
  ) async {
    return {};
  }
}
