import 'dart:async';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:boom_solutions_invoice/CustomerDetail/Screen/CustomerListScreen.dart';
import 'package:boom_solutions_invoice/final/controller/auth_controller.dart';
import 'package:boom_solutions_invoice/final/controller/dashbord_Controller.dart';
import 'package:boom_solutions_invoice/final/view/homeScreen/homeScreenResponse.dart';
import 'package:boom_solutions_invoice/final/view/web_view.dart';
import 'package:boom_solutions_invoice/screens/SetteingsScreen.dart';
import 'package:boom_solutions_invoice/widgets/notes/notes.dart';
import 'package:boom_solutions_invoice/widgets/salesChart.dart'
    show SalesChartView, SalesChartController;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

// Utility for responsive font sizes
double getResponsiveFontSize(BuildContext context, double baseFontSize) {
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth / 400;
  return (baseFontSize * scaleFactor).clamp(baseFontSize * 0.8, baseFontSize * 1.2);
}

// Utility for formatting numbers with k, M, B suffixes
String formatNumber(double value, {bool isCurrency = true}) {
  if (value < 1000) {
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
  String formatted = NumberFormat("#,##0.00").format(scaledValue);
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

class _SalesDashboardState extends State<SalesDashboard> with SingleTickerProviderStateMixin {
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
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _filterDataByTimeRange('7d');
    _fetchAllData().then((_) {
      _animationController.forward();
    });
    _startPolling();
  }

  Future<void> _fetchAllData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _fetchHomeScreenData();
      final salesChartController = Get.find<SalesChartController>();
      await salesChartController.fetchData();
      await Get.find<DashboardController>().fetchNotes();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error refreshing data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchHomeScreenData() async {
    try {
      final authController = Get.find<AuthController>();
      final baseUrl = 'https://onix.boom-solutions.co/';
      final token = GetStorage().read('token') ?? '';
      final url = Uri.parse('$baseUrl/api/v1/users/2/home-screen?api_token=$token');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          homeData = HomeScreenResponse.fromJson(jsonData);
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  void _startPolling() {
    if (isRealTimeEnabled) {
      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _fetchAllData();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();

    // Minimalist color palette
    final Color bgColor = isDark ? Color(0xFF121212) : Color(0xFFFAFAFA);
    final Color cardBackground = isDark ? Color(0xFF1A1A1A) : Colors.white;
    final Color cardBorder = isDark ? Color(0xFF2A2A2A) : Color(0xFFE0E0E0);
    final Color primaryTextColor = isDark ? Colors.white : Color(0xFF212121);
    final Color secondaryTextColor = isDark ? Color(0xFFB0B0B0) : Color(0xFF757575);
    final Color accentColor = isDark ? Color(0xFF4FC3F7) : Color(0xFF1976D2);
    final Color shimmerBaseColor = isDark ? Color(0xFF262626) : Colors.grey[300]!;
    final Color shimmerHighlightColor = isDark ? Color(0xFF303030) : Colors.grey[100]!;

    final List<Widget> pages = [
      SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchAllData,
          color: accentColor,
          backgroundColor: cardBackground,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    FadeInDown(
                      duration: Duration(milliseconds: 400),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                  fontSize: getResponsiveFontSize(context, 13),
                                  color: secondaryTextColor,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${authController.currentUser.value?.name ?? 'admin'}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: getResponsiveFontSize(context, 20),
                                  color: primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          // Container(
                          //   width: 40,
                          //   height: 40,
                          //   decoration: BoxDecoration(
                          //     color: accentColor,
                          //     shape: BoxShape.circle,
                          //   ),
                          //   child: Icon(
                          //     Icons.notifications_none_rounded,
                          //     color: Colors.white,
                          //     size: 20,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Sales Chart
                    FadeInUp(
                      duration: Duration(milliseconds: 500),
                      from: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: cardBackground,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SalesChartView(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Loading or Error State
                    isLoading
                        ? _buildShimmerLoading(shimmerBaseColor, shimmerHighlightColor, isTablet)
                        : errorMessage != null
                            ? _buildErrorView(errorMessage!, accentColor, isDark)
                            : FadeInUp(
                                duration: Duration(milliseconds: 600),
                                from: 30,
                                child: Column(
                                  children: [
                                    // Key Metrics Header
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     // Text(
                                    //     //   'Key Metrics',
                                    //     //   style: GoogleFonts.poppins(
                                    //     //     fontWeight: FontWeight.w600,
                                    //     //     fontSize: getResponsiveFontSize(context, 16),
                                    //     //     color: primaryTextColor,
                                    //     //   ),
                                    //     // ),
                                    //     // Text(
                                    //     //   'Today',
                                    //     //   style: GoogleFonts.poppins(
                                    //     //     fontWeight: FontWeight.w500,
                                    //     //     fontSize: getResponsiveFontSize(context, 13),
                                    //     //     color: accentColor,
                                    //     //   ),
                                    //     // ),
                                    //   ],
                                    // ),
                                    SizedBox(height: 12),

                                    // Metric Cards - Grid Layout
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: isTablet ? 2 : 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 1.0,
                                      ),
                                      itemCount: 4,
                                      itemBuilder: (context, index) {
                                        return FadeInUp(
                                          duration: Duration(milliseconds: 600 + index * 100),
                                          from: 30,
                                          child: _MetricCard(
                                            title: [
                                              'Sales Target',
                                              'Collections',
                                              'Visits',
                                              'New Customers'
                                            ][index],
                                            value: [
                                              '${formatNumber(homeData!.monthlySales.metrics.totalAmount)}/${formatNumber(homeData!.monthlySales.metrics.monthTarget)}',
                                              formatNumber(homeData!.receivables.amountDueToday),
                                              '${homeData!.additionalMetrics.todayVisits}',
                                              '${homeData!.additionalMetrics.newCustomersThisMonth}',
                                            ][index],
                                            subtitle: [
                                              '${(homeData!.monthlySales.metrics.achievementPercentage).toStringAsFixed(1)}% of target',
                                              '${homeData!.receivables.partnerCount} partners',
                                              'Completed today',
                                              'This month',
                                            ][index],
                                            icon: [
                                              Icons.show_chart,
                                              Icons.account_balance_wallet,
                                              Icons.check_circle_outline,
                                              Icons.person_add_alt,
                                            ][index],
                                            iconColor: [
                                              homeData!.monthlySales.metrics.achievementPercentage >= 80
                                                  ? Colors.green[400]!
                                                  : Colors.orange[400]!,
                                              Colors.amber[400]!,
                                              Colors.green[400]!,
                                              Colors.blue[400]!,
                                            ][index],
                                            isDark: isDark,
                                            accentColor: accentColor,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                    SizedBox(height: 20),
                    
                    // Quick Actions
                    FadeInUp(
                      duration: Duration(milliseconds: 700),
                      from: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: getResponsiveFontSize(context, 16),
                              color: primaryTextColor,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.place,
                                  label: 'Nearby Customers',
                                  onTap: () => Get.toNamed('/NearByCustomer'),
                                  isDark: isDark,
                                  accentColor: accentColor,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.inventory_2,
                                  label: 'Stock',
                                  onTap: () {
                                    Get.find<DashboardController>().createNewDeal();
                                    Get.toNamed('/Stock');
                                  },
                                  isDark: isDark,
                                  accentColor: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Notes Section
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      from: 30,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            height: screenSize.height * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: cardBackground,
                              border: Border.all(color: cardBorder, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: NotesWidget(
                                height: screenSize.height * 0.3,
                                scrollController: _scrollController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      Center(child: CustomersListScreen()),
      Center(child: WebViewScreen(url: GetStorage().read('webViewUrl') ?? 'http://137.184.205.67:2710/web/login?redirect=%2Fodoo%3F')),
      Center(child: SettingsScreen()),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: BouncingScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDark, accentColor),
    );
  }

  Widget _buildShimmerLoading(Color baseColor, Color highlightColor, bool isTablet) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics title shimmer
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 12),
          
          // Metric cards shimmer
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 2 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 90,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          
          // Quick Actions shimmer
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              // Expanded(
              //   child: Container(
              //     height: 46,
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //   ),
              // ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message, Color accentColor, bool isDark) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.red[400],
                fontSize: getResponsiveFontSize(context, 14),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _ActionButton(
            icon: Icons.refresh,
            label: 'Retry',
            onTap: _fetchAllData,
            isDark: isDark,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isDark, Color accentColor) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', accentColor, isDark),
          _buildNavItem(1, Icons.people_alt_outlined, Icons.people_alt, 'Customers', accentColor, isDark),
          _buildNavItem(2, Icons.public_outlined, Icons.public, 'Odoo', accentColor, isDark),
          _buildNavItem(3, Icons.settings_outlined, Icons.settings, 'Settings', accentColor, isDark),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, Color accentColor, bool isDark) {
    bool isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? accentColor.withOpacity(0.1) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? accentColor : isDark ? Color(0xFF757575) : Color(0xFFBDBDBD),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? accentColor : isDark ? Color(0xFF757575) : Color(0xFFBDBDBD),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pollingTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final Color accentColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isDark ? Color(0xFF1A1A1A) : Colors.white;
    final Color textColor = isDark ? Colors.white : Color(0xFF212121);
    final Color subtitleColor = isDark ? Color(0xFFB0B0B0) : Color(0xFF757575);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            // Spacer(),
            SizedBox(height: 15,),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: getResponsiveFontSize(context, 15),
                color: subtitleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: textColor,
                fontSize: getResponsiveFontSize(context, 18),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: getResponsiveFontSize(context, 13),
                color: subtitleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
  final VoidCallback onTap;
  final bool isDark;
  final Color accentColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? accentColor.withOpacity(0.2) : accentColor,
        foregroundColor: isDark ? Colors.white : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: getResponsiveFontSize(context, 14),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
