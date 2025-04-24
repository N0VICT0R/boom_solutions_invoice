import 'package:boom_solutions_invoice/services/ConnectivityService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controller/auth_controller.dart';

class DashboardController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final RxString selectedCompany = 'EGP'.obs;
  final RxDouble totalUnpaid = 0.0.obs;
  final RxDouble totalOverdue = 4500.0.obs;
  final RxDouble totalBalance = 4500.0.obs;
  final RxDouble totalPaid = 1500.0.obs;
  final RxDouble totalSales = 6000.0.obs;
  final RxInt unpaidInvoices = 0.obs;
  final RxInt overdueInvoices = 1.obs;
  final RxInt invoicedClients = 1.obs;
  final RxInt invoicedItems = 3.obs;
  final notes = <Map<String, dynamic>>[].obs;
  final noteController = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
 final ConnectivityService connectivityService = Get.find<ConnectivityService>();
  @override
  void onInit() {
    super.onInit();
       checkInternetAccess();
    // Optional: Listen for connectivity changes
    connectivityService.isConnected.listen((isConnected) {
      if (!isConnected && Get.currentRoute != '/offline') {
        Get.offAllNamed('/offline');
      }
    });
    fetchNotes();
  }
   Future<void> checkInternetAccess() async {
    bool hasAccess = await connectivityService.checkGoogleAccess();
    if (!hasAccess && Get.currentRoute != '/offline') {
      Get.offAllNamed('/offline');
    }
  }

  Future<void> fetchNotes() async {
    final baseUrl = "https://onix.boom-solutions.co/"; // Assume baseUrl is stored in AuthController
    final token = "gln5EU3jkGwBy7GZWnSpm9N7EffslYS5"; // Assume apiToken is stored in AuthController
    final url = Uri.parse('$baseUrl/api/v1/users/notes?api_token=$token');

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final fetchedNotes = List<Map<String, dynamic>>.from(data['notes']);
          // Sort notes by priority (High=2, Medium=1, Low=0)
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

    final baseUrl = "https://onix.boom-solutions.co/";
    final token = "gln5EU3jkGwBy7GZWnSpm9N7EffslYS5";
    final url = Uri.parse('$baseUrl/api/v1/users/notes?api_token=$token');

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': 'Note', // Default title; could be user-input
          'message': noteController.text.trim(),
          'priority': '1', // Default to Medium priority
        }),
      );
      if (response.statusCode == 201) {
        noteController.clear();
        await fetchNotes(); // Refresh notes
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
      case '2': // High
        return Colors.redAccent;
      case '1': // Medium
        return Colors.yellowAccent;
      case '0': // Low
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
    return Container();
  }

  Widget collectPayment() {
    return Container();
  }

  Widget logVisit() {
    return Container();
  }
}