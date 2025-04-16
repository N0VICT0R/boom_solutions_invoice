  import 'dart:math';
  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:fl_chart/fl_chart.dart';
  import 'package:get/get.dart';
  import 'package:intl/intl.dart';

  class SalesChartController extends GetxController {
    final String baseUrl = "http://137.184.205.67:2710/";
    final String token = "gln5EU3jkGwBy7GZWnSpm9N7EffslYS5";
    var salesData = <FlSpot>[].obs;
    var rawSalesData = <double>[].obs; // Daily data
    var aggregatedData = <String, List<FlSpot>>{}.obs; // Aggregated data by category
    var isLoading = true.obs;
    var selectedTimeRange = '7 Days'.obs;
    var dateFrom = DateTime.now().subtract(const Duration(days: 7));
    var dateTo = DateTime.now();
    var xLabels = <String>[].obs;
    var displayPoints = <int>[].obs;
    var currentScrollPosition = 0.obs;
    var totalDataPoints = 0.obs;
    bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
    final NumberFormat largeValueFormatter = NumberFormat.compact();
    double? _previousScrollPosition;
    String _formatDate(DateTime date) =>
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    String _monthAbbr(int month) =>
        ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];

    String formatLargeNumber(double value) {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
      return value.toStringAsFixed(0);
    }

    Future<void> fetchSalesData() async {
      isLoading(true);
      try {
        final response = await http.get(Uri.parse(
          "$baseUrl/api/v1/users/2/sales?api_token=$token&"
          "date_from=${_formatDate(dateFrom)}&date_to=${_formatDate(dateTo)}&group_by=day",
        ));
        Map<String, double> dataMap = {};
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['data'] != null) {
            responseData['data'].forEach((item) {
              dataMap[item['date']] = item['value'].toDouble();
            });
          }
        }

        List<double> rawData = [];
        DateTime current = dateFrom;
        int index = 0;

        // Fetch daily data
        while (current.isBefore(dateTo) || current.isAtSameMomentAs(dateTo)) {
          final dateKey = _formatDate(current);
          final value = dataMap[dateKey] ?? 0.0;
          rawData.add(value);
          index++;
          current = current.add(const Duration(days: 1));
        }

        rawSalesData.assignAll(rawData);
        totalDataPoints.value = rawData.length;

        // Aggregate data for the selected time range
        _aggregateData(rawData);

        // Update chart data
        _updateChartData();
      } catch (e) {
        print("Error fetching data: $e");
      } finally {
        isLoading(false);
      }
    }

    void _aggregateData(List<double> rawData) {
      aggregatedData.clear();
      DateTime current = dateFrom;

      if (selectedTimeRange.value == '5 years') {
        // Monthly data for 5 years
        Map<String, double> monthlySums = {};
        for (int i = 0; i < rawData.length; i++) {
          String monthKey = '${current.year}-${current.month}';
          monthlySums[monthKey] = (monthlySums[monthKey] ?? 0) + rawData[i];
          current = current.add(const Duration(days: 1));
        }

        List<FlSpot> monthlyData = [];
        List<String> monthlyLabels = [];
        current = dateFrom;
        int monthIndex = 0;
        while (current.isBefore(dateTo) || current.isAtSameMomentAs(dateTo)) {
          String monthKey = '${current.year}-${current.month}';
          double sum = monthlySums[monthKey] ?? 0;
          monthlyData.add(FlSpot(monthIndex.toDouble(), sum));
          monthlyLabels.add('${_monthAbbr(current.month)} ${current.year}');
          monthIndex++;
          current = DateTime(current.year, current.month + 1, 1);
        }
        aggregatedData['monthly'] = monthlyData;
        xLabels.assignAll(monthlyLabels);
        print("Monthly data length: ${monthlyData.length}, Labels: ${monthlyLabels.length}");
      } else if (selectedTimeRange.value == '1 year') {
        // Monthly data for 1 year
        Map<String, double> monthlySums = {};
        for (int i = 0; i < rawData.length; i++) {
          String monthKey = '${current.year}-${current.month}';
          monthlySums[monthKey] = (monthlySums[monthKey] ?? 0) + rawData[i];
          current = current.add(const Duration(days: 1));
        }

        List<FlSpot> monthlyData = [];
        List<String> monthlyLabels = [];
        current = dateFrom;
        int monthIndex = 0;
        while (current.isBefore(dateTo) || current.isAtSameMomentAs(dateTo)) {
          String monthKey = '${current.year}-${current.month}';
          double sum = monthlySums[monthKey] ?? 0;
          monthlyData.add(FlSpot(monthIndex.toDouble(), sum));
          monthlyLabels.add(_monthAbbr(current.month));
          monthIndex++;
          current = DateTime(current.year, current.month + 1, 1);
        }
        aggregatedData['monthly'] = monthlyData;
        xLabels.assignAll(monthlyLabels);
      } else if (selectedTimeRange.value == '1 quarter') {
        // Monthly data for 1 quarter
        Map<String, double> monthlySums = {};
        for (int i = 0; i < rawData.length; i++) {
          String monthKey = '${current.year}-${current.month}';
          monthlySums[monthKey] = (monthlySums[monthKey] ?? 0) + rawData[i];
          current = current.add(const Duration(days: 1));
        }

        List<FlSpot> monthlyData = [];
        List<String> monthlyLabels = [];
        current = dateFrom;
        int monthIndex = 0;
        while (current.isBefore(dateTo) || current.isAtSameMomentAs(dateTo)) {
          String monthKey = '${current.year}-${current.month}';
          double sum = monthlySums[monthKey] ?? 0;
          monthlyData.add(FlSpot(monthIndex.toDouble(), sum));
          monthlyLabels.add(_monthAbbr(current.month));
          monthIndex++;
          current = DateTime(current.year, current.month + 1, 1);
        }
        aggregatedData['monthly'] = monthlyData;
        xLabels.assignAll(monthlyLabels);
      } else if (selectedTimeRange.value == '1 month') {
        // Weekly data for 1 month
        Map<int, double> weeklySums = {};
        for (int i = 0; i < rawData.length; i++) {
          int week = (i / 7).floor();
          weeklySums[week] = (weeklySums[week] ?? 0) + rawData[i];
        }

        List<FlSpot> weeklyData = [];
        List<String> weeklyLabels = [];
        int weekIndex = 0;
        weeklySums.forEach((week, sum) {
          weeklyData.add(FlSpot(weekIndex.toDouble(), sum));
          weeklyLabels.add('Week ${week + 1}');
          weekIndex++;
        });
        aggregatedData['weekly'] = weeklyData;
        xLabels.assignAll(weeklyLabels);
      } else {
        // Daily data for 7 days
        List<FlSpot> dailyData = [];
        List<String> dailyLabels = [];
        for (int i = 0; i < rawData.length; i++) {
          dailyData.add(FlSpot(i.toDouble(), rawData[i]));
          dailyLabels.add('${dateFrom.add(Duration(days: i)).day}/${dateFrom.add(Duration(days: i)).month}');
        }
        aggregatedData['daily'] = dailyData;
        xLabels.assignAll(dailyLabels);
      }
    }

    void _updateChartData() {
      String key;
      if (selectedTimeRange.value == '5 years') {
        key = 'monthly';
      } else if (selectedTimeRange.value == '1 year' || selectedTimeRange.value == '1 quarter') {
        key = 'monthly';
      } else if (selectedTimeRange.value == '1 month') {
        key = 'weekly';
      } else {
        key = 'daily';
      }

      salesData.assignAll(aggregatedData[key] ?? []);
      totalDataPoints.value = salesData.length;

      // Ensure currentScrollPosition is within bounds, considering the visible window size
      int maxStartIndex = salesData.length > 12 ? salesData.length - 12 : 0;
      currentScrollPosition.value = max(0, min(currentScrollPosition.value, maxStartIndex));

      // Update display points to match the current data length
      List<int> displayIndices = [];
      int labelLength = xLabels.length;
      int dataLength = salesData.length;
      int maxLength = min(labelLength, dataLength);
      for (int i = 0; i < maxLength; i++) {
        displayIndices.add(i);
      }
      displayPoints.assignAll(displayIndices);

      print("After update - SalesData length: ${salesData.length}, xLabels length: ${xLabels.length}, DisplayPoints length: ${displayPoints.length}");
    }

    void updateTimeRange(String range) {
      final now = DateTime.now();
      switch (range) {
        case '7 Days':
          dateFrom = DateTime(now.year, now.month, now.day - 7);
          break;
        case '1 month':
          dateFrom = DateTime(now.year, now.month - 1, now.day);
          break;
        case '1 quarter':
          dateFrom = DateTime(now.year, now.month - 3, now.day);
          break;
        case '1 year':
          dateFrom = DateTime(now.year - 1, now.month, now.day);
          break;
        case '5 years':
          dateFrom = DateTime(now.year - 5, now.month, now.day);
          break;
      }
      dateTo = now;
      selectedTimeRange.value = range;
      fetchSalesData();
    }

    void scrollByAmount(int amount) {
      int newPosition = currentScrollPosition.value + amount;
      // Ensure newPosition is within bounds, considering the visible window size
      int maxStartIndex = salesData.length > 12 ? salesData.length - 12 : 0;
      newPosition = max(0, min(newPosition, maxStartIndex));
      newPosition = max(0, min(newPosition, xLabels.length - 1));
      currentScrollPosition.value = newPosition;

      // Update display points to ensure they are within bounds
      List<int> displayIndices = [];
      int labelLength = xLabels.length;
      int dataLength = salesData.length;
      int maxLength = min(labelLength, dataLength);
      for (int i = 0; i < maxLength; i++) {
        displayIndices.add(i);
      }
      displayPoints.assignAll(displayIndices);
    }

    int getCategoryScrollAmount(bool isLeft) {
      int scrollAmount;
      switch (selectedTimeRange.value) {
        case '7 Days':
          scrollAmount = 1;
          break;
        case '1 month':
          scrollAmount = 1;
          break;
        case '1 quarter':
          scrollAmount = 1;
          break;
        case '1 year':
          scrollAmount = 1;
          break;
        case '5 years':
          scrollAmount = 12;
          break;
        default:
          scrollAmount = 1;
      }
      return isLeft ? -scrollAmount : scrollAmount;
    }

    @override
    void onInit() {
      super.onInit();
      fetchSalesData();
      
    }
  }

  class SalesChartCard extends StatefulWidget {
    @override
    _SalesChartCardState createState() => _SalesChartCardState();
  }

  class _SalesChartCardState extends State<SalesChartCard> {
    late final SalesChartController controller;
    
  bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
    @override
    void initState() {
      super.initState();
      controller = Get.put(SalesChartController());
    }

    @override
    Widget build(BuildContext context) {
      return Obx(
        () => Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 25,
                child: _buildHeader(),
              ),
              const SizedBox(height: 8),
              _buildSwipeGuide(),
              const SizedBox(height: 8),
              _buildInteractiveChart(),
              const SizedBox(height: 8),
              _buildTopLabel(),
            ],
          ),
        ),
      );
    }

    Widget _buildHeader() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Last ${controller.selectedTimeRange.value}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: controller.selectedTimeRange.value,
                items: ['7 Days', '1 month', '1 quarter', '1 year', '5 years']
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            v,
                            style: TextStyle(
                          color:  isDark(context) ? Colors.white : Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => controller.updateTimeRange(v!),
                style: const TextStyle(
                  fontSize: 12,
                ),
                underline: Container(),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                ),
              ),
            ),
          ],
        );

    Widget _buildSwipeGuide() {
      return Obx(() {
        if (controller.isLoading.value || controller.salesData.isEmpty) return const SizedBox.shrink();

        bool canScrollLeft = controller.currentScrollPosition.value > 0;
        int displayCount = controller.salesData.length > 12 ? 12 : controller.salesData.length;
        int lastVisibleIndex = controller.currentScrollPosition.value + displayCount - 1;
        bool canScrollRight = lastVisibleIndex < controller.salesData.length - 1;

        if (!canScrollLeft && !canScrollRight) return const SizedBox.shrink();

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1.0, end: 0.0),
          duration: const Duration(seconds: 5),
          onEnd: () {
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() {});
              }
            });
          },
          builder: (context, opacity, child) {
            return AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 500),
              child: Opacity(
                opacity: (opacity > 0.5) ? 1.0 : 0.5,
                child: child,
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swipe,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Swipe left or right to view more data',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      });
    }

    Widget _buildTopLabel() {
      final startIndex = controller.currentScrollPosition.value;
      if (controller.xLabels.isEmpty || startIndex < 0 || startIndex >= controller.xLabels.length) {
        return const SizedBox.shrink();
      }

      String label = controller.xLabels[startIndex];
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    Widget _buildInteractiveChart() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.salesData.isEmpty) {
        return const SizedBox(
          height: 160,
          child: Center(child: Text('No data available')),
        );
      }
      return GestureDetector(
        onHorizontalDragUpdate: (details) {
          double sensitivity = 3;
          int scrollAmount = (details.delta.dx / sensitivity).round();
          controller.scrollByAmount(-scrollAmount);
        },
        child: _buildChart(),
      );
    }

    Widget _buildChart() {
      final startIndex = controller.currentScrollPosition.value;
      final displayCount = controller.salesData.length > 12 ? 12 : controller.salesData.length;
      final endIndex = min(startIndex + displayCount, controller.salesData.length);
      
      if (startIndex >= controller.salesData.length || startIndex < 0 || endIndex > controller.salesData.length) {
        return const SizedBox(
          height: 160,
          child: Center(child: Text('Data range error')),
        );
      }

      List<FlSpot> visibleData = controller.salesData.sublist(startIndex, endIndex);
      print("Visible data length: ${visibleData.length}, StartIndex: $startIndex, EndIndex: $endIndex");
      double maxY = visibleData.isNotEmpty ? visibleData.map((e) => e.y).reduce(max) * 1.1 : 1.0;

      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 32),
            child: SizedBox(
              height: MediaQuery.of(context).size.height*.25,  
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  minX: startIndex.toDouble(),
                  maxX: (endIndex - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  clipData: FlClipData.all(),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= startIndex &&
                              index < endIndex &&
                              controller.displayPoints.contains(index) &&
                              index >= 0 &&
                              index < controller.xLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Transform.rotate(
                                angle: 22 * (3.14159 / 180),
                                child: Text(
                                  controller.xLabels[index],
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == maxY / 2 || value == maxY) {
                            String formattedValue = controller.formatLargeNumber(value);
                            return Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Text(
                                formattedValue,
                                style: const TextStyle(
                                  fontSize: 9,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: visibleData,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      curveSmoothness: 0.35,
                      color: const Color.fromARGB(255, 4, 101, 181),
                      barWidth: 2.0,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        cutOffY: 0,
                        applyCutOffY: true,
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 73, 173, 255).withOpacity(0.4),
                            Color.fromRGBO(33, 150, 243, 0.0),
                          ],
                          stops: [0.1, 0.9],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          spot.x.toInt();
                          double originalValue = spot.y;
                          return LineTooltipItem(
                            controller.formatLargeNumber(originalValue),
                            const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 22,
            child: _buildSwipeIndicator(isLeft: true),
          ),
          Positioned(
            right: 8,
            top: 22,
            child: _buildSwipeIndicator(isLeft: false),
          ),
        ],
      );
    }

    Widget _buildSwipeIndicator({required bool isLeft}) {
      // Calculate if swiping is possible
      bool canScroll;
      if (isLeft) {
        canScroll = controller.currentScrollPosition.value > 0;
      } else {
        // Can swipe right if the last visible index is less than the total data length
        int displayCount = controller.salesData.length > 12 ? 12 : controller.salesData.length;
        int lastVisibleIndex = controller.currentScrollPosition.value + displayCount - 1;
        canScroll = lastVisibleIndex < controller.salesData.length - 1;
      }

      if (!canScroll) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () {
          int scrollAmount = controller.getCategoryScrollAmount(isLeft);
          controller.scrollByAmount(scrollAmount);
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isLeft ? Icons.chevron_left : Icons.chevron_right,
              size: 16,
            ),
          ),
        ),
      );
    }
  }

  void main() {
    runApp(
      GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          // scaffoldBackgroundColor: const Color(0xFF13151A),
          // primaryColor: const Color(0xFF2196F3),
        ),
        home: Scaffold(
          body: SafeArea(child: SalesChartCard()),
        ),
      ),
    );
  }