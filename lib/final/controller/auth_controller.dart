// controllers/auth_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
class AuthController extends GetxController {
  final Rx<User?> currentUser = Rx<User?>(null);
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  
  final emailController = TextEditingController();
  final apiTokenController = TextEditingController();

  @override
  void onInit() {
    checkLoginStatus();
    super.onInit();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    
    if (userJson != null) {
      currentUser.value = User.fromJson(jsonDecode(userJson));
      Get.offAllNamed('/dashboard');
    }
  }

  Future<void> signIn() async {
    if (formKey.currentState?.validate() ?? false) return;
    isLoading(true);
    
    try {
      final response = await http.post(
        Uri.parse('http://137.184.205.67:2710//api/v1/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'api_token': apiTokenController.text.trim(),
          'login': emailController.text.trim(),
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        final user = User.fromJson(data['user']);
        await _saveUserData(user: user);
        currentUser.value = user;
        
        Get.offAllNamed('/dashboard');
        Get.snackbar('Success', 'Welcome ${user.name}!');
      } else {
        Get.snackbar('Error', data['error'] ?? 'Authentication failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _saveUserData({required User user}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    await prefs.setString('token', apiTokenController.text.trim());
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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