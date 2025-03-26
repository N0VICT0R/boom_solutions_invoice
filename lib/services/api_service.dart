// lib/services/api_service.dart
import 'dart:convert';
import 'package:boom_solutions_invoice/services/Models.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://137.184.205.67:2710';
  
  // These are updated during login
  static String? apiToken;
  static int? partnerId;

  // Update credentials after login
  static void updateCredentials({required String token, required int partner}) {
    apiToken = token;
    partnerId = partner;
  }

  // ---------------------------
  // Authentication Endpoint
  // ---------------------------
  Future<AuthResponse> auth(String login) async {
    final url = Uri.parse('$baseUrl/api/v1/auth');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"login": login}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AuthResponse.fromJson(data);
    }
    throw Exception(
      "Authentication failed. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  // ---------------------------
  // Partner Endpoints
  // ---------------------------
  Future<Partner> getPartnerById(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/partners/$id?api_token=$apiToken');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return Partner.fromJson(json.decode(response.body));
    }
    throw Exception(
      "Failed to fetch partner details. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  Future<PartnersList> listPartners({int limit = 10, int page = 1, String stateId = ''}) async {
    final url = Uri.parse('$baseUrl/api/v1/partners?api_token=$apiToken&limit=$limit&page=$page&state_id=$stateId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return PartnersList.fromJson(json.decode(response.body));
    }
    throw Exception(
      "Failed to list partners. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  Future<StatesResponse> getStates() async {
    final url = Uri.parse('$baseUrl/api/v1/states?api_token=$apiToken');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return StatesResponse.fromJson(json.decode(response.body));
    }
    throw Exception(
      "Failed to retrieve states. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  // ---------------------------
  // Partner Financials Endpoints
  // ---------------------------
  Future<CustomerBalance> getCustomerBalance() async {
    if (partnerId == null) throw Exception("Partner ID is not set. Please login again.");
    final url = Uri.parse('$baseUrl/api/v1/partners/$partnerId/balance?api_token=$apiToken');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return CustomerBalance.fromJson(json.decode(response.body));
    }
    throw Exception(
      "Failed to retrieve customer balance. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  Future<PartnerStatement> getCustomerStatement() async {
    if (partnerId == null) throw Exception("Partner ID is not set. Please login again.");
    final url = Uri.parse('$baseUrl/api/v1/partners/$partnerId/statement?api_token=$apiToken');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Partner partner = Partner.fromJson(data['partner']);
      Statement statement = Statement.fromJson(data['statement']);
      return PartnerStatement(partner: partner, statement: statement);
    }
    throw Exception(
      "Failed to retrieve customer statement. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  Future<String> getSOAStatementHtml({
    required int partner,
    required String dateFrom,
    required String dateTo,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/partners/$partner/statement/pdf?api_token=$apiToken&date_from=$dateFrom&date_to=$dateTo');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception(
      "Failed to retrieve SOA statement. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  Future<SalesCustomerProductsChart> getSalesCustomerProductsChart() async {
    if (partnerId == null) throw Exception("Partner ID is not set. Please login again.");
    final url = Uri.parse('$baseUrl/api/v1/partners/$partnerId/sales_customer_products_chart?api_token=$apiToken');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return SalesCustomerProductsChart.fromJson(json.decode(response.body));
    }
    throw Exception(
      "Failed to retrieve sales chart. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  Future<CustomerPayments> getCustomerPayments({int page = 1}) async {
    if (partnerId == null) throw Exception("Partner ID is not set. Please login again.");
    final url = Uri.parse('$baseUrl/api/v1/partners/$partnerId/payments?api_token=$apiToken&page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return CustomerPayments.fromJson(json.decode(response.body));
    }
    throw Exception(
      "Failed to retrieve customer payments. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  // ---------------------------
  // Inventory & Products Endpoints
  // ---------------------------
  Future<CurrentStock> getCurrentStock() async {
    final url = Uri.parse('$baseUrl/api/v1/inventory/quantities?api_token=$apiToken');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return CurrentStock.fromJson(json.decode(response.body));
    }
    throw Exception(
      "Failed to retrieve current stock. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  // The following endpoints are placeholders and return dynamic JSON.
  Future<Map<String, dynamic>> getAllProducts() async {
    final url = Uri.parse('$baseUrl/api/v1/products?api_token=$apiToken');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception(
      "Failed to retrieve products. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  Future<Map<String, dynamic>> getProductsByCategory(String categoryId) async {
    final url = Uri.parse('$baseUrl/api/v1/products?api_token=$apiToken&category_id=$categoryId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception(
      "Failed to retrieve products by category. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  Future<Map<String, dynamic>> searchProducts(String searchTerm) async {
    final url = Uri.parse('$baseUrl/api/v1/products?api_token=$apiToken&search=$searchTerm');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception(
      "Failed to search products. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  Future<Map<String, dynamic>> getProductsPagination({int limit = 10, int page = 1}) async {
    final url = Uri.parse('$baseUrl/api/v1/products?api_token=$apiToken&limit=$limit&page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception(
      "Failed to retrieve paginated products. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  Future<Map<String, dynamic>> getProductByBarcode(String barcode) async {
    final url = Uri.parse('$baseUrl/api/v1/products/barcode/$barcode?api_token=$apiToken');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception(
      "Failed to retrieve product by barcode. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  Future<Map<String, dynamic>> getProductByMultiOptions(Map<String, dynamic> options) async {
    final url = Uri.parse('$baseUrl/api/v1/products/multi_options?api_token=$apiToken');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(options),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception(
      "Failed to retrieve product with multi options. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }

  // ---------------------------
  // Payment Endpoint
  // ---------------------------
  Future<Map<String, dynamic>> postPayment({
    required double amount,
    required int paymentMethodId,
    required String memo,
    required bool postImmediately,
  }) async {
    if (partnerId == null) throw Exception("Partner ID is not set. Please login again.");
    final url = Uri.parse('$baseUrl/api/v1/partners/$partnerId/payments?api_token=$apiToken');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "amount": amount,
        "payment_method_id": paymentMethodId,
        "memo": memo,
        "post_immediately": postImmediately,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception(
      "Payment failed. Please try again later. [Error ${response.statusCode}: ${response.body}]"
    );
  }
}
