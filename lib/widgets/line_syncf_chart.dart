import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesController extends GetxController {
  Rx<DateTime> startDate = DateTime(2025, 2, 16).obs;
  Rx<DateTime> endDate = DateTime(2025, 3, 17).obs;
  RxList<SalesData> salesData = <SalesData>[].obs;
  RxDouble totalSales = 0.0.obs;
  RxDouble totalPaid = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  } 

  void loadData() {
    // Sample data - replace with your actual data
    salesData.assignAll([
      SalesData(DateTime(2025, 2, 10), 4200),
      SalesData(DateTime(2025, 2, 21), 3000),
      SalesData(DateTime(2025, 2, 26), 6500),
      SalesData(DateTime(2025, 3, 3), 4800),
      SalesData(DateTime(2025, 3, 8), 5500),
      SalesData(DateTime(2025, 3, 13), 7200),
    ]);
    
    calculateTotals();
  }

  void calculateTotals() {
    totalSales.value = salesData.fold(0.0, (sum, item) => sum + item.amount);
    totalPaid.value = totalSales.value * 0.8; // Example calculation
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: startDate.value, end: endDate.value),
    );
    
    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;
      loadData(); // Reload data based on new dates
    }
  }
}

class SalesData {
  final DateTime date;
  final double amount;

  SalesData(this.date, this.amount);
}

class SalesLineChart extends StatelessWidget {
  final SalesController controller = Get.put(SalesController());

  SalesLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Range Selector
            Obx(() => InkWell(
              onTap: () => controller.selectDateRange(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatDate(controller.startDate.value)} - ${_formatDate(controller.endDate.value)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Text('More', style: TextStyle(color: Colors.blue)),
                ],
              ),
            )),
            
            const SizedBox(height: 20),
            
            // Chart
            SizedBox(
              height: 300,
              child: Obx(() => SfCartesianChart(
                primaryXAxis: DateTimeCategoryAxis(),
                series: <CartesianSeries>[
                  LineSeries<SalesData, DateTime>(
                    dataSource: controller.salesData,
                    xValueMapper: (SalesData sales, _) => sales.date,
                    yValueMapper: (SalesData sales, _) => sales.amount,
                  )
                ],
              )),
            ),
            
            const SizedBox(height: 20),
            
            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Obx(() => Text(
                      '£${controller.totalSales.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24),
                    )),
                    const Text('0.00moles'),
                  ],
                ),
                Column(
                  children: [
                    Obx(() => Text(
                      '£${controller.totalPaid.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24),
                    )),
                    const Text('0.00moles'),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Sales Dates
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: controller.salesData
                  .map((sale) => Text(_formatDateShort(sale.date)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}