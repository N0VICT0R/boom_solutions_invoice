import 'package:boom_solutions_invoice/screens/PaymentPostScreen.dart';
import 'package:boom_solutions_invoice/screens/visitsScreens/visits_hestory_customer_Screen.dart';
import 'package:boom_solutions_invoice/widgets/SOA/SOApdf.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:boom_solutions_invoice/widgets/line_syncf_chart.dart';
import 'package:boom_solutions_invoice/generated/l10n.dart'; // Import localization

//=======================
// Location Service
//=======================
class LocationService {
  static const String baseUrl = 'http://137.184.205.67:2710';
  static String get apiToken => GetStorage().read('token') ?? '';

  Future<(bool, String?)> _checkAndRequestLocationPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return (false, S.current.location_services_disabled);
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return (false, S.current.location_permissions_denied);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return (false, S.current.location_permissions_denied_forever);
      }

      return (true, null);
    } catch (e) {
      print('Error checking location permissions: $e');
      return (false, '${S.current.error}: $e');
    }
  }

  Future<(bool, String?, double?, double?)> _getCurrentLocation() async {
    try {
      final (permissionGranted, permissionError) = await _checkAndRequestLocationPermissions();
      if (!permissionGranted) {
        return (false, permissionError, null, null);
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('Fetched current location: Latitude=${position.latitude}, Longitude=${position.longitude}');
      return (true, null, position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      return (false, '${S.current.error_getting_location}: $e', null, null);
    }
  }

  Future<(bool, String?)> updatePartnerLocation(int partnerId) async {
    try {
      if (apiToken.isEmpty) {
        return (false, S.current.no_token);
      }

      print('API Token: $apiToken');

      final (locationSuccess, locationError, latitude, longitude) = await _getCurrentLocation();
      if (!locationSuccess) {
        return (false, locationError);
      }

      final url = Uri.parse('$baseUrl/api/v1/partners/$partnerId/location');
      print('Updating location for partner ID $partnerId at URL: $url');

      final body = jsonEncode({
        'api_token': apiToken,
        'latitude': latitude,
        'longitude': longitude,
        'update_address': true,
      });
      print('Request body: $body');

      final response = await http
          .put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return (true, null);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return (false, S.current.auth_failed);
      } else if (response.statusCode == 429) {
        return (false, S.current.too_many_requests);
      } else {
        return (false, '${S.current.failed_to_update_location}: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating location: $e');
      return (false, '${S.current.error_updating_location}: $e');
    }
  }
}

//=======================
// Utility Function for Google Maps
//=======================
Future<void> launchGoogleMapsByPartnerId({
  required int partnerId,
  required BuildContext context,
}) async {
  final String baseUrl = 'http://137.184.205.67:2710/';
  final String token = GetStorage().read('token') ?? '';

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/partners/map?api_token=$token'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] && data['partners'] != null && data['partners'].isNotEmpty) {
        final partnerJson = (data['partners'] as List).firstWhere(
          (p) => p['id'] == partnerId,
          orElse: () => throw Exception('${S.current.partner_not_found} $partnerId'),
        );
        final partner = _Partner.fromJson(partnerJson);
        if (partner.latitude == 0.0 || partner.longitude == 0.0) {
          throw Exception('${S.current.no_valid_coordinates} $partnerId');
        }
        await MapsLauncher.launchCoordinates(partner.latitude, partner.longitude);
      } else {
        throw Exception(S.current.no_partners_found);
      }
    } else {
      throw Exception('${S.current.failed_to_fetch_partner_data}: ${response.statusCode}');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${S.current.error}: $e')),
    );
  }
}

class _Partner {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;

