import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
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
 final notes = <String>[].obs;
  final noteController = TextEditingController();

  void addNote() {
    if (noteController.text.trim().isNotEmpty) {
      notes.insert(0, noteController.text.trim());
      noteController.clear();
      update();
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