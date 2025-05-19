import 'package:boom_solutions_invoice/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class PartnerController extends GetxController {
  var partners = <Partner>[].obs;
  var isLoading = true.obs;
  var selectedPartner = Rx<Partner?>(null);
  var statementData = Rx<Map<String, dynamic>?>(null);
  var isLoadingStatement = false.obs;

  final apiToken = GetStorage().read('token') ?? "";
  final String baseUrl = GetStorage().read('apiUrl') ?? "";

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
    statementData.value = null;
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

class MapScreen extends StatefulWidget {
  MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final controller = Get.put(PartnerController());
  LatLng? userLocation;
  bool locationPermissionGranted = false;
  List<LatLng> routePoints = [];
  bool isDynamicRoute = false;
  bool isLoadingRoute = false;
  
  // No need for OpenRouteService - we'll use direct lines and Google Maps for navigation

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _setupLocationStream();
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationPermissionGranted = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).locationPermissionDenied)),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationPermissionGranted = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).locationPermissionDeniedForever)),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        locationPermissionGranted = true;
      });
      if (controller.selectedPartner.value != null && isDynamicRoute) {
        _fetchRoute(controller.selectedPartner.value!);
      }
    } catch (e) {
      print("Error getting user location: $e");
      setState(() {
        locationPermissionGranted = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).locationError)),
      );
    }
  }

  void _showEnhancedBottomSheet(BuildContext context) {
    if (MediaQuery.of(context).size.width <= 800) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
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

  // Simple function to draw direct line without API call
  void _drawDirectLine(Partner partner) {
    if (userLocation == null) return;
    
    setState(() {
      // Always just draw a direct line from user to partner
      routePoints = [
        userLocation!,
        LatLng(partner.latitude, partner.longitude),
      ];
    });
  }

  Future<void> _fetchRoute(Partner partner) async {
    if (userLocation == null) return;
    
    // First draw a direct line immediately for instant feedback
    _drawDirectLine(partner);
    
    setState(() {
      isLoadingRoute = true;
    });
    
    try {
      // We'll keep the API-based routing code here but it won't actually be used
      // since we're directly drawing lines now. You can implement this if you
      // get the proper API key later.
      
      // Just to make sure we have a line even if API calls fail
      setState(() {
        routePoints = [
          userLocation!,
          LatLng(partner.latitude, partner.longitude),
        ];
      });
    } catch (e) {
      print("Error fetching route: $e");
      
      // Fallback to direct line if exception occurs
      setState(() {
        routePoints = [
          userLocation!,
          LatLng(partner.latitude, partner.longitude),
        ];
      });
    } finally {
      setState(() {
        isLoadingRoute = false;
      });
    }
  }

  void _setupLocationStream() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
      if (isDynamicRoute && controller.selectedPartner.value != null) {
        _fetchRoute(controller.selectedPartner.value!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).partnersMap),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchPartners();
              _getUserLocation();
            },
            tooltip: S.of(context).refresh,
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value && userLocation == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.partners.isEmpty && userLocation == null) {
              return Center(child: Text(S.of(context).noPartnersFound));
            }

            LatLng initialCenter = userLocation ??
                LatLng(
                  controller.partners.isNotEmpty
                      ? controller.partners[0].latitude
                      : 40.7128,
                  controller.partners.isNotEmpty
                      ? controller.partners[0].longitude
                      : -74.0060,
                );

            return FlutterMap(
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 12.0,
                onTap: (_, __) {
                  controller.clearSelection();
                  setState(() {
                    routePoints = [];
                    isDynamicRoute = false;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.mapapp',
                ),
                if (userLocation != null && locationPermissionGranted)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: userLocation!,
                        radius: 5000,
                        color: Colors.blue.withOpacity(0.2),
                        borderColor: Colors.blue,
                        borderStrokeWidth: 2,
                        useRadiusInMeter: true,
                      ),
                      CircleMarker(
                        point: userLocation!,
                        radius: 10000,
                        color: Colors.red.withOpacity(0.1),
                        borderColor: Colors.red,
                        borderStrokeWidth: 2,
                        useRadiusInMeter: true,
                      ),
                    ],
                  ),
                // Draw the route polyline if available
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue.withOpacity(0.8),
                      ),
                    ],
                  ),
                if (userLocation != null && locationPermissionGranted)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: userLocation!,
                        width: 100,
                        height: 60,
                        child: Column(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.blue, size: 35),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "You",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: controller.partners.map((partner) {
                    return Marker(
                      point: LatLng(partner.latitude, partner.longitude),
                      width: 100,
                      height: 60,
                      child: Column(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 35),
                          GestureDetector(
                            onTap: () {
                              controller.selectPartner(partner);
                              setState(() {
                                isDynamicRoute = true;
                                // Draw direct line immediately when partner selected
                                if (userLocation != null) {
                                  routePoints = [
                                    userLocation!,
                                    LatLng(partner.latitude, partner.longitude),
                                  ];
                                }
                              });
                              _showEnhancedBottomSheet(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${partner.name} (${_calculateDistance(partner)})",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                // Show loading indicator while fetching route
                if (isLoadingRoute)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text("Loading route...", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }),
          Obx(() {
            if (controller.selectedPartner.value != null &&
                MediaQuery.of(context).size.width > 800) {
              return Positioned(
                right: Directionality.of(context) == TextDirection.rtl ? null : 16,
                left: Directionality.of(context) == TextDirection.rtl ? 16 : null,
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
  // Launch Google Maps for navigation
  
        ],
      ),
    );
  }
  

  String _calculateDistance(Partner partner) {
    if (userLocation == null) return "Unknown";
    final distance = Distance();
    final meters = distance(
      userLocation!,
      LatLng(partner.latitude, partner.longitude),
    );
    if (meters < 1000) {
      return "${meters.toStringAsFixed(0)} m";
    } else {
      return "${(meters / 1000).toStringAsFixed(2)} km";
    }
  }

  Widget _buildPartnerInfoPanel(BuildContext context,
      [ScrollController? scrollController]) {
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
                // IconButton(
                //   icon: Icon(
                //     isDynamicRoute ? Icons.directions_off : Icons.directions,
                //     color: Colors.indigo,
                //   ),
                //   onPressed: () {
                //     setState(() {
                //       isDynamicRoute = !isDynamicRoute;
                //       if (isDynamicRoute && userLocation != null) {
                //         // Draw direct line
                //         routePoints = [
                //           userLocation!,
                //           LatLng(partner.latitude, partner.longitude),
                //         ];
                //       } else {
                //         routePoints = [];
                //       }
                //     });
                //   },
                //   tooltip: S.of(context).toggleRouteMode,
                // ),
                IconButton(
                  icon: const Icon(
                    Icons.map,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    // _launchGoogleMapsNavigation(partner);
                  },
                  tooltip: "Navigate with Google Maps",
                ),
                if (scrollController != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    tooltip: S.of(context).close,
                  ),
              ],
            ),
            const Divider(height: 24),
            Text(
              "Distance: ${_calculateDistance(partner)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            if (controller.isLoadingStatement.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.statementData.value != null)
              _buildStatementSection(context, controller.statementData.value!),
          ],
        ),
      );
    });
  }

  Widget _buildStatementSection(BuildContext context, Map<String, dynamic> data) {
    final statement = data['statement'];
    final transactions = statement['transactions'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          title: S.of(context).statementSummary,
          icon: Icons.receipt_long,
          color: Colors.green,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(S.of(context).dateRange,
                  "${statement['date_from']} — ${statement['date_to']}"),
              _buildInfoRow(S.of(context).currency, statement['currency']),
              _buildInfoRow(
                S.of(context).endingBalance,
                "${statement['ending_balance'].toStringAsFixed(2)}",
                valueStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: S.of(context).transactions,
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
                        S.of(context).date,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        S.of(context).debit,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        S.of(context).credit,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        S.of(context).balance,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${S.of(context).reference}: ${transaction['reference']}",
                                  style: const TextStyle(
                                    fontSize: 11,
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
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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