
import 'package:boom_solutions_invoice/widgets/line_syncf_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

//=======================
// Data Models
//=======================
class PartnerList {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final dynamic phone;
  final dynamic mobile;

  PartnerList({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.state,
    this.country,
    this.phone,
    this.mobile,
  });

  factory PartnerList.fromJson(Map<String, dynamic> json) {
    return PartnerList(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      address: _parseString(json['address']),
      city: _parseString(json['city']),
      state: _parseString(json['state']),
      country: _parseString(json['country']),
      phone: json['phone'],
      mobile: json['mobile'],
    );
  }

  static String? _parseString(dynamic value) {
    if (value is String) return value;
    if (value == false) return null;
    return value?.toString();
  }
}

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
      totalSales: json['total_sales']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'EGP',
      currencySymbol: json['currency_symbol'] ?? 'LE',
      products: (json['products'] as List?)
              ?.map((e) => Product.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Partner {
  final int id;
  final String name;

  Partner({required this.id, required this.name});

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Customer',
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
      name: json['name']?['en_US'] ?? 'Unnamed Product',
      amount: json['amount']?.toDouble() ?? 0.0,
      percentage: json['percentage']?.toDouble() ?? 0.0,
    );
  }
}

//=======================
// Controllers
//=======================
class CustomerListController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  final partners = <PartnerList>[].obs;
  final isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading(true);
      hasError(false);
      
      final response = await http.get(Uri.parse(
        'http://137.184.205.67:2710/api/v1/partners?api_token=VKwmwcRzwAIY9ef6A7Gp2qBOISwwPCke&limit=10&page=1&state_id='
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['partners'] is List) {
          partners.assignAll(
            (data['partners'] as List).map((e) => PartnerList.fromJson(e)).toList()
          );
        }
      } else {
        hasError(true);
      }
    } catch (e) {
      hasError(true);
      print('Error fetching customers: $e');
    } finally {
      isLoading(false);
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
}

class CustomerController extends GetxController {
  final isDarkMode = true.obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final Rx<SalesData?> salesData = Rx<SalesData?>(null);
  final selectedProduct = Rx<Product?>(null);
  final selectedIndex = Rx<int?>(null);

