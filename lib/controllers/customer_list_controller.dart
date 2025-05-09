import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/partner_list.dart';  // Single import source

class CustomerListController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  final partners = <PartnerList>[].obs;
  final isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading(true);
      hasError(false);
            final apiurl = GetStorage().read("apiUrl");
      final token = GetStorage().read('token') ?? '';
      final response = await http.get(Uri.parse(
        '$apiurl/api/v1/partners?api_token=$token&limit=10&page=1&state_id='
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['partners'] is List) {
          partners.assignAll(
            (data['partners'] as List).map((e) => PartnerList.fromJson(e)).toList()
          );
        }
      } else {
        hasError(true);
      }
    } catch (e) {
      hasError(true);
      print('Error fetching customers: $e');
    } finally {
      isLoading(false);
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
}