  _Partner({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory _Partner.fromJson(Map<String, dynamic> json) {
    return _Partner(
      id: json['id'] ?? 0,
      name: json['name'] ?? S.current.customer,
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
    );
  }
}

//=======================
// Data Models
//=======================
class PartnerDetails {
  final int id;
  final String name;
  final double balance;
  final double amountDueToday;
  final int daysOldestDue;
  final double aov;
  final double oct;
  final int orderCount;
  final int daysSincePurchase;
  final String currency;

  PartnerDetails({
    required this.id,
    required this.name,
    required this.balance,
    required this.amountDueToday,
    required this.daysOldestDue,
    required this.aov,
    required this.oct,
    required this.orderCount,
    required this.daysSincePurchase,
    required this.currency,
  });

  factory PartnerDetails.fromJson(Map<String, dynamic> json) {
    return PartnerDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? S.current.customer,
      balance: (json['balance'] ?? 0.0).toDouble(),
      amountDueToday: (json['amount_due_today'] ?? 0.0).toDouble(),
      daysOldestDue: json['days_oldest_due'] ?? 0,
      aov: (json['aov'] ?? 0.0).toDouble(),
      oct: (json['oct'] ?? 0.0).toDouble(),
      orderCount: json['order_count'] ?? 0,
      daysSincePurchase: json['days_since_purchase'] ?? 0,
      currency: json['currency'] ?? 'EGP',
    );
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
  final String? internalNotes;

  Partner({
    required this.id,
    required this.name,
    this.internalNotes,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? 0,
      name: json['name'] ?? S.current.customer,
      internalNotes: json['internal_notes'],
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
      name: json['name']?['en_US']?['en_US'] ?? S.current.unnamed_product,
      amount: json['amount']?.toDouble() ?? 0.0,
      percentage: json['percentage']?.toDouble() ?? 0.0,
    );
  }
}

//=======================
// Controllers
//=======================
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
        hasError(true);
        return;
      }

      final url = "http://137.184.205.67:2710/api/v1/partners/$partnerId/balance?api_token=$token";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          salesData.value = SalesData.fromJson(jsonData);
        } else {
          hasError(true);
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
        hasError(true);
        return;
      }

      final url = 'http://137.184.205.67:2710/api/v1/partners/$partnerId/balance?api_token=$token';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['partner'] != null) {
          partnerDetails.value = PartnerDetails.fromJson(jsonData['partner']);
        } else {
          hasError(true);
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
}

//=======================
// Customer Detail Screen
//=======================
class CustomerDetailScreen extends StatelessWidget {
  final CustomerController controller = Get.put(CustomerController());
  final PartnerController partnerController = Get.put(PartnerController());
  final LocationService locationService = LocationService();
  final List<Color> chartColors = [
    Color(0xFFFF1744),
    Color(0xFFFFD600),
    Color(0xFF76FF03),
    Color(0xFF00E5FF),
    Color(0xFFD500F9),
    Color(0xFFFF9100),
  ];
  DateTime? lastUpdateTime;

