// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../models/partner_list.dart';  // Single import source

// class CustomerListController extends GetxController {
//   final isLoading = true.obs;
//   final hasError = false.obs;
//   final partners = <PartnerList>[].obs;
//   final isDarkMode = true.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchCustomers();
//   }

//   Future<void> fetchCustomers() async {
//     try {
//       isLoading(true);
//       hasError(false);
//             final apiurl = GetStorage().read("apiUrl");
//       final token = GetStorage().read('token') ?? '';
//       final response = await http.get(Uri.parse(
//         '$apiurl/api/v1/partners?api_token=$token&limit=10&page=1&state_id='
//       ));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['partners'] is List) {
//           partners.assignAll(
//             (data['partners'] as List).map((e) => PartnerList.fromJson(e)).toList()
//           );
//         }
//       } else {
//         hasError(true);
//       }
//     } catch (e) {
//       hasError(true);
//       print('Error fetching customers: $e');
//     } finally {
//       isLoading(false);
//     }
//   }

//   void toggleTheme() {
//     isDarkMode.value = !isDarkMode.value;
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:boom_solutions_invoice/CustomerDetail/Datamodels/PartnerListModel.dart';


class CustomerListController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  final partners = <PartnerList>[].obs;
  final filteredPartners = <PartnerList>[].obs;
  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading(true);
      hasError(false);
      final apiUrl = GetStorage().read("apiUrl") ?? '';
      final token = GetStorage().read('token') ?? '';
      final url =
          '$apiUrl/api/v1/partners?api_token=$token&limit=10&page=1&state_id=';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['partners'] is List) {
          partners.assignAll(
            (data['partners'] as List)
                .map((e) => PartnerList.fromJson(e))
                .toList(),
          );
          filteredPartners.assignAll(partners);
        } else {
          hasError(true);
        }
      } else {
        hasError(true);
      }
    } catch (e) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  void searchCustomers(String query) {
    if (query.isEmpty) {
      filteredPartners.assignAll(partners);
    } else {
      filteredPartners.assignAll(
        partners
            .where((partner) =>
                partner.name.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  void sortCustomers() {
    filteredPartners.sort((a, b) => a.name.compareTo(b.name));
    filteredPartners.refresh();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}