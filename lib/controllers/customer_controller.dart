// controllers/customer_controller.dart
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SalesData {
  final Partner partner;
  final double totalSales;
  final String currency;
  final String currencySymbol;
  final List<Product> products;

  SalesData({
    required this.partner,
    required this.totalSales,
    required this.currency,
    required this.currencySymbol,
    required this.products,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      partner: Partner.fromJson(json['partner']),
      totalSales: json['total_sales'].toDouble(),
      currency: json['currency'],
      currencySymbol: json['currency_symbol'],
      products: List<Product>.from(
        json['products'].map((x) => Product.fromJson(x)),
      ),
    );
  }
}

class Partner {
  final int id;
  final String name;

  Partner({required this.id, required this.name});

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Product {
  final String name;
  final double amount;
  final double percentage;

  Product({
    required this.name,
    required this.amount,
    required this.percentage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name']['en_US'],
      amount: json['amount'].toDouble(),
      percentage: json['percentage'].toDouble(),
    );
  }
}

class CustomerController extends GetxController {
  final isDarkMode = false.obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final salesData = Rx<SalesData?>(null);
   final selectedIndex = Rxn<int>();
  final Rx<Product?> selectedProduct = Rx<Product?>(null);
  get hasError => null;

  @override
  void onInit() {
    fetchSalesData(10); // Replace 5 with the appropriate partnerId value
    super.onInit();
  }

  Future<void> fetchSalesData(partnerId) async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await http.get(
        Uri.parse('http://137.184.205.67:2710/api/v1/partners/5/sales_customer_products_chart?api_token=VKwmwcRzwAIY9ef6A7Gp2qBOISwwPCke'),
      );

      if (response.statusCode == 200) {
        salesData.value = SalesData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void toggleTheme() {
    isDarkMode.toggle();
  }
}