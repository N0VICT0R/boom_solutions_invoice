import 'dart:convert';

import 'package:boom_solutions_invoice/CustomerDetail/Datamodels/SalesDataModels.dart';
import 'package:boom_solutions_invoice/CustomerDetail/Datamodels/productDataModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
class CustomerDetailController extends GetxController {
  final isDarkMode = true.obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final Rx<SalesData?> salesData = Rx<SalesData?>(null);
  final selectedProduct = Rx<Product?>(null);
  final selectedIndex = Rx<int?>(null);

  Future<void> fetchSalesData(int partnerId) async {
    try {
      isLoading(true);
      hasError(false);

      final response = await http.get(Uri.parse(
          'http://137.184.205.67:2710/api/v1/partners/$partnerId/sales_customer_products_chart?api_token=VKwmwcRzwAIY9ef6A7Gp2qBOISwwPCke'));

      if (response.statusCode == 200) {
        salesData.value = SalesData.fromJson(json.decode(response.body));
      } else {
        hasError(true);
      }
    } catch (e) {
      hasError(true);
      print('Error fetching data: $e');
    } finally {
      isLoading(false);
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
}
