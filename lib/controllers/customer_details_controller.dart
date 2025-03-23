// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import '../models/sales_data.dart';
//
// class CustomerController extends GetxController {
//   static const String apiToken = '8ix9pmELkqR43vwAMICnVSGclSCkaGAf';
//   final RxList<int> customerIds = <int>[10, 11, 12].obs; // Add more IDs as needed
//   final RxInt selectedCustomerId = 10.obs;
//   final Rx<SalesData?> salesData = Rx<SalesData?>(null);
//   final RxBool isLoading = false.obs;
//   final RxString errorMessage = ''.obs;
//   final RxBool isDarkMode = true.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchSalesData();
//   }
//   Future<void> fetchSalesData() async {
//     try {
//       final response = await http.get(
//           Uri.parse('http://137.184.205.67:2710/api/v1/partners/${selectedCustomerId.value}/sales_customer_products_chart?api_token=$apiToken')
//       ).timeout(Duration(seconds: 10));
//
//       if (response.statusCode == 200) {
//         // Handle success
//       } else {
//         throw Exception('Server responded with ${response.statusCode}');
//       }
//     } on SocketException catch (_) {
//       throw Exception('Network error - check internet connection');
//     } on TimeoutException catch (_) {
//       throw Exception('Request timed out - server might be busy');
//     } catch (e) {
//       throw Exception('Failed to fetch data: $e');
//     }
//   }
//   // Future<void> fetchSalesData() async {
//   //   try {
//   //     isLoading.value = true;
//   //     errorMessage.value = '';
//   //
//   //     final response = await http.get(
//   //         Uri.parse(
//   //             'http://137.184.205.67:2710/api/v1/partners/${selectedCustomerId.value}/sales_customer_products_chart?api_token=$apiToken'
//   //         )
//   //     );
//   //
//   //     if (response.statusCode == 200) {
//   //       salesData.value = SalesData.fromJson(
//   //           json.decode(response.body),
//   //           selectedCustomerId.value
//   //       );
//   //     } else {
//   //       throw Exception('Failed to load data: ${response.statusCode}');
//   //     }
//   //   } catch (e) {
//   //     errorMessage.value = e.toString();
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   // }
//
//   void updateCustomerId(int newId) {
//     selectedCustomerId.value = newId;
//     fetchSalesData();
//   }
//
//   void toggleTheme() {
//     isDarkMode.value = !isDarkMode.value;
//   }
// }