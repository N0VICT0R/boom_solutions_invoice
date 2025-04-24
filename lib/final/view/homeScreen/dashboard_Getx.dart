import 'dart:async';
import 'dart:convert';
import 'package:boom_solutions_invoice/final/controller/auth_controller.dart';
import 'package:boom_solutions_invoice/final/controller/dashbord_Controller.dart';
import 'package:boom_solutions_invoice/final/controller/themeController.dart';
import 'package:boom_solutions_invoice/final/view/homeScreen/homeScreenResponse.dart';
import 'package:boom_solutions_invoice/widgets/notes/notes.dart';
import 'package:boom_solutions_invoice/widgets/salesChart.dart'
    show SalesChart, SalesChart22, SalesChartCard, SalesChartView;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Utility for responsive font sizes
double getResponsiveFontSize(BuildContext context, double baseFontSize) {
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth / 400;
  return (baseFontSize * scaleFactor).clamp(baseFontSize * 0.8, baseFontSize * 1.2);
}

// Utility for formatting numbers with k, M, B suffixes
String formatNumber(double value, {bool isCurrency = true}) {
  if (value < 1000) {
    // For small numbers, show as is with two decimal places for currency
    if (isCurrency) {
      return NumberFormat("#,##0.00").format(value);
    }
    return value.toStringAsFixed(0);
  }

  const suffixes = ['k', 'M', 'B', 'T'];
  int suffixIndex = -1;
  double scaledValue = value;

  while (scaledValue >= 1000 && suffixIndex < suffixes.length - 1) {
    scaledValue /= 1000;
    suffixIndex++;
  }

  // Format to two decimal places
  String formatted = NumberFormat("#,##0.00").format(scaledValue);
  // Remove trailing .00 if the value is effectively an integer
  if (formatted.endsWith('.00')) {
    formatted = formatted.substring(0, formatted.length - 3);
  }
  return '$formatted${suffixes[suffixIndex]}';
}

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  String selectedRange = '7d';
  List<Map<String, dynamic>> fullData = [];
  List<Map<String, dynamic>> displayData = [];
  DateTime? startDate;
  DateTime? endDate;
  bool showDatePicker = false;
  HomeScreenResponse? homeData;
  bool isLoading = true;
  String? errorMessage;
  bool isRealTimeEnabled = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _filterDataByTimeRange('7d');
    _fetchHomeScreenData();
    _startPolling();
  }

  Future<void> _fetchHomeScreenData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
        final authController = Get.find<AuthController>();
      final baseUrl = 'https://onix.boom-solutions.co/'; // Replace with actual base URL
      final token = GetStorage().read('token') ?? '';
      final url =
          Uri.parse('$baseUrl/api/v1/users/2/home-screen?api_token=$token');
     

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          homeData = HomeScreenResponse.fromJson(jsonData);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _startPolling() {
    if (isRealTimeEnabled) {
      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _fetchHomeScreenData();
      });
    }
  }

  void _toggleRealTime(bool value) {
    setState(() {
      isRealTimeEnabled = value;
      if (isRealTimeEnabled) {
        _startPolling();
      } else {
        _pollingTimer?.cancel();
      }
    });
  }

  void _filterDataByTimeRange(String range) {
    final today = DateTime.now();
    DateTime filterDate = today;

    switch (range) {
      case '7d':
        filterDate = today.subtract(const Duration(days: 7));
        break;
      case '1m':
        filterDate = DateTime(today.year, today.month - 1, today.day);
        break;
      case '3m':
        filterDate = DateTime(today.year, today.month - 3, today.day);
        break;
      case 'q':
        filterDate = DateTime(today.year, today.month - 3, today.day);
        break;
      case '1y':
        filterDate = DateTime(today.year - 1, today.month, today.day);
        break;
      case 'custom':
        if (startDate != null && endDate != null) {
          setState(() {
            displayData = fullData.where((item) {
              final itemDate = item['date'] as DateTime;
              return (itemDate.isAfter(startDate!) ||
                      itemDate.isAtSameMomentAs(startDate!)) &&
                  (itemDate.isBefore(endDate!) ||
                      itemDate.isAtSameMomentAs(endDate!));
            }).toList();
          });
          return;
        }
        break;
      default:
        filterDate = today.subtract(const Duration(days: 7));
    }

    setState(() {
      displayData = fullData.where((item) {
        final itemDate = item['date'] as DateTime;
        return itemDate.isAfter(filterDate) ||
            itemDate.isAtSameMomentAs(filterDate);
      }).toList();
    });
  }

  String _formatDateRange() {
    if (selectedRange == 'custom' && startDate != null && endDate != null) {
      return '${DateFormat('MMM d').format(startDate!)} - ${DateFormat('MMM d').format(endDate!)}';
    }

    final Map<String, String> labels = {
      '7d': 'Last 7 Days',
      '1m': 'Last Month',
      '3m': 'Last 3 Months',
      'q': 'Last Quarter',
      '1y': 'Last Year',
    };

    return labels[selectedRange] ?? 'Custom';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Get.offNamed('/dashboard');
        break;
      case 1:
        Get.toNamed('/webView', preventDuplicates: true);
        break;
      case 2:
        Get.toNamed('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchHomeScreenData,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 10.0,
            vertical: 12.0,
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 20, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                              child: Text(
                                'Welcome back !',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: getResponsiveFontSize(context, 16),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 25),
                              child: Text(
                                '${authController.currentUser.value?.name ?? 'Guest'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: getResponsiveFontSize(context, 24),
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              value: isRealTimeEnabled,
                              onChanged: _toggleRealTime,
                              activeColor: Colors.blue,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.notifications_none_rounded,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SalesChartView(),
                  const SizedBox(height: 10),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                          ? Center(
                              child: Column(
                                children: [
                                  Text(errorMessage!),
                                  ElevatedButton(
                                    onPressed: _fetchHomeScreenData,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isTablet ? 4 : 2,
                                childAspectRatio: isTablet ? 1.5 : 1.8,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                final metrics = [
                                  {
                                    'title': 'Sales Target',
                                    'value':
                                        '\$${formatNumber(homeData!.monthlySales.metrics.totalAmount)}/\$${formatNumber(homeData!.monthlySales.metrics.monthTarget)} (${(homeData!.monthlySales.metrics.achievementPercentage).toStringAsFixed(2)}%)',
                                  },
                                  {
                                    'title': 'Pending Collection',
                                    'value':
                                        '\$${formatNumber(homeData!.receivables.amountDueToday)} From ${homeData!.receivables.partnerCount} partners',
                                  },
                                  {
                                    'title': 'Completed Visits',
                                    'value':
                                        '${homeData!.additionalMetrics.todayVisits}',
                                  },
                                  {
                                    'title': 'New Customers',
                                    'value':
                                        '${homeData!.additionalMetrics.newCustomersThisMonth}',
                                  },
                                ];

                                return _MetricCard(
                                  title: metrics[index]['title']!,
                                  value: metrics[index]['value']!,
                                  shade: index * 12,
                                );
                              },
                            ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 4 : 2,
                      childAspectRatio: isTablet ? 2.8 : 3.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final actions = [
                        {
                          'icon': Icons.store,
                          'label': 'Stock',
                          'action': () {
                            Get.find<DashboardController>().createNewDeal();
                            Get.toNamed('/Stock');
                          }
                        },
                        {
                          'icon': Icons.payment,
                          'label': 'Receive Payment',
                          'action': () =>
                              Get.find<DashboardController>().collectPayment()
                        },
                        {
                          'icon': Icons.pin_drop,
                          'label': 'Nearby Customers',
                          'action': () => Get.toNamed('/NearByCustomer')
                        },
                        {
                          'icon': Icons.people_alt_outlined,
                          'label': 'Customers',
                          'action': () => Get.toNamed('/customers')
                        },
                      ];

                      return _ActionButton(
                        icon: actions[index]['icon'] as IconData,
                        label: actions[index]['label'] as String,
                        shade: (index * 8) + 30,
                        onTap: actions[index]['action'] as VoidCallback,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  NotesWidget(
                    height: screenSize.height * (isTablet ? 0.39 : 0.35),
                    scrollController: _scrollController,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 8,
        backgroundColor: isDark ? Colors.black : Colors.white,
        selectedItemColor: isDark ? Colors.white : Colors.black,
        unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
        selectedLabelStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 12),
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 12),
        ),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_outlined),
            activeIcon: Icon(Icons.person_pin),
            label: 'Odoo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showCustomDatePicker() async {
    startDate ??= DateTime.now().subtract(const Duration(days: 7));
    endDate ??= DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate!, end: endDate!),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        _filterDataByTimeRange('custom');
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final int shade;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.shade,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark
        ? (shade % 2 == 0 ? Colors.grey[800]! : Colors.grey[900]!)
        : (shade % 2 == 0 ? Colors.white : Colors.grey[100]!);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: getResponsiveFontSize(context, 10),
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: getResponsiveFontSize(context, 16),
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int shade;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.shade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int calculatedShade = (shade + (isDark ? 600 : 200)).clamp(0, 900);
    final int normalizedShade = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]
        .reduce((a, b) => (calculatedShade - a).abs() < (calculatedShade - b).abs() ? a : b);
    final buttonColor = Colors.grey[normalizedShade]!;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : Colors.black,
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: getResponsiveFontSize(context, 10),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}