import 'package:boom_solutions_invoice/services/ConnectivityService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controller/auth_controller.dart';

class DashboardController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final RxString selectedCompany = 'EGP'.obs;
  final RxDouble totalUnpaid = 0.0.obs;
  final RxDouble totalOverdue = 0.0.obs;
  final RxDouble totalBalance = 0.0.obs;
  final RxDouble totalPaid = 0.0.obs;
  final RxDouble totalSales = 0.0.obs;
  final RxInt unpaidInvoices = 0.obs;
  final RxInt overdueInvoices = 0.obs;
  final RxInt invoicedClients = 0.obs;
  final RxInt invoicedItems = 0.obs;
  final RxInt totalCustomers = 0.obs;
  final RxInt todayVisits = 0.obs;
  final RxInt newCustomersThisMonth = 0.obs;
  final notes = <Map<String, dynamic>>[].obs;
  final noteController = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
    int currentIndex = 0;

  final ConnectivityService connectivityService = Get.find<ConnectivityService>();

  @override
  void onInit() {
    super.onInit();
    checkInternetAccess();
    connectivityService.isConnected.listen((isConnected) {
      if (!isConnected && Get.currentRoute != '/offline') {
        Get.offAllNamed('/offline');
      } else if (isConnected && Get.currentRoute == '/offline') {
        Get.offAllNamed('/dashboard'); // Navigate back to dashboard when reconnected
      }
    });
    fetchDashboardData();
    fetchNotes();
  }

  Future<void> checkInternetAccess() async {
    bool hasAccess = await connectivityService.checkGoogleAccess();
    if (!hasAccess && Get.currentRoute != '/offline') {
      Get.offAllNamed('/offline');
    }
  }

  Future<void> fetchDashboardData() async {
    final token = GetStorage().read('token') ?? '';
    final baseUrl = GetStorage().read('apiUrl') ?? '';
    final url = Uri.parse('$baseUrl/api/v1/users/2/home-screen?api_token=$token');

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Update reactive variables with API data
          totalSales.value = (data['monthly_sales']['metrics']['total_amount'] as num?)?.toDouble() ?? 0.0;
          unpaidInvoices.value = data['receivables']['invoice_count'] ?? 0;
          invoicedClients.value = data['receivables']['partner_count'] ?? 0;
          totalUnpaid.value = (data['receivables']['amount_due_today'] as num?)?.toDouble() ?? 0.0;
          totalBalance.value = (data['cash_journal']['balance'] as num?)?.toDouble() ?? 0.0;
          totalCustomers.value = data['additional_metrics']['total_customers'] ?? 0;
          todayVisits.value = data['additional_metrics']['today_visits'] ?? 0;
          newCustomersThisMonth.value = data['additional_metrics']['new_customers_this_month'] ?? 0;
          // Note: totalOverdue, totalPaid, and invoicedItems are not in the JSON; may need separate API or logic
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to fetch dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching dashboard data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNotes() async {
    final token = GetStorage().read('token') ?? '';
    final baseUrl = GetStorage().read('apiUrl') ?? '';
    final url = Uri.parse('$baseUrl/api/v1/users/notes?api_token=$token');

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final fetchedNotes = List<Map<String, dynamic>>.from(data['notes']);
          notes.assignAll(fetchedNotes..sort((a, b) => b['priority'].compareTo(a['priority'])));
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to fetch notes: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching notes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNote() async {
    if (noteController.text.trim().isEmpty) return;

    final token = GetStorage().read('token') ?? '';
    final baseUrl = GetStorage().read('apiUrl') ?? '';
    final url = Uri.parse('$baseUrl/api/v1/users/notes?api_token=$token');

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': 'Note',
          'message': noteController.text.trim(),
          'priority': '1',
        }),
      );
      if (response.statusCode == 201) {
        noteController.clear();
        await fetchNotes();
      } else {
        throw Exception('Failed to add note: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Error adding note: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case '2':
        return Colors.redAccent;
      case '1':
        return Colors.yellow;
      case '0':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  Widget createNewDeal() {
    // Implement logic to create a new deal
    return Container(); // Replace with actual UI
  }

  Widget collectPayment() {
    // Implement logic to collect payment
    return Container(); // Replace with actual UI
  }

  Widget logVisit() {
    // Implement logic to log a visit
    return Container(); // Replace with actual UI
  }
}