
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class PartnerController extends GetxController {
  var partners = <Partner>[].obs;
  var isLoading = true.obs;
  var selectedPartner = Rx<Partner?>(null);
  var statementData = Rx<Map<String, dynamic>?>(null);
  var isLoadingStatement = false.obs;

  final String baseUrl = 'http://137.184.205.67:2710';
  final apiToken = GetStorage().read('token') ?? "";

  @override
  void onInit() {
    super.onInit();
    fetchPartners();
    setupContinuousFetching();
  }

  void setupContinuousFetching() {
    fetchPartnersContinuously();
  }

  Future<void> fetchPartners() async {
    try {
      isLoading.value = true;
      final url = Uri.parse('$baseUrl/api/v1/partners/map').replace(
        queryParameters: {'api_token': apiToken},
      );
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> partnerList = jsonData['partners'];
        partners.value = partnerList.map((e) => Partner.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load partners: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching partners: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchPartnersContinuously() {
    Future.delayed(const Duration(minutes: 10), () async {
      await fetchPartners();
      fetchPartnersContinuously();
    });
  }

  Future<bool> fetchPartnerStatement(Partner partner) async {
    int retries = 3;
    while (retries > 0) {
      try {
        isLoadingStatement.value = true;
        final url = Uri.parse('$baseUrl/api/v1/partners/${partner.id}/statement').replace(
          queryParameters: {'api_token': apiToken},
        );
        final response = await http.get(url).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success']) {
            statementData.value = data;
            return true;
          }
        }
        retries--;
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print("Error fetching statement: $e");
        retries--;
        await Future.delayed(const Duration(seconds: 1));
      } finally {
        isLoadingStatement.value = false;
      }
    }
    return false;
  }

  void selectPartner(Partner partner) {
    selectedPartner.value = partner;
    statementData.value = null; // Clear previous data
    fetchPartnerStatement(partner);
  }

  void clearSelection() {
    selectedPartner.value = null;
    statementData.value = null;
  }
}

class Partner {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  Partner({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }
}

class MapScreen extends StatelessWidget {
  MapScreen({super.key});
  
  final controller = Get.put(PartnerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Partners Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchPartners();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.partners.isEmpty) {
              return const Center(child: Text("No partners found."));
            }

            return FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  controller.partners[0].latitude,
                  controller.partners[0].longitude,
                ),
                initialZoom: 7.0,
                onTap: (_, __) => controller.clearSelection(),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.mapapp',
                ),
                MarkerLayer(
                  markers: controller.partners.map((partner) {
                    return Marker(
                      point: LatLng(partner.latitude, partner.longitude),
                      width: 100,
                      height: 60,
                      child: Column(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 35),
                          GestureDetector(
                            onTap: () {
                              controller.selectPartner(partner);
                              _showEnhancedBottomSheet(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                partner.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          }),
          
          Obx(() {
            if (controller.selectedPartner.value != null && 
                MediaQuery.of(context).size.width > 800) {
              return Positioned(
                right: 16,
                top: 16,
                width: 350,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildPartnerInfoPanel(context),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  void _showEnhancedBottomSheet(BuildContext context) {
    if (MediaQuery.of(context).size.width <= 800) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        // backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: _buildPartnerInfoPanel(context, scrollController),
              );
            },
          );
        },
      );
    }
  }

  Widget _buildPartnerInfoPanel(BuildContext context, [ScrollController? scrollController]) {
    return Obx(() {
      final partner = controller.selectedPartner.value;
      if (partner == null) return const SizedBox.shrink();

      return SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (scrollController != null)
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

            Row(
              children: [
                const Icon(Icons.business, size: 28, color: Colors.indigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    partner.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                if (scrollController != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
            
            const Divider(height: 24),
            
            // _buildInfoCard(
            //   title: "Partner Details",
            //   icon: Icons.info_outline,
            //   color: Colors.blue,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       _buildInfoRow("ID", "${partner.id}"),
            //       _buildInfoRow("Location", 
            //         "${partner.latitude.toStringAsFixed(6)}, ${partner.longitude.toStringAsFixed(6)}"),
            //     ],
            //   ),
            // ),
            
            const SizedBox(height: 16),
            
            if (controller.isLoadingStatement.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.statementData.value != null)
              _buildStatementSection(controller.statementData.value!),
          ],
        ),
      );
    });
  }
  
  Widget _buildStatementSection(Map<String, dynamic> data) {
    final statement = data['statement'];
    final transactions = statement['transactions'] as List<dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          title: "Statement Summary",
          icon: Icons.receipt_long,
          color: Colors.green,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Date Range  ", "${statement['date_from']} — ${statement['date_to']}"),
              _buildInfoRow("Currency  ", statement['currency']),
                _buildInfoRow("Ending Balance  ", 
                  "  ${statement['ending_balance'].toStringAsFixed(2)}", 
                  valueStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildInfoCard(
          title: "Transactions",
          icon: Icons.sync_alt,
          color: Colors.deepOrange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "DATE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          // color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "DEBIT",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          // color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "CREDIT",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          // color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "BALANCE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          // color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              ...transactions.map<Widget>((transaction) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction['date'],
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  transaction['description'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    // color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Ref: ${transaction['reference']}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    // color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              transaction['debit'].toString(),
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              transaction['credit'].toString(),
                              style: const TextStyle(color: Colors.green),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              transaction['balance'].toString(),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}