  Future<void> fetchSalesData(int partnerId) async {
    try {
      isLoading(true);
      hasError(false);

      final response = await http.get(Uri.parse(
          'http://137.184.205.67:2710/api/v1/partners/$partnerId/sales_customer_products_chart?api_token=VKwmwcRzwAIY9ef6A7Gp2qBOISwwPCke'));

      if (response.statusCode == 200) {
        salesData.value = SalesData.fromJson(json.decode(response.body));
      } else {
        hasError(true);
      }
    } catch (e) {
      hasError(true);
      print('Error fetching data: $e');
    } finally {
      isLoading(false);
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
}

//=======================
// Customer List Screen
//=======================
class CustomersListScreen extends StatelessWidget {
  final CustomerListController controller = Get.put(CustomerListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: controller.isDarkMode.value ? Colors.black : Colors.white70,
      appBar: AppBar(
        title: Text('Customers',
          style: TextStyle(
            color: controller.isDarkMode.value ? Colors.white : Colors.black
          ),
        ),
        backgroundColor: controller.isDarkMode.value ? Colors.black : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              controller.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
              color: controller.isDarkMode.value ? Colors.white : Colors.black,
            ),
            onPressed: controller.toggleTheme,
          ),
        ],
      ),
      body: _buildBody(),
    ));
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) return _buildLoading();
      if (controller.hasError.value) return _buildError();
      if (controller.partners.isEmpty) return _buildEmptyState();
      return _buildCustomerList();
    });
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: controller.isDarkMode.value ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Failed to load customers',
            style: TextStyle(
              color: controller.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          ElevatedButton(
            onPressed: controller.fetchCustomers,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined, size: 64,
            color: controller.isDarkMode.value ? Colors.white54 : Colors.black54),
          SizedBox(height: 16),
          Text(
            'No customers found',
            style: TextStyle(
              fontSize: 18,
              color: controller.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: controller.partners.length,
      itemBuilder: (context, index) {
        final partner = controller.partners[index];
        return _buildCustomerCard(partner);
      },
    );
  }

  Widget _buildCustomerCard(PartnerList partner) {
    return Card(
      color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(partner.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: controller.isDarkMode.value ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            if (partner.address?.isNotEmpty ?? false)
              _buildInfoRow(Icons.location_on, partner.address!),
            if (partner.city?.isNotEmpty ?? false)
              _buildInfoRow(Icons.location_city, partner.city!),
            if (partner.state?.isNotEmpty ?? false)
              _buildInfoRow(Icons.map, partner.state!),
            if (partner.country?.isNotEmpty ?? false)
              _buildInfoRow(Icons.public, partner.country!),
            if (partner.phone != null && partner.phone != false)
              _buildInfoRow(Icons.phone, partner.phone.toString()),
            if (partner.mobile != null && partner.mobile != false)
              _buildInfoRow(Icons.phone_iphone, partner.mobile.toString()),
          ],
        ),
        trailing: Icon(Icons.chevron_right,
          color: controller.isDarkMode.value ? Colors.white54 : Colors.black54,
        ),
        onTap: () {
          Get.to(() => CustomerDetailScreen(), 
            arguments: {'partnerId': partner.id}
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Visibility(
      visible: text.isNotEmpty,
      child: Row(
        children: [
          Icon(icon, 
            size: 16, 
            color: controller.isDarkMode.value ? Colors.white54 : Colors.black54
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(text,
              style: TextStyle(
                color: controller.isDarkMode.value ? Colors.white54 : Colors.black54
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//=======================
// Customer Detail Screen 
//=======================
// [Keep your existing CustomerDetailScreen implementation here]
// [Include all the SalesSummary, SalesChart, MetricsGrid classes]

//=======================
// Main Application
//=======================
void main() => runApp(GetMaterialApp(
  home: CustomersListScreen(),
  debugShowCheckedModeBanner: false,
  theme: ThemeData.light(),
  darkTheme: ThemeData.dark(),
));

//=======================
// Customer List Screen
//=======================
// class CustomersListScreen extends StatelessWidget {
//   final CustomerListController controller = Get.put(CustomerListController());

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Scaffold(
//       backgroundColor: controller.isDarkMode.value ? Colors.black : Colors.white70,
//       appBar: AppBar(
//         title: Text('Customers',
//           style: TextStyle(
//             color: controller.isDarkMode.value ? Colors.white : Colors.black
//           ),
//         ),
//         backgroundColor: controller.isDarkMode.value ? Colors.black : Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(
//               controller.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
//               color: controller.isDarkMode.value ? Colors.white : Colors.black,
//             ),
//             onPressed: controller.toggleTheme,
//           ),
//         ],
//       ),
//       body: _buildBody(),
//     ));
//   }

//   Widget _buildBody() {
//     return Obx(() {
//       if (controller.isLoading.value) return _buildLoading();
//       if (controller.hasError.value) return _buildError();
//       return _buildCustomerList();
//     });
//   }

//   Widget _buildLoading() {
//     return Center(
//       child: CircularProgressIndicator(
//         color: controller.isDarkMode.value ? Colors.white : Colors.black,
//       ),
//     );
//   }

//   Widget _buildError() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Failed to load customers',
//             style: TextStyle(
//               color: controller.isDarkMode.value ? Colors.white : Colors.black,
//             ),
//           ),
//           ElevatedButton(
//             onPressed: controller.fetchCustomers,
//             child: Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCustomerList() {
//     return ListView.builder(
//       padding: EdgeInsets.all(16),
//       itemCount: controller.partners.length,
//       itemBuilder: (context, index) {
//         final partner = controller.partners[index];
//         return _buildCustomerCard(partner);
//       },
//     );
//   }

//   Widget _buildCustomerCard(PartnerList partner) {
//     return Card(
//       color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.all(16),
//         title: Text(partner.name,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: controller.isDarkMode.value ? Colors.white : Colors.black,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 8),
//             _buildInfoRow(Icons.phone, partner.phone),
//             _buildInfoRow(Icons.email, partner.email),
//           ],
//         ),
//         trailing: Icon(Icons.chevron_right,
//           color: controller.isDarkMode.value ? Colors.white54 : Colors.black54,
//         ),
//         onTap: () {
//           Get.to(() => CustomerDetailScreen(), 
//             arguments: {'partnerId': partner.id}
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, 
//           size: 16, 
//           color: controller.isDarkMode.value ? Colors.white54 : Colors.black54
//         ),
//         SizedBox(width: 8),
//         Text(text,
//           style: TextStyle(
//             color: controller.isDarkMode.value ? Colors.white54 : Colors.black54
//           ),
//         ),
//       ],
//     );
//   }
// }

//=======================
// Customer Detail Screen
//=======================
class CustomerDetailScreen extends StatelessWidget {
  final CustomerController controller = Get.put(CustomerController());
  final List<Color> chartColors = [
    Colors.black,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.redAccent,
    Colors.tealAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final partnerId = args['partnerId'] ?? 11;
    controller.fetchSalesData(partnerId);

    return Obx(() => Scaffold(
      backgroundColor: controller.isDarkMode.value ? Colors.black : Colors.white70,
      appBar: _buildAppBar(),
      body: _buildBody(context),
    ));
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Obx(() => Text(
            controller.salesData.value?.partner.name ?? 'Dashboard',
            style: TextStyle(
              color: controller.isDarkMode.value ? Colors.grey[100]: Colors.black,
            ),
          )),
      backgroundColor: controller.isDarkMode.value ? Colors.black : Colors.white12,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            controller.isDarkMode.value ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: controller.isDarkMode.value ? Colors.white : Colors.black,
          ),
          onPressed: controller.toggleTheme,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value) return _buildLoading();
    if (controller.hasError.value || controller.salesData.value == null)
      return _buildError();
    return _buildMainContent(context);
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: controller.isDarkMode.value ? Colors.white : Colors.black,
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
              color: controller.isDarkMode.value ? Colors.white : Colors.black,
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
    final padding = size.width * 0.05;
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

//=======================
// Detail Screen Components
//=======================
class SalesSummary extends GetView<CustomerController> {
  
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
                color: controller.isDarkMode.value
                    ? Colors.white70
                    : Colors.black54,
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
                color: controller.isDarkMode.value ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCard({required double height, required Widget child}) {
    return Container(
      width: double.infinity,
      height: height,
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class SalesChart extends GetView<CustomerController> {
  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      // width: 150,
      decoration: BoxDecoration(
        color: controller.isDarkMode.value ? Colors.grey[900] : Colors.grey[100],
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
                  color: controller.isDarkMode.value
                      ? Colors.white60
                      : Colors.black54,
                ),
                 SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: controller.isDarkMode.value
                    ? Colors.white54
                    : Colors.black54,
              ),
            ),
                // Spacer(),
                SizedBox(width: 10),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: controller.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
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

  SalesChart({required this.chartColors});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final salesData = controller.salesData.value;
      if (salesData == null) return Container();

      return buildCard(
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
                    color: controller.isDarkMode.value ? Colors.white70 : Colors.black87,
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
                            fontSize: 14,
                            color: controller.isDarkMode.value 
                                ? Colors.white60 
                                : Colors.black54,
                          ),
                        ),
                        Text(
                          
                          '${salesData.totalSales.toStringAsFixed(0)}'' ${salesData.currencySymbol}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: controller.isDarkMode.value 
                                ? Colors.white 
                                : Colors.black,
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
                    child: _buildProductDetails(
                      controller.selectedProduct.value!,
                      chartColors[controller.selectedIndex.value! % chartColors.length],
                    ),
                  )
                : const SizedBox.shrink()),
          ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.isDarkMode.value ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
                    color: controller.isDarkMode.value 
                        ? Colors.white 
                        : Colors.black87,
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
              color: controller.isDarkMode.value 
                  ? Colors.white70 
                  : Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: controller.isDarkMode.value 
                  ? Colors.white 
                  : Colors.black87,
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
        color: controller.isDarkMode.value ? const Color(0xFF1E1E1E) : Colors.white24,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class MetricsGrid extends GetView<CustomerController> {
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
          // _buildMetricCard(
          //   'Total Products',
          //   salesData.products.length.toString(),
          //   Icons.list_alt,
          // ),
          // _buildMetricCard(
          //   'Top Product',
          //   salesData.products.isNotEmpty
          //       ? salesData.products.first.name
          //       : 'N/A',
          //   Icons.star,
          // ),
          // _buildMetricCard(
          //   'Currency',
          //   salesData.currency,
          //   Icons.currency_exchange,
          // ),
          // _buildMetricCard(
          //   'Highest Percentage',
          //   salesData.products.isNotEmpty
          //       ? '${salesData.products.first.percentage.toStringAsFixed(1)}%'
          //       : 'N/A',
          //   Icons.leaderboard,
          // ),
        ],
      );
    });
  }

  
}

//=======================
// Main Application
//=======================
// void main() => runApp(GetMaterialApp(
//   home: CustomersListScreen(),
//   debugShowCheckedModeBanner: false,
//   theme: ThemeData.light(),
//   darkTheme: ThemeData.dark(),
// ));