//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
//
// class User {
//   final int id;
//   final String name;
//   final String login;
//   final String email;
//   final int partnerId;
//   final int storeId;
//   final String storeName;
//
//   User({
//     required this.id,
//     required this.name,
//     required this.login,
//     required this.email,
//     required this.partnerId,
//     required this.storeId,
//     required this.storeName,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       name: json['name'],
//       login: json['login'],
//       email: json['email'],
//       partnerId: json['partner_id'],
//       storeId: json['store_id'],
//       storeName: json['store_name'],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'login': login,
//     'email': email,
//     'partner_id': partnerId,
//     'store_id': storeId,
//     'store_name': storeName,
//   };
// }
//
// class AuthController extends GetxController {
//   final Rx<User?> currentUser = Rx<User?>(null);
//   final isLoading = false.obs;
//   final formKey = GlobalKey<FormState>();
//
//   final emailController = TextEditingController();
//   final apiTokenController = TextEditingController();
//
//   final storage = GetStorage(); // Mobile-compatible storage
//
//   @override
//   void onInit() {
//     checkLoginStatus();
//     super.onInit();
//   }
//
//   Future<void> checkLoginStatus() async {
//     String? userJson = storage.read('user');
//     if (userJson != null) {
//       currentUser.value = User.fromJson(jsonDecode(userJson));
//       Get.offAllNamed('/dashboard');
//     }
//   }
//
//   Future<void> signIn() async {
//     if (!(formKey.currentState?.validate() ?? false)) return;
//     isLoading(true);
//
//     try {
//       final response = await http.post(
//         Uri.parse('http://137.184.205.67:2710/api/v1/auth'), // Fixed double slash in URL
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'api_token': apiTokenController.text.trim(),
//           'login': emailController.text.trim(),
//         }),
//       );
//
//       print('Response Status: ${response.statusCode}');
//       print('Response Body: ${response.body}'); // Log the full response body
//
//       final data = jsonDecode(response.body);
//
//       if (response.statusCode == 200 && data['success'] == true) {
//         final user = User.fromJson(data['user']);
//         await _saveUserData(user: user);
//         currentUser.value = user;
//
//         Get.offAllNamed('/dashboard');
//         Get.snackbar('Success', 'Welcome ${user.name}!');
//       } else {
//         Get.snackbar('Error', data['message'] ?? 'Authentication failed');
//       }
//     } catch (e) {
//       print('Error: $e'); // Log the error for debugging
//       Get.snackbar('Error', 'Connection error');
//     } finally {
//       isLoading(false);
//     }
//   }
//
//   Future<void> _saveUserData({required User user}) async {
//     final userJson = jsonEncode(user.toJson());
//     storage.write('user', userJson);
//     storage.write('token', apiTokenController.text.trim());
//   }
//
//   Future<void> logout() async {
//     storage.erase();
//     currentUser.value = null;
//     Get.offAllNamed('/login');
//   }
//
//   @override
//   void onClose() {
//     emailController.dispose();
//     apiTokenController.dispose();
//     super.onClose();
//   }
// }
import 'dart:convert';
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
      id: json['id'],
      name: json['name'],
      login: json['login'],
      email: json['email'],
      partnerId: json['partner_id'],
      storeId: json['store_id'],
      storeName: json['store_name'],
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

/// Authentication controller that manages login, token saving, and logout.
class AuthController extends GetxController {
  final Rx<User?> currentUser = Rx<User?>(null);
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  // Text controllers for user input.
  final emailController = TextEditingController();
  final apiTokenController = TextEditingController();

  final storage = GetStorage(); // For persistent storage

  // Instance of ApiClient to be used for API calls.
  late final ApiClient apiClient;

  @override
  void onInit() {
    // Initialize GetStorage before using it (typically done in main.dart).
    // Initialize the ApiClient with your base URL.
    apiClient = ApiClient(baseUrl: 'http://137.184.205.67:2710');
    checkLoginStatus();
    super.onInit();
  }

  /// Checks if the user is already logged in by reading user data from storage.
  Future<void> checkLoginStatus() async {
    String? userJson = storage.read('user');
    if (userJson != null) {
      currentUser.value = User.fromJson(jsonDecode(userJson));
      Get.offAllNamed('/dashboard');
    }
  }

  /// Signs in the user using the API token as their password.
  Future<void> signIn() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading(true);

    try {
      // Use the ApiClient to make a POST request.
      final response = await apiClient.postRequest(
        '/api/v1/auth',
        {
          'api_token': apiTokenController.text.trim(), // User-entered API token
          'login': emailController.text.trim(),
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final user = User.fromJson(data['user']);
        await _saveUserData(user: user);
        currentUser.value = user;
         GetStorage().write('token', '${apiTokenController.text.trim()}');
        // Navigate to the dashboard.
        Get.offAllNamed('/dashboard');
        Get.snackbar('Success', 'Welcome ${user.name}!');
      } else {
        Get.snackbar('Error', data['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Connection error');
    } finally {
      isLoading(false);
    }
  }

  /// Saves the user data and the API token (user-entered) to storage.
  Future<void> _saveUserData({required User user}) async {
    final userJson = jsonEncode(user.toJson());
    storage.write('user', userJson);
    storage.write('token', apiTokenController.text.trim());
  }

  /// Logs out the user by erasing storage data and navigating to the login screen.
  Future<void> logout() async {
    storage.erase();
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
