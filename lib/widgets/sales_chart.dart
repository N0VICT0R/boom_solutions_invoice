import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/customer_controller.dart';
import '../controllers/customer_details_controller.dart';

class SalesChart extends StatelessWidget {
  final CustomerController controller = Get.find();
  final List<Color> chartColors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.redAccent,
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('Product Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: controller.isDarkMode.value ? Colors.white70 : Colors.black87,
            )),
        SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.5,
          child: Obx(() => PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: _buildSections(),
              borderData: FlBorderData(show: false),
            ),
          )),
        )],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return controller.salesData.value?.products.asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      return PieChartSectionData(
        color: chartColors[index % chartColors.length],
        value: product.percentage,
        title: '${product.percentage.toStringAsFixed(1)}%',
        radius: 22,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList() ?? [];
  }
}