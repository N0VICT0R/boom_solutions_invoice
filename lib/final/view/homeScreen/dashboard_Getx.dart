
import 'dart:async';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:boom_solutions_invoice/CustomerDetail/Screen/CustomerListScreen.dart';
import 'package:boom_solutions_invoice/final/controller/auth_controller.dart';
import 'package:boom_solutions_invoice/final/controller/dashbord_Controller.dart';
import 'package:boom_solutions_invoice/final/view/web_view.dart';
import 'package:boom_solutions_invoice/generated/l10n.dart';
import 'package:boom_solutions_invoice/screens/SetteingsScreen.dart';
import 'package:boom_solutions_invoice/widgets/notes/notes.dart';
import 'package:boom_solutions_invoice/widgets/salesChart.dart' show SalesChartView, SalesChartController;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

double getResponsiveFontSize(BuildContext context, double baseFontSize) {
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth / 400;
  return (baseFontSize * scaleFactor).clamp(baseFontSize * 0.8, baseFontSize * 1.2);
}

String formatNumber(double value, {bool isCurrency = true}) {
  final bool isArabic = Get.locale?.languageCode == 'ar';
  if (value < 1000) {
    if (isCurrency) {
      return intl.NumberFormat("#,##0.00").format(value);
    }
    return value.toStringAsFixed(0);
  }
  if (isArabic) {
    const suffixes = [' ألف', ' مليون', ' مليار', ' تريليون'];
    int suffixIndex = -1;
    double scaledValue = value;
    while (scaledValue >= 1000 && suffixIndex < suffixes.length - 1) {
      scaledValue /= 1000;
      suffixIndex++;
    }
    String formatted = intl.NumberFormat("#,##0.00").format(scaledValue);
    if (formatted.endsWith('.00')) {
      formatted = formatted.substring(0, formatted.length - 3);
    }
    return '$formatted${suffixes[suffixIndex]}';
  }
  const suffixes = ['k', 'M', 'B', 'T'];
  int suffixIndex = -1;
  double scaledValue = value;
  while (scaledValue >= 1000 && suffixIndex < suffixes.length - 1) {
    scaledValue /= 1000;
    suffixIndex++;
  }
  String formatted = intl.NumberFormat("#,##0.00").format(scaledValue);
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
  bool isOffline = false;
  Timer? _pollingTimer;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  DateTime _currentDateTime = DateTime.now();
  Timer? _clockTimer;
  String? _csrfToken;
  bool isBalanceVisible = false;
  int _retryCount = 0;

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
    _fetchCsrfToken().then((_) => _fetchAllData()).then((_) {
      _animationController.forward();
    }).catchError((_) {});
    _startPolling();
    _startClock();
    _checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool wasOffline = isOffline;
      setState(() {
        isOffline = results.every((result) => result == ConnectivityResult.none);
      });
      if (wasOffline && !isOffline) {
        _fetchCsrfToken().then((_) => _fetchAllData());
      } else if (isOffline && _selectedIndex != 2) {
        _onItemTapped(2);
      }
    });
  }

  void _startClock() {
    if (isRealTimeEnabled) {
      _clockTimer?.cancel();
      _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _currentDateTime = DateTime.now();
        });
      });
    }
  }

  String _formatDateTime(DateTime dateTime, bool isArabic) {
    final dateFormat = isArabic
        ? intl.DateFormat('dd MMMM yyyy', 'ar')
        : intl.DateFormat('dd MMMM yyyy', 'en');
    final timeFormat = intl.DateFormat('hh:mm a', isArabic ? 'ar' : 'en');
    return '${dateFormat.format(dateTime)} ${timeFormat.format(dateTime)} EEST';
  }

  Future<void> _checkConnectivity() async {
    var connectivityResults = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = connectivityResults.every((result) => result == ConnectivityResult.none);
    });
    if (isOffline && _selectedIndex != 2) {
      _onItemTapped(2);
    }
  }

  Future<void> _fetchCsrfToken() async {
    try {
      final apiUrl = GetStorage().read("apiUrl") ?? "";
      if (apiUrl.isEmpty) return;
      final url = Uri.parse('$apiUrl/api/v1/csrf-token');
      final response = await http.get(url).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _csrfToken = jsonData['csrf_token'];
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch CSRF token: $e');
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final authController = Get.find<AuthController>();
      final apiUrl = GetStorage().read("apiUrl") ?? "";
      final userId = GetStorage().read('user_id');
      if (apiUrl.isEmpty || userId == null) return false;
      final url = Uri.parse('$apiUrl/api/v1/users/$userId/refresh-token');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_csrfToken != null) 'X-CSRF-Token': _csrfToken!,
        },
        body: jsonEncode({}),
      ).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final newToken = jsonData['token'];
        GetStorage().write('token', newToken);
        await _fetchCsrfToken();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return false;
    }
  }

  Future<void> _fetchAllData() async {
    if (isOffline) {
      setState(() {
        errorMessage = S.of(context).checkConnection ?? 'Check your connection';
        isLoading = false;
      });
      if (_selectedIndex != 2) _onItemTapped(2);
      return;
    }

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
        _retryCount = 0;
      });
    } catch (e) {
      if (e.toString().contains('400') && e.toString().contains('invalid CSRF token')) {
        if (await _refreshToken()) {
          await _fetchAllData();
          return;
        }
      }
      if (_retryCount < 3) {
        _retryCount++;
        debugPrint('Retrying fetchAllData, attempt $_retryCount of 3');
        await Future.delayed(Duration(seconds: 4));
        await _fetchAllData();
      } else {
        setState(() {
          errorMessage = S.of(context).checkConnection ?? 'Check your connection';
          isLoading = false;
        });
        if (_selectedIndex != 2) _onItemTapped(2);
      }
    }
  }

  Future<void> _fetchHomeScreenData() async {
    try {
      final authController = Get.find<AuthController>();
      final apiUrl = GetStorage().read("apiUrl") ?? "";
      final token = GetStorage().read('token') ?? '';
      final userId = GetStorage().read('user_id');
      if (apiUrl.isEmpty || token.isEmpty || userId == null) {
        throw Exception('Missing API URL, token, or user ID');
      }
      final url = Uri.parse('$apiUrl/api/v1/users/$userId/home-screen?api_token=$token');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          if (_csrfToken != null) 'X-CSRF-Token': _csrfToken!,
        },
      ).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          homeData = HomeScreenResponse.fromJson(jsonData);
        });
      } else if (response.statusCode == 400 && response.body.contains('invalid CSRF token')) {
        throw Exception('400: invalid CSRF token');
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
      _startClock();
    }
  }

  void _toggleRealTime(bool value) {
    setState(() {
      isRealTimeEnabled = value;
      if (isRealTimeEnabled) {
        _startPolling();
      } else {
        _pollingTimer?.cancel();
        _clockTimer?.cancel();
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
              return (itemDate.isAfter(startDate!) || itemDate.isAtSameMomentAs(startDate!)) &&
                  (itemDate.isBefore(endDate!) || itemDate.isAtSameMomentAs(endDate!));
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
        return itemDate.isAfter(filterDate) || itemDate.isAtSameMomentAs(filterDate);
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    debugPrint('Navigation tapped: index $index');
    if (isOffline && index != 2) {
      debugPrint('Offline mode: cannot navigate to index $index');
      return;
    }
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
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final authController = Get.find<AuthController>();
    final l10n = S.of(context);
    final bool isRTL = Get.locale?.languageCode == 'ar';
    final bool isArabic = isRTL;

    final List<Widget> pages = [
      isOffline
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                child: _buildShimmerLoading(isTablet),
              ),
            )
          : Scaffold(
              backgroundColor: theme.colorScheme.background,
            body: SafeArea(
              
                child: RefreshIndicator(
                  onRefresh: _fetchAllData,
                  color: theme.colorScheme.primary,
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
                            FadeInDown(
                              duration: Duration(milliseconds: 400),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.welcomeBack,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          fontSize: getResponsiveFontSize(context, 13),
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        authController.currentUser.value?.name ?? 'admin',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: getResponsiveFontSize(context, 20),
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _formatDateTime(_currentDateTime, isArabic),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          fontSize: getResponsiveFontSize(context, 12),
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isBalanceVisible ? Icons.visibility_off : Icons.account_balance_wallet,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                                    tooltip: isBalanceVisible ? l10n.hideBalance : l10n.currentBalance,
                                    onPressed: () {
                                      setState(() {
                                        isBalanceVisible = !isBalanceVisible;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            AnimatedCrossFade(
                              firstChild: Container(),
                              secondChild: FadeInDown(
                                duration: Duration(milliseconds: 450),
                                from: 30,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: theme.colorScheme.surface,
                                    border: Border.all(color: theme.colorScheme.outline, width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.shadow.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: isLoading
                                          ? Shimmer.fromColors(
                                              baseColor: theme.colorScheme.surfaceContainer,
                                              highlightColor: theme.colorScheme.surfaceContainerHigh,
                                              child: _buildBalanceShimmer(),
                                            )
                                          : (homeData?.cashJournal?.balance != null && errorMessage == null)
                                              ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          l10n.currentBalance,
                                                          style: GoogleFonts.poppins(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: getResponsiveFontSize(context, 16),
                                                            color: theme.colorScheme.onSurface,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              formatNumber(homeData!.cashJournal!.balance),
                                                              style: GoogleFonts.poppins(
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: getResponsiveFontSize(context, 20),
                                                                color: theme.colorScheme.primary,
                                                              ),
                                                            ),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              homeData?.cashJournal?.currencySymbol ?? 'LE',
                                                              style: GoogleFonts.poppins(
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: getResponsiveFontSize(context, 16),
                                                                color: theme.colorScheme.onSurfaceVariant,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme.primary.withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.account_balance,
                                                        size: 24,
                                                        color: theme.colorScheme.primary,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  children: [
                                                    Text(
                                                      l10n.dataLoadError,
                                                      style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: getResponsiveFontSize(context, 14),
                                                        color: theme.colorScheme.error,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    ElevatedButton(
                                                      onPressed: _fetchAllData,
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: theme.colorScheme.primary,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        l10n.retry,
                                                        style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: getResponsiveFontSize(context, 12),
                                                          color: theme.colorScheme.onPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                    ),
                                  ),
                                ),
                              ),
                              crossFadeState: isBalanceVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                              duration: Duration(milliseconds: 300),
                            ),
                            SizedBox(height: isBalanceVisible ? 20 : 0),
                                 FadeInUp(
                              duration: Duration(milliseconds: 500),
                              from: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: theme.colorScheme.surface,
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
                            isLoading
                                ? _buildShimmerLoading(isTablet)
                                : errorMessage != null
                                    ? _buildErrorView(errorMessage!, l10n)
                                    : FadeInUp(
                                        duration: Duration(milliseconds: 600),
                                        from: 30,
                                        child: Column(
                                          children: [
                                            SizedBox(height: 12),
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
                                                      l10n.salesTarget,
                                                      l10n.collections,
                                                      l10n.visits,
                                                      l10n.newCustomers,
                                                    ][index],
                                                    value: [
                                                      homeData?.monthlySales?.metrics?.totalAmount != null &&
                                                              homeData?.monthlySales?.metrics?.monthTarget != null
                                                          ? '${formatNumber(homeData!.monthlySales!.metrics!.totalAmount!)}/${formatNumber(homeData!.monthlySales!.metrics!.monthTarget!)}'
                                                          : 'N/A',
                                                      homeData?.receivables?.amountDueToday != null
                                                          ? formatNumber(homeData!.receivables!.amountDueToday!)
                                                          : 'N/A',
                                                      homeData?.additionalMetrics?.todayVisits != null
                                                          ? '${homeData!.additionalMetrics!.todayVisits}'
                                                          : 'N/A',
                                                      homeData?.additionalMetrics?.newCustomersThisMonth != null
                                                          ? '${homeData!.additionalMetrics!.newCustomersThisMonth}'
                                                          : 'N/A',
                                                    ][index],
                                                    subtitle: [
                                                      l10n.ofTarget(homeData?.monthlySales?.metrics?.achievementPercentage ?? 0),
                                                      l10n.partners(homeData?.receivables?.partnerCount ?? 0),
                                                      l10n.completedToday,
                                                      l10n.thisMonth,
                                                    ][index],
                                                    icon: [
                                                      Icons.show_chart,
                                                      Icons.account_balance_wallet,
                                                      Icons.check_circle_outline,
                                                      Icons.person_add_alt,
                                                    ][index],
                                                    achievementPercentage: homeData?.monthlySales?.metrics?.achievementPercentage ?? 0,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                            SizedBox(height: 20),
                            FadeInUp(
                              duration: Duration(milliseconds: 700),
                              from: 30,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.quickActions,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: getResponsiveFontSize(context, 16),
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _ActionButton(
                                          icon: Icons.place,
                                          label: l10n.nearbyCustomers,
                                          onTap: () {
                                            debugPrint('Tapped Nearby Customers');
                                            if (Get.isRegistered<DashboardController>()) {
                                              Get.toNamed('/nearbycustomer');
                                            } else {
                                              debugPrint('DashboardController not found');
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Navigation error: Controller not found')),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: _ActionButton(
                                          icon: Icons.inventory_2,
                                          label: l10n.stock,
                                          onTap: () {
                                            debugPrint('Tapped Stock');
                                            if (Get.isRegistered<DashboardController>()) {
                                              try {
                                                Get.find<DashboardController>().createNewDeal();
                                                Get.toNamed('/stock');
                                              } catch (e) {
                                                debugPrint('Error in Stock tap: $e');
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Navigation error: $e')),
                                                );
                                              }
                                            } else {
                                              debugPrint('DashboardController not found');
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Navigation error: Controller not found')),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            FadeInUp(
                              duration: Duration(milliseconds: 800),
                              from: 30,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [],
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    height: screenSize.height * 0.3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: theme.colorScheme.surface,
                                      border: Border.all(color: theme.colorScheme.outline, width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.shadow.withOpacity(0.05),
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
          ),
      isOffline
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                child: _buildCustomersShimmer(),
              ),
            )
          : Center(child: CustomersListScreen()),
      Center(child: WebViewScreen(url: GetStorage().read('webViewUrl') ?? 'https://onix.boom-solutions.co/web/login?redirect=%2Fodoo%3F')),
      isOffline
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                child: _buildSettingsShimmer(),
              ),
            )
          : Center(child: SettingsScreen()),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          physics: NeverScrollableScrollPhysics(),
          children: pages,
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomNavigationBar(),
          if (isOffline)
            Container(
              color: theme.colorScheme.error,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.signal_wifi_statusbar_connected_no_internet_4, color: theme.colorScheme.onError, size: 16),
                  SizedBox(width: 8),
                  Text(
                    l10n.youAreOffline,
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.onError,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceShimmer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading(bool isTablet) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainer,
      highlightColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: 100,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(height: 20),
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
                    color: Theme.of(context).colorScheme.surfaceContainer,
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
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: 90,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
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
            Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomersShimmer() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainer,
      highlightColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 60,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              S.of(context).customers,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.sort_by_alpha, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
            Column(
              children: List.generate(6, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: 60,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsShimmer() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainer,
      highlightColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: List.generate(4, (index) {
                return Container(
                  height: 60,
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message, S l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              l10n.checkConnection,
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.error,
                fontSize: getResponsiveFontSize(context, 14),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _ActionButton(
            icon: Icons.refresh,
            label: l10n.retry,
            onTap: () {
              debugPrint('Tapped Retry');
              _fetchAllData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, S.of(context).dashboard),
          _buildNavItem(1, Icons.people_alt_outlined, Icons.people_alt, S.of(context).customers),
          _buildNavItem(2, Icons.public_outlined, Icons.public, S.of(context).odoo),
          _buildNavItem(3, Icons.settings_outlined, Icons.settings, S.of(context).settings),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    bool isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
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
    _clockTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final double achievementPercentage;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.achievementPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = title == S.of(context).salesTarget
        ? (achievementPercentage >= 80 ? theme.colorScheme.primary : theme.colorScheme.secondary)
        : title == S.of(context).collections
            ? theme.colorScheme.secondary
            : title == S.of(context).visits
                ? theme.colorScheme.primary
                : theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
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
            SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: getResponsiveFontSize(context, 15),
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
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
                color: theme.colorScheme.onSurfaceVariant,
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

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
                color: theme.colorScheme.onPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreenResponse {
  final bool success;
  final User user;
  final MonthlySales monthlySales;
  final Receivables receivables;
  final AdditionalMetrics additionalMetrics;
  final CashJournal cashJournal;

  HomeScreenResponse({
    required this.success,
    required this.user,
    required this.monthlySales,
    required this.receivables,
    required this.additionalMetrics,
    required this.cashJournal,
  });

  factory HomeScreenResponse.fromJson(Map<String, dynamic> json) {
    return HomeScreenResponse(
      success: json['success'] ?? false,
      user: User.fromJson(json['user'] ?? {}),
      monthlySales: MonthlySales.fromJson(json['monthly_sales'] ?? {}),
      receivables: Receivables.fromJson(json['receivables'] ?? {}),
      additionalMetrics: AdditionalMetrics.fromJson(json['additional_metrics'] ?? {}),
      cashJournal: CashJournal.fromJson(json['cash_journal'] ?? {}),
    );
  }
}

class CashJournal {
  final int journalId;
  final String journalName;
  final String currency;
  final String currencySymbol;
  final double balance;

  CashJournal({
    required this.journalId,
    required this.journalName,
    required this.currency,
    required this.currencySymbol,
    required this.balance,
  });
  factory CashJournal.fromJson(Map<String, dynamic> json) {
    final journalId = json['journal_id'] ?? 0;
    GetStorage().write('journalId', journalId);
    return CashJournal(
      journalId: journalId,
      journalName: json['journal_name'] ?? '',
      currency: json['currency'] ?? '',
      currencySymbol: json['currency_symbol'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
    );
  }
}

class User {
  final int id;
  final String name;
  final int year;
  final int month;

  User({
    required this.id,
    required this.name,
    required this.year,
    required this.month,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
    );
  }
}

class MonthlySales {
  final Metrics metrics;

  MonthlySales({required this.metrics});

  factory MonthlySales.fromJson(Map<String, dynamic> json) {
    return MonthlySales(
      metrics: Metrics.fromJson(json['metrics'] ?? {}),
    );
  }
}

class Metrics {
  final int orderCount;
  final double totalAmount;
  final double monthTarget;
  final double achievementPercentage;

  Metrics({
    required this.orderCount,
    required this.totalAmount,
    required this.monthTarget,
    required this.achievementPercentage,
  });

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      orderCount: json['order_count'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      monthTarget: (json['month_target'] ?? 0.0).toDouble(),
      achievementPercentage: (json['achievement_percentage'] ?? 0.0).toDouble(),
    );
  }
}

class Receivables {
  final double amountDueToday;
  final int partnerCount;
  final int invoiceCount;
  final List<Partner> partnersWithDues;

  Receivables({
    required this.amountDueToday,
    required this.partnerCount,
    required this.invoiceCount,
    required this.partnersWithDues,
  });

  factory Receivables.fromJson(Map<String, dynamic> json) {
    var partnersJson = json['partners_with_dues'] ?? [];
    List<Partner> partners = List<Partner>.from(
        partnersJson.map((partner) => Partner.fromJson(partner)));
    return Receivables(
      amountDueToday: (json['amount_due_today'] ?? 0.0).toDouble(),
      partnerCount: json['partner_count'] ?? 0,
      invoiceCount: json['invoice_count'] ?? 0,
      partnersWithDues: partners,
    );
  }
}

class Partner {
  final int id;
  final String name;
  final double amountDue;

  Partner({
    required this.id,
    required this.name,
    required this.amountDue,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      amountDue: (json['amount_due'] ?? 0.0).toDouble(),
    );
  }
}

class AdditionalMetrics {
  final int totalCustomers;
  final int todayVisits;
  final int newCustomersThisMonth;

  AdditionalMetrics({
    required this.totalCustomers,
    required this.todayVisits,
    required this.newCustomersThisMonth,
  });

  factory AdditionalMetrics.fromJson(Map<String, dynamic> json) {
    return AdditionalMetrics(
      totalCustomers: json['total_customers'] ?? 0,
      todayVisits: json['today_visits'] ?? 0,
      newCustomersThisMonth: json['new_customers_this_month'] ?? 0,
    );
  }
}