  CustomerDetailScreen({super.key, required int partnerId}) {
    final args = Get.arguments ?? {};
    final id = args['partnerId'] ?? partnerId;
    if (id == 0) {
      print('Warning: ${S.current.no_valid_partner_id}');
    }
    controller.fetchSalesData(id);
    partnerController.fetchPartnerDetails(id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
        ));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Obx(() => Text(
            controller.salesData.value?.partner.name ?? S.of(context).customer,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          )),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_location_alt_outlined, size: 20),
          onPressed: () async {
            final partnerId = Get.arguments['partnerId'] ?? 0;
            print('Attempting to update location for Partner ID: $partnerId');
            if (partnerId == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).invalid_partner_id)),
              );
              return;
            }

            if (lastUpdateTime != null &&
                DateTime.now().difference(lastUpdateTime!).inSeconds < 30) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).wait_30_seconds)),
              );
              return;
            }

            try {
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              final (success, errorMessage) = await locationService.updatePartnerLocation(partnerId);

              Get.back();

              if (success) {
                lastUpdateTime = DateTime.now();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).location_updated_successfully)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage ?? S.of(context).failed_to_update_location)),
                );
              }
            } catch (e) {
              if (Get.isDialogOpen ?? false) {
                Get.back();
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${S.of(context).error}: ${e.toString()}')),
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.navigation, size: 20),
          onPressed: () {
            final partnerId = Get.arguments['partnerId'] ?? 0;
            if (partnerId != 0) {
              launchGoogleMapsByPartnerId(
                partnerId: partnerId,
                context: context,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).invalid_partner_id)),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value) return _buildLoading();
    if (controller.hasError.value || controller.salesData.value == null) {
      return _buildError(context);
    }
    return _buildMainContent(context);
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).no_data_available,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                controller.fetchSalesData(Get.arguments['partnerId'] ?? 0),
            child: Text(S.of(context).retry),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchSalesData(Get.arguments['partnerId'] ?? 11);
        await partnerController
            .fetchPartnerDetails(Get.arguments['partnerId'] ?? 11);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth * 0.04;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final notes = controller.salesData.value?.partner.internalNotes;
                    if (notes?.isNotEmpty ?? false) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildNotesCard(notes!, context),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Payment(),
                  const SizedBox(height: 12),
                  MetricsGrid(),
                  const SizedBox(height: 12),
                  SalesChart(chartColors: chartColors),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotesCard(String notes, BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, size: 16, color: Colors.yellow),
                const SizedBox(width: 8),
                Text(
                  S.of(context).notes,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notes,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

//=======================
// Widgets
//=======================
class Payment extends GetView<CustomerController> {
  const Payment({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final salesData = controller.salesData.value;
      if (salesData == null) return const SizedBox.shrink();

      return InkWell(
        onTap: () async {
          final partnerId = Get.arguments['partnerId'];
          final result = await Get.to<bool>(
            () => InvoicePaymentPage(partnerId: partnerId),
            arguments: {'partnerId': partnerId},
          );

          if (result == true) {
            await Get.find<CustomerController>().fetchSalesData(partnerId);
            await Get.find<PartnerController>().fetchPartnerDetails(partnerId);
          }
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).make_payment,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class SalesChart extends GetView<CustomerController> {
  final List<Color> chartColors;

  const SalesChart({super.key, required this.chartColors});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final salesData = controller.salesData.value;
      if (salesData == null) return const SizedBox.shrink();

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).product_distribution,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildMetricCard(
                    S.of(context).top_product,
                    salesData.products.isNotEmpty
                        ? salesData.products.first.name
                        : S.of(context).na,
                    Icons.star,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: 25,
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
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
                            S.of(context).total,
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${salesData.totalSales.toStringAsFixed(0)} ${salesData.currencySymbol}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
                      padding: const EdgeInsets.only(top: 12),
                      child: _buildProductDetails(
                        controller.selectedProduct.value!,
                        chartColors[controller.selectedIndex.value! %
                            chartColors.length],
                        context,
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
        radius: isSelected ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        showTitle: product.percentage > 5.0,
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Widget _buildProductDetails(Product product, Color color, BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
                S.of(context).percentage, '${product.percentage.toStringAsFixed(1)}%'),
            _buildDetailRow(
                S.of(context).amount,
                '${controller.salesData.value!.currencySymbol} ${product.amount.toStringAsFixed(2)}'),
            _buildDetailRow(
                S.of(context).share_of_total,
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
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MetricsGrid extends StatelessWidget {
  const MetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<PartnerController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final partner = controller.partnerDetails.value;
        if (partner == null) {
          return Center(child: Text(S.of(context).no_data));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return _buildMetricCard(
                      context: context,
                      title: _getMetricTitle(index, partner, context),
                      value: _getMetricValue(index, partner),
                      icon: _getMetricIcon(index),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  S.of(context).details,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 12),
                _buildDetailsCard(
                  context: context,
                  icon: Icons.receipt_long,
                  title: S.of(context).statement_of_account,
                  subtitle: S.of(context).view_transaction_history,
                  onTap: () async {
                    final pickedFromDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      helpText: S.of(context).select_start_date,
                    );

                    if (pickedFromDate != null) {
                      final pickedToDate = await showDatePicker(
                        context: context,
                        initialDate: pickedFromDate,
                        firstDate: pickedFromDate,
                        lastDate: DateTime.now(),
                        helpText: S.of(context).select_end_date,
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
                const SizedBox(height: 12),
                _buildDetailsCard(
                  context: context,
                  icon: Icons.map_outlined,
                  title: S.of(context).visit_information,
                  subtitle: S.of(context).view_customer_visit_patterns,
                  onTap: () {
                    Get.to(() => VisitsScreen(),
                        arguments: {'partnerId': Get.arguments['partnerId']});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getMetricTitle(int index, PartnerDetails partner, BuildContext context) {
    switch (index) {
      case 0:
        return S.of(context).balance;
      case 1:
        return S.of(context).dues;
      case 2:
        return S.of(context).aov;
      case 3:
        return S.of(context).oct;
      case 4:
        return S.of(context).oldest_due;
      case 5:
        return S.of(context).last_purchase;
      default:
        return '';
    }
  }

  String _getMetricValue(int index, PartnerDetails partner) {
    switch (index) {
      case 0:
        return '${partner.currency} ${partner.balance.abs().toStringAsFixed(1)}';
      case 1:
        return '${partner.currency} ${partner.amountDueToday.abs().toStringAsFixed(0)}';
      case 2:
        return '${partner.currency} ${partner.aov.toStringAsFixed(1)}';
      case 3:
        return '${partner.oct.toStringAsFixed(2)} ${S.current.days}';
      case 4:
        return '${partner.daysOldestDue} ${S.current.days}';
      case 5:
        return '${partner.daysSincePurchase} ${S.current.days}';
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
      case 4:
        return Icons.hourglass_top;
      case 5:
        return Icons.history;
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
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: MediaQuery.of(context).size.width * .05,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: MediaQuery.of(context).size.width * .03,
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
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}