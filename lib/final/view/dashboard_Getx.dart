import 'dart:math';

import 'package:boom_solutions_invoice/final/controller/auth_controller.dart';
import 'package:boom_solutions_invoice/screens/new1.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:boom_solutions_invoice/final/controller/dashbord_Controller.dart';
import 'package:boom_solutions_invoice/final/controller/themeController.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0; // Tracks the current tab index
  String selectedRange = '7d';
  List<Map<String, dynamic>> fullData = [];
  List<Map<String, dynamic>> displayData = [];
  DateTime? startDate;
  DateTime? endDate;
  bool showDatePicker = false;
  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    generateSampleData();
    _filterDataByTimeRange('7d');
  }
  void generateSampleData() {
    final today = DateTime.now();
    final oneYearAgo = DateTime(today.year - 1, today.month, today.day);

    fullData = [];
    DateTime currentDate = oneYearAgo;

    // Generate smoother, more natural-looking data
    double lastValue = 80.0;
    while (currentDate.isBefore(today) || currentDate.isAtSameMomentAs(today)) {
      // Create a smooth trend with some randomness
      lastValue = lastValue + (Random().nextDouble() * 10 - 5);
      // Keep values in a reasonable range
      lastValue = lastValue.clamp(50.0, 150.0);

      fullData.add({
        'date': currentDate,
        'value': lastValue,
      });
      currentDate = currentDate.add(const Duration(days: 1));
    }
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
        // Navigate to the Dashboard screen
        Get.offNamed('/dashboard');
        break;
      case 1:
        // Navigate to the WebView screen without recreating it
        Get.toNamed('/webView', preventDuplicates: true);
        break;
      case 2:
        // Navigate to the Settings screen
        Get.toNamed('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
      final authController = Get.put<AuthController>(AuthController());
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: const Text(
          'Sales Dashboard ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // IconButton(
          //   icon: Obx(() => Icon(
          //         Get.find<ThemeController>().isDarkMode
          //             ? Icons.dark_mode
          //             : Icons.light_mode,
          //         color: isDark ? Colors.white70 : Colors.black87,
          //       )),
          //   onPressed: () => Get.find<ThemeController>().toggleTheme(),
          // ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 10.0, vertical: 12.0),
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sales Performance Chart
                // _DashboardCard(
                //   height: screenSize.height * (isTablet ? 0.25 : 0.28),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const _SectionTitle('Sales Performance'),
                //       const SizedBox(height: 8),
                //       Expanded(
                //         child: _buildChart(context),
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  // color: Colors.greenAccent,
                   decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDateRange(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                // color: Colors.grey[100],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedRange,
                                  icon: const Icon(Icons.keyboard_arrow_down,
                                      size: 16),
                                  borderRadius: BorderRadius.circular(8),
                                  itemHeight: 48,
                                  elevation: 1,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedRange = newValue;
                                        if (newValue == 'custom') {
                                          _showCustomDatePicker();
                                        } else {
                                          _filterDataByTimeRange(newValue);
                                        }
                                      });
                                    }
                                  },
                                  items: [
                                    DropdownMenuItem(
                                        value: '7d', child: Text('7 Days')),
                                    DropdownMenuItem(
                                        value: '1m', child: Text('1 Month')),
                                    DropdownMenuItem(
                                        value: '3m', child: Text('3 Months')),
                                    DropdownMenuItem(
                                        value: 'q', child: Text('Quarter')),
                                    DropdownMenuItem(
                                        value: '1y', child: Text('Year')),
                                    DropdownMenuItem(
                                        value: 'custom', child: Text('Custom')),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 180, // Reduced height for minimalism
                          width: double.infinity,
                          child: displayData.isEmpty
                              ? const Center(child: Text('No data available'))
                              : MinimalLineChart(
                                  data: displayData, timeRange: selectedRange),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Metrics Grid - Adaptive grid layout
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 2,
                    childAspectRatio: isTablet ? 1.5 : 1.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final metrics = [
                      {'title': 'Sales Target', 'value': '\$5,000/10k'},
                      {'title': 'Pending Collection', 'value': '\$2,400'},
                      {'title': 'Completed Visits', 'value': '8/10'},
                      {'title': 'New Customers', 'value': '12'},
                    ];

                    return _MetricCard(
                      title: metrics[index]['title']!,
                      value: metrics[index]['value']!,
                      shade: index * 12,
                    );
                  },
                ),

                const SizedBox(height: 20),
                const _SectionTitle('Quick Actions'),
                const SizedBox(height: 8),

                // Quick Actions - Adaptive grid layout
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
                          'icon': Icons.add_circle_outline,
                          'label': 'New Deal',
                          'action': () =>
                              Get.find<DashboardController>().createNewDeal()
                        },
                        {
                          'icon': Icons.payment,
                          'label': 'Receive Payment',
                          'action': () =>
                              Get.find<DashboardController>().collectPayment()
                        },
                        {
                          'icon': Icons.pin_drop,
                          'label': 'Log Visit',
                          // 'action': () =>
                          //     Get.find<DashboardController>().logVisit()
                               'action': () => Get.toNamed('/Stock')
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
                    }),

                const SizedBox(height: 20),

                // Notes Section
                _DashboardCard(
                  height: screenSize.height * (isTablet ? 0.3 : 0.35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('Notes'),
                      const SizedBox(height: 8),
                      GetBuilder<DashboardController>(
                        builder: (controller) => TextField(
                          controller: controller.noteController,
                          decoration: InputDecoration(
                            hintText: 'Add note...',
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[900] : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              onPressed: () {
                                controller.addNote();
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (_scrollController.hasClients) {
                                    _scrollController.animateTo(
                                      _scrollController
                                          .position.maxScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Obx(() {
                          final notes = Get.find<DashboardController>().notes;
                          if (notes.isEmpty) {
                            return Center(
                              child: Text(
                                'No notes yet',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[400],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                            ),
                            itemCount: notes.length,
                            itemBuilder: (_, index) {
                              final note = notes.reversed.toList()[index];
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                leading: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                title: Text(
                                  note,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
      // Bottom Navigation Bar with monochrome styling
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 8,
        backgroundColor: isDark ? Colors.black : Colors.white,
        selectedItemColor: isDark ? Colors.white : Colors.black,
        unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
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
    // Start with current dates if not set
    startDate ??= DateTime.now().subtract(const Duration(days: 7));
    endDate ??= DateTime.now();

    // Show date range picker
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
}

class MinimalLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String timeRange;

  const MinimalLineChart({
    Key? key,
    required this.data,
    required this.timeRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      
      LineChartData(
        gridData: FlGridData(
          show: false, // No grid for minimal look
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 18,
              interval: _calculateInterval(),
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= data.length) {
                  return const SizedBox();
                }

                final date = data[value.toInt()]['date'] as DateTime;

                // Change date format based on timeRange
                String dateLabel;
                if (timeRange == '1y' || _isLongTimeRange()) {
                  // For year view or long custom ranges, show year
                  dateLabel = DateFormat('yyyy').format(date);
                } else if (timeRange == '3m' || timeRange == 'q') {
                  // For quarterly view, show abbreviated month
                  dateLabel = DateFormat('MMM').format(date);
                } else {
                  // For shorter periods, show month and day
                  dateLabel = DateFormat('MMM d').format(date);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false, // No border for minimal look
        ),
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: 0,
        maxY: _getMaxY() * 1.1, // Add 10% padding at the top
        lineBarsData: [
          LineChartBarData(
            spots: _createSpots(),
            isCurved: true,
            curveSmoothness: 0.4,
            color: Colors.blue[500],
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false), // No dots for minimal look
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue[100]?.withOpacity(0.15),
              gradient: LinearGradient(
                colors: [
                  Colors.blue[300]!.withOpacity(0.15),
                  Colors.blue[100]!.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: Colors.blue[700]!.withOpacity(0.8),
            tooltipRoundedRadius: 8,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final date = data[spot.x.toInt()]['date'] as DateTime;
                final value = spot.y;
                return LineTooltipItem(
                  '${DateFormat('MMM d, yyyy').format(date)}\n',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                  children: [
                    TextSpan(
                      text: value.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  List<FlSpot> _createSpots() {
    return List.generate(data.length, (index) {
      return FlSpot(index.toDouble(), (data[index]['value'] as double));
    });
  }

  double _getMaxY() {
    double max = 0;
    for (var item in data) {
      final value = item['value'] as double;
      if (value > max) {
        max = value;
      }
    }
    return max;
  }

  double _calculateInterval() {
    // Determine a good interval based on the number of data points and time range
    if (timeRange == '7d') return 1;
    if (timeRange == '1m') return max(1, (data.length / 4).floor().toDouble());
    if (timeRange == '3m' || timeRange == 'q')
      return max(1, (data.length / 3).floor().toDouble());
    if (timeRange == '1y') return max(1, (data.length / 6).floor().toDouble());

    // For custom ranges
    if (data.length <= 7) return 1;
    if (data.length <= 30) return 5;
    if (data.length <= 90) return 15;
    return 30;
  }

  // Determine if this is a long custom time range (more than 6 months)
  bool _isLongTimeRange() {
    if (timeRange != 'custom' || data.isEmpty) return false;

    final firstDate = data.first['date'] as DateTime;
    final lastDate = data.last['date'] as DateTime;

    // Calculate difference in months
    int monthsDiff = (lastDate.year - firstDate.year) * 12 +
        lastDate.month -
        firstDate.month;

    return monthsDiff >= 6;
  }

  // Chart widget keeping the original colors from the first code
  Widget _buildChart(BuildContext context) {
    final thisMonthData = [
      const FlSpot(0, 0),
      const FlSpot(1, 1),
      const FlSpot(2, 5),
      const FlSpot(3, 1),
      const FlSpot(4, 0),
      const FlSpot(5, 0),
      const FlSpot(6, 0),
      const FlSpot(7, 0),
      const FlSpot(8, 0),
      const FlSpot(9, 0),
      const FlSpot(10, 0),
      const FlSpot(11, 0),
    ];

    final lastMonthData = [
      const FlSpot(0, 0),
      const FlSpot(1, 0),
      const FlSpot(2, 0),
      const FlSpot(3, 0),
      const FlSpot(4, 0),
      const FlSpot(5, 0),
      const FlSpot(6, 0),
      const FlSpot(7, 0),
      const FlSpot(8, 0),
      const FlSpot(9, 1),
      const FlSpot(10, 5),
      const FlSpot(11, 1),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 6,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 2,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${value.toInt()}k',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const months = [
                  "Jan",
                  "Feb",
                  "Mar",
                  "Apr",
                  "May",
                  "Jun",
                  "Jul",
                  "Aug",
                  "Sep",
                  "Oct",
                  "Nov",
                  "Dec"
                ];

                // Only show every other month to avoid clutter on small screens
                final isSmallScreen = MediaQuery.of(context).size.width < 360;
                if (isSmallScreen && value.toInt() % 2 != 0) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    months[value.toInt()],
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: isDark ? Colors.grey[800]! : Colors.white,
            tooltipRoundedRadius: 8,
          ),
        ),
        lineBarsData: [
          // Last month data (red) - keeping original style
          LineChartBarData(
            spots: lastMonthData,
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.8),
                  Colors.red.withOpacity(0.125),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // This month data (green) - keeping original style
          LineChartBarData(
            spots: thisMonthData,
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.8),
                  Colors.green.withOpacity(0.125),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Monochrome Reusable Components
class _DashboardCard extends StatelessWidget {
  final Widget child;
  final double height;

  const _DashboardCard({
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: isDark ? 20 : 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
    );
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

    // Fix: Use valid Colors.grey values
    final Color cardColor = isDark
        ? (shade % .5 == 0 ? Colors.grey[800]! : Colors.grey[900]!)
        : (shade % .5 == 0 ? Colors.white! : Colors.grey[100]!);

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    // color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
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

    // Fix: Ensure shade values are within valid range for Colors.grey
    final int calculatedShade = (shade + (isDark ? 600 : 200)).clamp(0, 900);
    final int normalizedShade = [
      50,
      100,
      200,
      300,
      400,
      500,
      600,
      700,
      800,
      900
    ].reduce((a, b) =>
        (calculatedShade - a).abs() < (calculatedShade - b).abs() ? a : b);

    final buttonColor = Colors.grey[normalizedShade]!;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        // backgroundColor: buttonColor,
        foregroundColor: isDark ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18,
          color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Updated AppColors class
class AppColors {
  static const Color backgroundLight = Colors.blue;
  static const Color backgroundDark = Colors.blue;
}
