// // // import 'package:flutter/material.dart';
// // // import 'package:get/get.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:crypto/crypto.dart';
// // // import 'dart:convert';
// // import 'dart:convert';
// // import 'package:crypto/crypto.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';

// // class AuthController extends GetxController {
// //   final isLogin = true.obs;
// //   final isLoading = false.obs;
  
// //   final formKey = GlobalKey<FormState>();
  
// //   // Changed passwordController to apiTokenController
// //   final emailController = TextEditingController();
// //   final apiTokenController = TextEditingController();

// //   void toggleAuthMode() => isLogin.toggle();
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     Get.put<AuthController>(this); // Explicit registration
// //   }
// //   Future<void> signIn() async {
// //     if (!formKey.currentState!.validate()) return;
// //     isLoading(true); // Proper observable update
    
// //     try {
// //       final response = await http.post(
// //         Uri.parse('http://137.184.205.67:2710/api/v1/auth'),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode({
// //           'api_token': apiTokenController.text,
// //           'login': emailController.text,
// //         }),
// //       );
      
// //       final data = jsonDecode(response.body);
      
// //       if (response.statusCode == 200 && data['success'] == true) {
// //         // Save user data to shared preferences
// //         final prefs = await SharedPreferences.getInstance();
// //         await prefs.setString('user', jsonEncode(data['user']));
        
// //         // Navigate to dashboard
// //         Get.offAllNamed('/dashboard');
// //         Get.snackbar('Success', 'Welcome ${data['user']['name']}!');
// //       } else {
// //         Get.snackbar('Error', data['error'] ?? 'Authentication failed');
// //       }
// //     } catch (e) {
// //       Get.snackbar('Error', 'Check your internet connection');
// //       } finally {
// //       isLoading(false); // Proper observable update
// //     }
// //   }

// // // class AuthController extends GetxController {
// // //   final isLogin = true.obs;
// // //   final isLoading = false.obs;
  
// // //   final formKey = GlobalKey<FormState>();
  
// // //   final nameController = TextEditingController();
// // //   final emailController = TextEditingController();
// // //   final passwordController = TextEditingController();

// // //   void toggleAuthMode() => isLogin.toggle();

// // //   Future<void> signIn() async {
// // //     if (!formKey.currentState!.validate()) return;
// // //     isLoading.value = true;
    
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final email = emailController.text;
      
// // //       if (!prefs.containsKey(email)) {
// // //         Get.snackbar('Error', 'User not found');
// // //         return;
// // //       }

// // //       final userData = jsonDecode(prefs.getString(email)!);
// // //       final enteredHash = _hashPassword(passwordController.text);
      
// // //       if (userData['password'] != enteredHash) {
// // //         Get.snackbar('Error', 'Invalid credentials');
// // //         return;
// // //       }

// // //       Get.offAllNamed('/dashboard');
// // //     } finally {
// // //       isLoading.value = false;
// // //     }
// // //   }

// //   // Future<void> signUp() async {
// //   //   if (!formKey.currentState!.validate()) return;
// //   //   isLoading.value = true;
    
// //   //   try {
// //   //     final prefs = await SharedPreferences.getInstance();
// //   //     final email = emailController.text;
      
// //   //     if (prefs.containsKey(email)) {
// //   //       Get.snackbar('Error', 'User already exists');
// //   //       return;
// //   //     }

// //   //     final passwordHash = _hashPassword(passwordController.text);
      
// //   //     await prefs.setString(email, jsonEncode({
// //   //       'name': nameController.text,
// //   //       'email': email,
// //   //       'password': passwordHash,
// //   //       'createdAt': DateTime.now().toIso8601String(),
// //   //     }));

// //   //     Get.offAllNamed('/dashboard');
// //   //   } finally {
// //   //     isLoading.value = false;
// //   //   }
// //   // }

// // //   String _hashPassword(String password) {
// // //     final bytes = utf8.encode(password + _getSalt());
// // //     return sha256.convert(bytes).toString();
// // //   }

// // //   String _getSalt() => 'your-secure-salt-here';

// // //   @override
// // //   void onClose() {
// // //     nameController.dispose();
// // //     emailController.dispose();
// // //     passwordController.dispose();
// // //     super.onClose();
// // //   }

// //   @override
// //   void onClose() {
// //     emailController.dispose();
// //     apiTokenController.dispose();
// //     super.onClose();
// //   }
// // }
// // auth_controller.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthController extends GetxController {
//   final isLoading = false.obs;
//   final formKey = GlobalKey<FormState>();
  
//   final emailController = TextEditingController();
//   final apiTokenController = TextEditingController();

//   Future<void> signIn() async {
//     if (!formKey.currentState!.validate()) return;
//     isLoading(true);
    
//     try {
//       final response = await http.post(
//         Uri.parse('http://137.184.205.67:2710/api/v1/auth'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'api_token': apiTokenController.text.trim(),
//           'login': emailController.text.trim(),
//         }),
//       );
      
//       final data = jsonDecode(response.body);
      
//       if (response.statusCode == 200 && data['success'] == true) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('user', jsonEncode(data['user']));
//         Get.offAllNamed('/dashboard');
//         Get.snackbar('Success', 'Welcome ${data['user']['name']}!');
//       } else {
//         Get.snackbar('Error', data['error'] ?? 'Authentication failed');
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Connection error: ${e.toString()}');
//     } finally {
//       isLoading(false);
//     }
//   }

//   @override
//   void onClose() {
//     emailController.dispose();
//     apiTokenController.dispose();
//     super.onClose();
//   }
// }
// auth_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  
  final emailController = TextEditingController();
  final apiTokenController = TextEditingController();

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;
    isLoading(true);
    
    try {
      final response = await http.post(
        Uri.parse('http://137.184.205.67:2710/api/v1/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'api_token': apiTokenController.text.trim(),
          'login': emailController.text.trim(),
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data['user']));
        Get.offAllNamed('/dashboard');
        Get.snackbar('Success', 'Welcome ${data['user']['name']}!');
      } else {
        Get.snackbar('Error', data['error'] ?? 'Authentication failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    apiTokenController.dispose();
    super.onClose();
  }
}