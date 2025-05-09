// import 'dart:convert';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// class PaymentPostController extends GetxController {
//   final isLoading = false.obs;
//   final isSuccess = false.obs;
//   final errorMessage = ''.obs;

//   Future<void> postPayment({
//     required double amount,
//     required int paymentMethodId,
//     String memo = '',
//   }) async {
//     try {
//       isLoading(true);
//       isSuccess(false);
//       errorMessage('');

//       final response = await http
//           .post(
//             Uri.parse('http://137.184.205.67:2710//api/v1/partners/10/payments'),
//             headers: {
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//             },
//             body: json.encode({
//               'api_token': 'VKwmwcRzwAIY9ef6A7Gp2qBOISwwPCke',
//               'amount': amount,
//               'payment_method_id': paymentMethodId,
//               'memo': memo,
//               'post_immediately': true,
//             }),
//           )
//           .timeout(const Duration(seconds: 10));

//       print('Response Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         isSuccess(true);
//         Get.snackbar(
//           'Success',
//           'Payment posted successfully',
//           backgroundColor: Colors.green.shade600,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       } else {
//         errorMessage(json.decode(response.body)['message'] ?? 'Payment failed');
//         Get.snackbar(
//           'Error',
//           errorMessage.value,
//           backgroundColor: Colors.red.shade600,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
//     } on TimeoutException {
//       errorMessage('Request timed out. Please try again.');
//       Get.snackbar(
//         'Timeout',
//         errorMessage.value,
//         backgroundColor: Colors.orange.shade600,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } on http.ClientException catch (e) {
//       errorMessage('Client Exception: ${e.message}');
//       Get.snackbar(
//         'Error',
//         errorMessage.value,
//         backgroundColor: Colors.red.shade600,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } catch (e) {
//       errorMessage('An error occurred: $e');
//       Get.snackbar(
//         'Error',
//         errorMessage.value,
//         backgroundColor: Colors.red.shade600,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       isLoading(false);
//     }
//   }
// }
