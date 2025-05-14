//=======================
// Detail Screen Components
//=======================
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:boom_solutions_invoice/controllers/customer_controller.dart';

class SalesSummary extends GetView<CustomerController> {
  const SalesSummary({super.key});

  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final salesData = controller.salesData.value;
      if (salesData == null) return Container();

      return _buildCard(
        height: MediaQuery.of(context).size.height * 0.15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Sales',
              style: TextStyle(
                fontSize: 16,
                // color: controller.isDarkMode.value
                //     ? Colors.white70
                //     : Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            // Expanded(child: SalesLineChart()),
            SizedBox(height: 8),

            Text(
              '${salesData.currencySymbol} ${salesData.totalSales.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                // color: controller.isDarkMode.value ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCard({required double height, required Widget child}) {
    return Card(
      child: Container(
        width: double.infinity,
        height: height,
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          // color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 10,
          //     offset: Offset(0, 4),
          //   ),
          // ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
class Payment extends GetView<CustomerController> {
  const Payment({super.key});

  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final salesData = controller.salesData.value;
      if (salesData == null) return Container();

      return _buildCard(
        height: MediaQuery.of(context).size.height * 0.15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Sales',
              style: TextStyle(
                fontSize: 16,
                // color: controller.isDarkMode.value
                //     ? Colors.white70
                //     : Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            // Expanded(child: SalesLineChart()),
            SizedBox(height: 8),

            Text(
              '${salesData.currencySymbol} ${salesData.totalSales.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                // color: controller.isDarkMode.value ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      );
    }
    );
  }

  Widget _buildCard({required double height, required Widget child}) {
    return Card(
      child: Container(
        width: double.infinity,
        height: height,
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          // color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 10,
          //     offset: Offset(0, 4),
          //   ),
          // ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class SalesChart extends GetView<CustomerController> {
  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      // width: 150,
      decoration: BoxDecoration(
        // color: controller.isDarkMode.value ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
         
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  // color: controller.isDarkMode.value
                  //     ? Colors.white60
                  //     : Colors.black54,
                ),
                 SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                // color: controller.isDarkMode.value
                //     ? Colors.white54
                //     : Colors.black54,
              ),
            ),
                // Spacer(),
                SizedBox(width: 10),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    // color: controller.isDarkMode.value
                    //     ? Colors.white
                    //     : Colors.black,
                  ),
                ),
                
              ],
            ),
           
          ],
        ),
      ),
    );
  }
  final List<Color> chartColors;

  const SalesChart({super.key, required this.chartColors});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final salesData = controller.salesData.value;
      if (salesData == null) return Container();

      return Card(
        child: buildCard(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Product Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      // color: controller.isDarkMode.value ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  
                      _buildMetricCard(
                  'Top Product',
                  salesData.products.isNotEmpty
                      ? salesData.products.first.name
                      : 'N/A',
                  Icons.star,
                            ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: 25,
                        sectionsSpace: 0,
                        centerSpaceRadius: 55,
                        sections: buildPieSections(salesData.products),
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            if (event is FlTapUpEvent && 
                                pieTouchResponse != null &&
                                pieTouchResponse.touchedSection != null) {
                              final touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                              if (touchedIndex >= 0 && 
                                  touchedIndex < salesData.products.length) {
                                if (controller.selectedIndex.value == touchedIndex) {
                                  controller.selectedIndex.value = null;
                                  controller.selectedProduct.value = null;
                                } else {
                                  controller.selectedIndex.value = touchedIndex;
                                  controller.selectedProduct.value = 
                                    salesData.products[touchedIndex];
                                }
                              }
                            }
                          },
                          enabled: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              // color: controller.isDarkMode.value 
                              //     ? Colors.white60 
                              //     : Colors.black54,
                            ),
                          ),
                          Text(
                            
                            '${salesData.totalSales.toStringAsFixed(0)}'' ${salesData.currencySymbol}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              // color: controller.isDarkMode.value 
                              //     ? Colors.white 
                              //     : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() => controller.selectedProduct.value != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        child: _buildProductDetails(
                          controller.selectedProduct.value!,
                          chartColors[controller.selectedIndex.value! % chartColors.length],
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      );
    });
  }

  List<PieChartSectionData> buildPieSections(List<Product> products) {
    return products.asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      final isSelected = controller.selectedIndex.value == index;

      return PieChartSectionData(
        color: chartColors[index % chartColors.length],
        value: product.percentage,
        title: product.percentage > 5.0 ? '${product.percentage.toStringAsFixed(1)}%' : '',
        radius: isSelected ? 70 : 60,
        titleStyle: TextStyle(
          fontSize: isSelected ? 18 : 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        showTitle: product.percentage > 5.0,
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Widget _buildProductDetails(Product product, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // color: controller.isDarkMode.value ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 8,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // color: controller.isDarkMode.value 
                      //     ? Colors.white 
                      //     : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Percentage', '${product.percentage.toStringAsFixed(1)}%'),
            _buildDetailRow('Amount', 
                '${controller.salesData.value!.currencySymbol} ${product.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Share of Total', 
                '${(product.amount / controller.salesData.value!.totalSales * 100).toStringAsFixed(2)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              // color: controller.isDarkMode.value 
              //     ? Colors.white70 
              //     : Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              // color: controller.isDarkMode.value 
              //     ? Colors.white 
              //     : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({required double height, required Widget child}) {
    return Container(
     
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        //  color: controller.isDarkMode.value ? AppColors.containerDark :AppColors.containerLight,
        // color: controller.isDarkMode.value ? const Color(0xFF1E1E1E) : Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class MetricsGrid extends GetView<CustomerController> {
  const MetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final salesData = controller.salesData.value;
      if (salesData == null) return Container();

      return GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildMetricCard(
            'Total Products',
            salesData.products.length.toString(),
            Icons.list_alt,
          ),
          _buildMetricCard(
            'Top Product',
            salesData.products.isNotEmpty
                ? salesData.products.first.name
                : 'N/A',
            Icons.star,
          ),
          _buildMetricCard(
            'Currency',
            salesData.currency,
            Icons.currency_exchange,
          ),
          _buildMetricCard(
            'Highest Percentage',
            salesData.products.isNotEmpty
                ? '${salesData.products.first.percentage.toStringAsFixed(1)}%'
                : 'N/A',
            Icons.leaderboard,
          ),
        ],
      );
    });
  }

  
}
 Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      // color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon,),
                    // color: controller.isDarkMode.value ? Colors.white54 : Colors.black54),
                Spacer(),
                Text(value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // color: controller.isDarkMode.value ? Colors.white : Colors.black,
                    )),
              ],
            ),
            SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                  fontSize: 12,
                  // color: controller.isDarkMode.value ? Colors.white54 : Colors.black54,
                )),
          ],
        ),
      ),
    );
  }