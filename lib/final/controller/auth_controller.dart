// import 'dart:convert';
import 'dart:convert';

import 'package:boom_solutions_invoice/services/location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

/// User model representing the authenticated user.
class User {
  final int id;
  final String name;
  final String login;
  final String email;
  final int partnerId;
  final int storeId;
  final String storeName;

  User({
    required this.id,
    required this.name,
    required this.login,
    required this.email,
    required this.partnerId,
    required this.storeId,
    required this.storeName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      login: json['login'] as String? ?? '',
      email: json['email'] as String? ?? '',
      partnerId: json['partner_id'] as int? ?? 0,
      storeId: json['store_id'] as int? ?? 0,
      storeName: json['store_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'login': login,
        'email': email,
        'partner_id': partnerId,
        'store_id': storeId,
        'store_name': storeName,
      };
}

/// A separate API client that automatically attaches the API token to every request.
class ApiClient {
  final String baseUrl;
  final GetStorage storage = GetStorage();

  ApiClient({required this.baseUrl});

  String? get token => storage.read('token');

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> getRequest(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(uri, headers: _buildHeaders());
    return response;
  }

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

/// Authentication controller that manages login, token saving, and logout.
class AuthController extends GetxController {
  final Rx<User?> currentUser = Rx<User?>(null);
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final apiTokenController = TextEditingController();

  final storage = GetStorage();
  late final ApiClient apiClient;

  @override
  void onInit() async {
    super.onInit();
    await _initialize();
  }

  Future<void> _initialize() async {
    final String apiUrl = storage.read('apiUrl') ?? 'https://onix.boom-solutions.co';
    apiClient = ApiClient(baseUrl: apiUrl);
    await checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    String? userJson = storage.read('user');
    if (userJson != null) {
      try {
        currentUser.value = User.fromJson(jsonDecode(userJson));
        Get.offAllNamed('/dashboard');
      } catch (e) {
        print('Error decoding user data: $e');
        Get.snackbar('Error', 'Failed to load user data');
      }
    }
  }

  Future<void> signIn() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading(true);

    try {
      final response = await apiClient.postRequest(
        '/api/v1/auth',
        {
          'api_token': apiTokenController.text.trim(),
          'login': emailController.text.trim(),
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['user'];
        if (userData is Map<String, dynamic>) {
          final user = User.fromJson(userData);
          print('User ID from API: ${user.id}');
          await _saveUserData(user: user);
          storage.write('user_id', user.id);
          print('Saved user_id: ${storage.read('user_id')}');
          currentUser.value = user;

          // Set API token for LocationTrackerController
          Get.find<LocationTrackerController>().setApiToken(apiTokenController.text.trim());

          Get.offAllNamed('/dashboard');
          Get.snackbar('Success', 'Welcome ${user.name}!');
        } else {
          throw Exception('User data not found in response');
        }
      } else {
        Get.snackbar('Error', data['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Connection error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _saveUserData({required User user}) async {
    final userJson = jsonEncode(user.toJson());
    await storage.write('user', userJson);
    await storage.write('token', apiTokenController.text.trim());
  }

Future<void> logout() async {
  await GetStorage().remove('token');
  await GetStorage().remove('user_id');
  Get.find<LocationTrackerController>().stopTracking();
  currentUser.value = null;
  Get.offAllNamed('/login');
}

  @override
  void onClose() {
    emailController.dispose();
    apiTokenController.dispose();
    super.onClose();
  }
}