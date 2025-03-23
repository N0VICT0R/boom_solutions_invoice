import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_controller.dart';
import '../controllers/customer_details_controller.dart';

class MetricsGrid extends StatelessWidget {
  final CustomerController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard('Total Products',
            '${controller.salesData.value?.products.length ?? 0}',
            Icons.list_alt),
        _buildMetricCard('Currency',
            controller.salesData.value?.currency ?? 'N/A',
            Icons.currency_exchange),
        _buildMetricCard('Top Product',
            controller.salesData.value?.products.isNotEmpty == true
                ? controller.salesData.value!.products.first.name
                : 'N/A',
            Icons.star),
        _buildMetricCard('Highest %',
            controller.salesData.value?.products.isNotEmpty == true
                ? '${controller.salesData.value!.products.first.percentage.toStringAsFixed(1)}%'
                : 'N/A',
            Icons.leaderboard),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: controller.isDarkMode.value ? Colors.white54 : Colors.black54),
                Spacer(),
                Text(value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: controller.isDarkMode.value ? Colors.white : Colors.black,
                    )),
              ],
            ),
            SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                  fontSize: 12,
                  color: controller.isDarkMode.value ? Colors.white54 : Colors.black54,
                )),
          ],
        ),
      ),
    );
  }
}