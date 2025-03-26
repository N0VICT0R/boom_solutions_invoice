import 'dart:convert';

import 'package:boom_solutions_invoice/CustomerDetail/Datamodels/PartnerListModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
      
      final response = await http.get(Uri.parse(
        'http://137.184.205.67:2710/api/v1/partners?api_token=VKwmwcRzwAIY9ef6A7Gp2qBOISwwPCke&limit=10&page=1&state_id='
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
