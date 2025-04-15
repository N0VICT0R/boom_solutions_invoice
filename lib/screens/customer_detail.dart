import 'package:boom_solutions_invoice/final/controller/themeController.dart';
import 'package:boom_solutions_invoice/final/view/dashboard_Getx.dart';
import 'package:boom_solutions_invoice/screens/PaymentPostScreen.dart';
import 'package:boom_solutions_invoice/widgets/SOA/SOApdf.dart';
import 'package:boom_solutions_invoice/widgets/line_syncf_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

//=======================
// Data Models
//=======================
class PartnerDetails {
  final int id;
  final String name;
  final double balance;
  final double amountDueToday;
  final double aov;
  final double oct;
  final int orderCount;
  final String currency;

  PartnerDetails({
    required this.id,
    required this.name,
    required this.balance,
    required this.amountDueToday,
    required this.aov,
    required this.oct,
    required this.orderCount,
    required this.currency,
  });

  factory PartnerDetails.fromJson(Map<String, dynamic> json) {
    return PartnerDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Customer',
      balance: (json['balance'] ?? 0.0).toDouble(),
      amountDueToday: (json['amount_due_today'] ?? 0.0).toDouble(),
      aov: (json['aov'] ?? 0.0).toDouble(),
      oct: (json['oct'] ?? 0.0).toDouble(),
      orderCount: json['order_count'] ?? 0,
      currency: json['currency'] ?? 'EGP',
    );
  }
}

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
      name: json['name']?['en_US']?['en_US'] ?? 'Unnamed Product',
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
  final filteredPartners = <PartnerList>[].obs;
  final isDarkMode = true.obs;

  void toggleTheme() => isDarkMode.value = !isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading(true);
      hasError(false);
      final token = GetStorage().read('token') ?? '';
      final url =
          'http://137.184.205.67:2710/api/v1/partners?api_token=$token&limit=10&page=1&state_id=';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['partners'] is List) {
          partners.assignAll(
            (data['partners'] as List)
                .map((e) => PartnerList.fromJson(e))
                .toList(),
          );
          filteredPartners.assignAll(partners);
        }
      } else {
        hasError(true);
      }
    } catch (e) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  void searchCustomers(String query) {
    if (query.isEmpty) {
      filteredPartners.assignAll(partners);
    } else {
      filteredPartners.assignAll(
        partners
            .where((partner) =>
                partner.name.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  void sortCustomers() {
    filteredPartners.sort((a, b) => a.name.compareTo(b.name));
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

      final token = GetStorage().read('token') ?? "";
      if (token.isEmpty) {
        // print('Error: No token found in GetStorage');
        hasError(true);
        return;
      }

      final url =
          "http://137.184.205.67:2710/api/v1/partners/$partnerId/balance?api_token=$token";
      // print('Fetching data from: $url');

      final response = await http.get(Uri.parse(url));

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          salesData.value = SalesData.fromJson(jsonData);
        } else {
          // print('API returned success: false');
          hasError(true);
        }
      } else if (response.statusCode == 401) {
        // print('Unauthorized: Invalid or expired token');
        hasError(true);
      } else if (response.statusCode == 404) {
        // print('Partner not found for ID: $partnerId');
        hasError(true);
      } else {
        // print('HTTP Error: ${response.statusCode}');
        hasError(true);
      }
    } catch (e) {
      // print('Exception caught: $e');
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
}
class PartnerController extends GetxController {
  var partnerDetails = Rxn<PartnerDetails>();
  var isLoading = true.obs;
  var hasError = false.obs;
  final token = GetStorage().read('token') ?? '';

  Future<void> fetchPartnerDetails(int partnerId) async {
    try {
      isLoading(true);
      hasError(false);

      if (token.isEmpty) {
        // print('Error: No token found in GetStorage');
        hasError(true);
        return;
      }

      final url =
          'http://137.184.205.67:2710/api/v1/partners/$partnerId/balance?api_token=$token';
      // print('Fetching partner details from: $url');

      final response = await http.get(Uri.parse(url));

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['partner'] != null) {
          partnerDetails.value = PartnerDetails.fromJson(jsonData['partner']);
        } else {
          // print('API returned success: false or no partner data');
          hasError(true);
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
        hasError(true);
      }
    } catch (e) {
      // print('Exception caught: $e');
      hasError(true);
    } finally {
      isLoading(false);
    }
  }
}

//=======================
// Screens
//=======================
class CustomersListScreen extends StatefulWidget {
  @override
  _CustomersListScreenState createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen>
    with WidgetsBindingObserver {
  final CustomerListController controller = Get.put(CustomerListController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.fetchCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text('Customers'),
          elevation: 0,
        //    leading: 
        // IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        // Get.off(() => SalesDashboard());
        //   },
        // ),
          actions: [
            IconButton(
              icon: Icon(
                  controller.isDarkMode.value ? Icons.add_outlined : Icons.add),
              onPressed: () {
                Get.toNamed("addcustomer");
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchAndSort(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndSort() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: controller.searchCustomers,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.sort_by_alpha),
            onPressed: controller.sortCustomers,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) return _buildLoading();
      if (controller.hasError.value) return _buildError();
      if (controller.filteredPartners.isEmpty) return _buildEmptyState();
      return RefreshIndicator(
        onRefresh: controller.fetchCustomers,
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.filteredPartners.length,
          itemBuilder: (context, index) {
            final partner = controller.filteredPartners[index];
            return _buildCustomerCard(partner);
          },
        ),
      );
    });
  }

  Widget _buildLoading() => Center(child: CircularProgressIndicator());

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Failed to load customers'),
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
          Icon(Icons.people_alt_outlined, size: 64),
          SizedBox(height: 16),
          Text('No customers found', style: TextStyle(fontSize: 18)),
          ElevatedButton(
            onPressed: controller.fetchCustomers,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(PartnerList partner) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          partner.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (partner.address?.isNotEmpty ?? false)
              _buildInfoRow(Icons.location_on, partner.address!),
            if (partner.city?.isNotEmpty ?? false)
              _buildInfoRow(Icons.location_city, partner.city!),
            if (partner.state?.isNotEmpty ?? false)
              _buildInfoRow(Icons.map, partner.state!),
            if (partner.country?.isNotEmpty ?? false)
              _buildInfoRow(Icons.public, partner.country!),
            if (partner.phone != null)
              _buildInfoRow(Icons.phone, partner.phone.toString()),
            if (partner.mobile != null)
              _buildInfoRow(Icons.phone_iphone, partner.mobile.toString()),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () => Get.to(() => CustomerDetailScreen(partnerId: partner.id),
            arguments: {'partnerId': partner.id}),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Visibility(
      visible: text.isNotEmpty,
      child: Row(
        children: [
          Icon(icon, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class CustomerDetailScreen extends StatelessWidget {
  final CustomerController controller = Get.put(CustomerController());
  final PartnerController partnerController = Get.put(PartnerController());
  final List<Color> chartColors = [
    Color(0xFFFF1744),
    Color(0xFFFFD600),
    Color(0xFF76FF03),
    Color(0xFF00E5FF),
    Color(0xFFD500F9),
    Color(0xFFFF9100),
  ];

  CustomerDetailScreen({Key? key, required int partnerId}) : super(key: key) {
    final args = Get.arguments ?? {};
    final id = args['partnerId'] ?? partnerId;
    if (id == 0) {
      // print('Warning: No valid partnerId provided');
    }
    controller.fetchSalesData(id);
    partnerController.fetchPartnerDetails(id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(context),
        ));
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Obx(() => Text(
            controller.salesData.value?.partner.name ?? 'Dashboard',
            style: TextStyle(),
          )),
      elevation: 0,
      // leading: 
      //   IconButton(
      //     icon: Icon(Icons.arrow_back),
      //     onPressed: () {
      //   Get.off(() => CustomersListScreen());
      //     },
      //   ),
        
      
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value) return _buildLoading();
    if (controller.hasError.value || controller.salesData.value == null)
      return _buildError();
    return _buildMainContent(context);
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Customer has no data',
            style: TextStyle(fontSize: 25),
          ),
          ElevatedButton(
            onPressed: () =>
                controller.fetchSalesData(Get.arguments['partnerId'] ?? 0),
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
      onRefresh: () async {
        await controller.fetchSalesData(Get.arguments['partnerId'] ?? 11);
        await partnerController
            .fetchPartnerDetails(Get.arguments['partnerId'] ?? 11);
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: cardSpacing),
              Payment(),
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
// Widgets
//=======================
class Payment extends GetView<CustomerController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final salesData = controller.salesData.value;
      if (salesData == null) return Container();

      return InkWell(
        onTap: () async { // غيرناها لـ async
          final partnerId = Get.arguments['partnerId'];
          
          // استخدمنا await مع Get.to علشان نستنى النتيجة
          final result = await Get.to<bool>(
            () => InvoicePaymentPage(partnerId: partnerId),
            arguments: {'partnerId': partnerId},
          );
          
          // لو الدفع تم بنجاح (رجع true)
          if (result == true) {
            // روح جيب بيانات العميل من السيرڤر تاني
            await Get.find<CustomerController>().fetchSalesData(partnerId);
            // جيب تفاصيل البارتشر المحدثة
            await Get.find<PartnerController>().fetchPartnerDetails(partnerId);
          }
        },
        child: _buildCard(
          height: MediaQuery.of(context).size.height * 0.10,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Make Payment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ),
        ),
      );
    });
  }
}
  Widget _buildCard({required double height, required Widget child}) {
    return Card(
      child: Container(
        width: double.infinity,
        height: height,
        margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }


class SalesChart extends GetView<CustomerController> {
  final List<Color> chartColors;

  SalesChart({required this.chartColors});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final salesData = controller.salesData.value;
      if (salesData == null) return Container();

      return Card(
        child: buildCard(
          height: MediaQuery.of(context).size.height * 0.60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    'Product Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            if (event is FlTapUpEvent &&
                                pieTouchResponse != null &&
                                pieTouchResponse.touchedSection != null) {
                              final touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                              if (touchedIndex >= 0 &&
                                  touchedIndex < salesData.products.length) {
                                if (controller.selectedIndex.value ==
                                    touchedIndex) {
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
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${salesData.totalSales.toStringAsFixed(0)} ${salesData.currencySymbol}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                        chartColors[controller.selectedIndex.value! %
                            chartColors.length],
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
        title: product.percentage > 5.0
            ? '${product.percentage.toStringAsFixed(1)}%'
            : '',
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
          borderRadius: BorderRadius.circular(12),
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
                'Percentage', '${product.percentage.toStringAsFixed(1)}%'),
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
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({required double height, required Widget child}) {
    return Card(
      child: Container(
        width: double.infinity,
        height: height,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, size: 16),
        SizedBox(width: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: 
          [
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4,),
            Text(value,
              
              style: TextStyle(fontSize: 12),
            ),
            
          ],
        ),
      ],
    );
  }
}

class MetricsGrid extends StatelessWidget {
  const MetricsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<PartnerController>(
      builder: (controller) {
        if (controller.isLoading.value) return CircularProgressIndicator();
        final partner = controller.partnerDetails.value;
        if (partner == null) return Text("No Data");

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildMetricCard(
                      context: context,
                      title: _getMetricTitle(index, partner),
                      value: _getMetricValue(index, partner),
                      icon: _getMetricIcon(index),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildDetailsCard(
                  context: context,
                  icon: Icons.receipt_long,
                  title: 'Statement of Account',
                  subtitle: 'View your complete transaction history',
                  onTap: () async {
                  final pickedFromDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    helpText: 'Select Start Date', // Hint for "From" date
                    confirmText: 'Next',
                  );

                  if (pickedFromDate != null) {
                    final pickedToDate = await showDatePicker(
                    context: context,
                    initialDate: pickedFromDate,
                    firstDate: pickedFromDate,
                    lastDate: DateTime.now(),
                    helpText: 'Select End Date', // Hint for "To" date
                    confirmText: 'Confirm',
                    );

                    if (pickedToDate != null) {
                    final pdfController = Get.put(PdfController());
                    final partnerId = Get.arguments['partnerId'];
                    pdfController.downloadAndOpenPdf(
                      partnerId,
                      pickedFromDate.toIso8601String(),
                      pickedToDate.toIso8601String(),
                    );
                    }
                  }
                  },
                ),
                  
                
                const SizedBox(height: 16),
                _buildDetailsCard(
                  context: context,
                  icon: Icons.map_outlined,
                  title: 'Visit Information',
                  subtitle: 'Customer utilization patterns and frequency',
                  onTap: () {
                    // TODO: Implement navigation
                  },    
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMetricTitle(int index, dynamic partner) {
    switch (index) {
      case 0:
        return 'Balance';
      case 1:
        return 'Dues';
      case 2:
        return 'AOV';
      case 3:
        return 'OCT';
      default:
        return '';
    }
  }

  String _getMetricValue(int index, dynamic partner) {
    switch (index) {
      case 0:
        return '\$${partner.balance.abs().toStringAsFixed(1)}';
      case 1:
        return '\$${partner.amountDueToday.abs().toStringAsFixed(0)}';
      case 2:
        return '\$${partner.aov.toStringAsFixed(1)}';
      case 3:
        return '${partner.oct.toStringAsFixed(2)} days';
      default:
        return '';
    }
  }

  IconData _getMetricIcon(int index) {
    switch (index) {
      case 0:
        return Icons.account_balance_wallet;
      case 1:
        return Icons.attach_money;
      case 2:
        return Icons.shopping_cart;
      case 3:
        return Icons.calendar_today;
      default:
        return Icons.error;
    }
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}