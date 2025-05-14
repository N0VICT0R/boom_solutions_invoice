//=======================
// Customer Detail Screen
//=======================
import 'package:boom_solutions_invoice/CustomerDetail/Components/DetailScreenComponents.dart';
import 'package:boom_solutions_invoice/controllers/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerDetailScreen extends StatelessWidget {
  
  late final CustomerController controller = Get.put(CustomerController());
  final List<Color> chartColors = [
    Colors.black,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.redAccent,
    Colors.tealAccent,
  ];

  CustomerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final partnerId = args['partnerId'] ?? 11;
    controller.fetchSalesData(partnerId);

    return Obx(() => Scaffold(
      // backgroundColor: controller.isDarkMode.value ? Colors.black : Colors.white70,
      appBar: _buildAppBar(),
      body: _buildBody(context),
    ));
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Obx(() => Text(
            controller.salesData.value?.partner.name ?? 'Dashboard',
            style: TextStyle(
              // color: controller.isDarkMode.value ? Colors.grey[100]: Colors.black,
            ),
          )),
      // backgroundColor: controller.isDarkMode.value ? Colors.black : Colors.white12,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            controller.isDarkMode.value ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            // color: controller.isDarkMode.value ? Colors.white : Colors.black,
          ),
          onPressed: controller.toggleTheme,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value) return _buildLoading();
    if (controller.hasError.value || controller.salesData.value == null) {
      return _buildError();
    }
    return _buildMainContent(context);
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        // color: controller.isDarkMode.value ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Customer has no data ',
            style: TextStyle(
              fontSize: 25,
              // color: controller.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          ElevatedButton(
            onPressed: () => controller.fetchSalesData(
              Get.arguments['partnerId'] ?? 0),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.02;
    final cardSpacing = size.height * 0.02;

    return RefreshIndicator(
      onRefresh: () => controller.fetchSalesData(
        Get.arguments['partnerId'] ?? 11),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: cardSpacing),
              Payment(),
              SalesSummary(),
              SizedBox(height: cardSpacing),
              SalesChart(chartColors: chartColors),
              SizedBox(height: cardSpacing),
              MetricsGrid(),
              SizedBox(height: cardSpacing * 2),
            ],
          ),
        ),
      ),
    );
  }
}
