import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final GetStorage storage = GetStorage();

  ApiClient({required this.baseUrl});

  // Retrieves the saved API token from storage.
  String? get token => storage.read('token');

  // Build headers including the API token if available.
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Example GET request.
  Future<http.Response> getRequest(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(uri, headers: _buildHeaders());
    return response;
  }

  // Example POST request.
  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return response;
  }
}
