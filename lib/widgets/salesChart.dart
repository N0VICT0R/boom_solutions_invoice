import 'dart:convert';
import 'dart:math';
import 'package:boom_solutions_invoice/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Extension for firstWhereOrNull for older Dart versions
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class ThemeModes {
  static final lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.grey[100],
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    colorScheme: const ColorScheme.light().copyWith(
      primary: Colors.blueAccent,
      secondary: Colors.lightBlueAccent,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 11),
    ),
  );

  static final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1E1E1E),
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.blueAccent,
      secondary: Colors.lightBlueAccent,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 11),
    ),
  );
}

class SalesData {
  final String period;
  final double value;

  SalesData(this.period, this.value);
}

class SalesChartController extends GetxController {
  final String apiurl = GetStorage().read("apiUrl") ?? "";
  final token = GetStorage().read('token') ?? '';

  var isLoading = true.obs;
  var selectedRange = 'Day'.obs;
  var errorMessage = ''.obs;
  var selectedBarIndex = RxInt(-1);

  var salesData = <SalesData>[].obs;
  var dateFrom = DateTime.now();
  var dateTo = DateTime.now();

  final formatter = NumberFormat.compact();
  final dateFormatter = DateFormat('yyyy-MM-dd');

  SalesChartController() {
    print('New SalesChartController instance created');
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  String _monthName(int month) =>
      ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];

  String formatValue(double value) => formatter.format(value);

  void selectBar(int index) {
    if (selectedBarIndex.value == index) {
      selectedBarIndex.value = -1;
    } else {
      selectedBarIndex.value = index;
    }
  }

  SalesData? get selectedBarData {
    if (selectedBarIndex.value >= 0 && selectedBarIndex.value < salesData.length) {
      return salesData[selectedBarIndex.value];
    }
    return null;
  }

  double get averageSales =>
      salesData.isEmpty ? 0 : salesData.map((data) => data.value).reduce((a, b) => a + b) / salesData.length;

  double get maxYValue {
    if (salesData.isEmpty) return 100;
    double maxValue = salesData.map((data) => data.value).reduce(max);
    return maxValue > 0 ? maxValue * 1.2 : 100.0;
  }

  double get totalSales =>
      salesData.isEmpty ? 0 : salesData.map((data) => data.value).reduce((a, b) => a + b);

  double get selectedDiffFromAvg {
    if (selectedBarData == null || averageSales == 0) return 0;
    return ((selectedBarData!.value / averageSales) - 1) * 100;
  }

  Future<bool> refreshToken() async {
    try {
      final apiUrl = GetStorage().read("apiUrl") ?? "";
      final refreshToken = GetStorage().read('refresh_token') ?? '';
      print('Refreshing token with: $refreshToken');
      final url = Uri.parse('$apiUrl/api/v1/refresh-token');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      print('Refresh token response: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        GetStorage().write('token', jsonData['access_token']);
        GetStorage().write('refresh_token', jsonData['refresh_token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Refresh token error: $e');
      return false;
    }
  }

  Future<void> fetchData({int retryCount = 0, int maxRetries = 2}) async {
    final l10n = Get.context != null ? S.of(Get.context!) : null;
    print('fetchData called, retryCount: $retryCount, user_id: ${GetStorage().read('user_id')}, token: $token, apiUrl: $apiurl');
    if (GetStorage().read('user_id') == null || token.isEmpty) {
      print('Missing user_id or token');
      errorMessage.value = l10n?.pleaseLoginAgain ?? 'Please log in again.';
      isLoading(false);
      return;
    }
    isLoading(true);
    errorMessage.value = '';
    selectedBarIndex.value = -1;
    final userId = GetStorage().read('user_id');
    try {
      String groupBy = selectedRange.value.toLowerCase();
      final uri = Uri.parse(
        "$apiurl/api/v1/users/$userId/sales?api_token=$token&"
        "date_from=${_formatDate(dateFrom)}&date_to=${_formatDate(dateTo)}&group_by=$groupBy",
      );
      print('Fetching sales data from: $uri');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('Request timed out');
          return http.Response('{"error": "Request timed out"}', 408);
        },
      );
      print('Sales API response: ${response.statusCode}, ${response.body}');
      List<Map<String, dynamic>> dataList = [];
      if (response.statusCode == 408 && retryCount < maxRetries) {
        print('Timeout, retrying fetchData, attempt ${retryCount + 1}');
        return fetchData(retryCount: retryCount + 1);
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed API data: $data');
        if (data['data'] != null && data['data'] is List && data['data'].isNotEmpty) {
          dataList = List<Map<String, dynamic>>.from(data['data']);
          dataList.sort((a, b) => a['date'].compareTo(b['date']));
        } else {
          print('No sales data available for this period');
          errorMessage.value = l10n?.noSalesInThisTime ?? "No sales in this time.";
        }
      } else if (response.statusCode == 401) {
        print('401 Unauthorized, attempting token refresh');
        if (await refreshToken()) {
          return fetchData(retryCount: retryCount);
        }
        errorMessage.value = l10n?.sessionExpired ?? "Session expired. Please log in again.";
      } else if (response.statusCode == 400 && response.body.contains('invalid CSRF token')) {
        print('400 Invalid CSRF token, attempting token refresh');
        if (await refreshToken()) {
          return fetchData(retryCount: retryCount);
        }
        errorMessage.value = l10n?.authenticationError ?? "Authentication error. Please log in again.";
      } else {
        print('Server error: ${response.statusCode}, ${response.body}');
        errorMessage.value = l10n?.serverError(response.statusCode.toString()) ??
            "Server error: HTTP ${response.statusCode}";
      }

      int maxItems;
      if (groupBy == 'day') {
        maxItems = 7;
      } else if (groupBy == 'month') {
        maxItems = 12;
      } else if (groupBy == 'quarter') {
        maxItems = 9;
      } else {
        maxItems = 6;
      }

      List<Map<String, dynamic>> paddedData = [];
      DateTime current = dateFrom;
      for (int i = 0; i < maxItems; i++) {
        String expectedDate;
        if (groupBy == 'day') {
          expectedDate = _formatDate(current);
          current = current.add(const Duration(days: 1));
        } else if (groupBy == 'month') {
          expectedDate = "${current.year}-${current.month.toString().padLeft(2, '0')}";
          current = DateTime(current.year, current.month + 1, 1);
        } else if (groupBy == 'quarter') {
          int quarter = ((current.month - 1) ~/ 3) + 1;
          expectedDate = '${current.year}-Q$quarter';
          current = DateTime(current.year, current.month + 3, 1);
        } else {
          expectedDate = '${current.year}';
          current = DateTime(current.year + 1, 1, 1);
        }

        var matchingItem = dataList.firstWhereOrNull((item) => item['date'] == expectedDate);
        if (matchingItem != null) {
          paddedData.add(matchingItem);
        } else {
          paddedData.add({"date": expectedDate, "value": 0.0});
        }
      }

      print('Padded data: $paddedData');
      processData(paddedData);
    } catch (e) {
      print('FetchData error: $e');
      errorMessage.value = l10n?.networkError(e.toString()) ?? "Network error. Please try again.";
    } finally {
      isLoading(false);
    }
  }

  void processData(List<Map<String, dynamic>> rawData) {
    print('Processing raw data: $rawData');
    List<SalesData> newData = [];
    String groupBy = selectedRange.value.toLowerCase();

    for (var item in rawData) {
      String? period = item['date']?.toString();
      if (period == null) {
        print('Skipping item with null date: $item');
        continue;
      }

      if (groupBy == 'day') {
        DateTime date = dateFormatter.parse(period);
        period = '${date.day} ${_monthName(date.month)}';
      } else if (groupBy == 'month') {
        List<String> parts = period.split('-');
        int year = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        period = '${_monthName(month)} $year';
      } else if (groupBy == 'quarter') {
        List<String> parts = period.split('-Q');
        int year = int.parse(parts[0]);
        int quarter = int.parse(parts[1]);
        period = 'Q$quarter $year';
      }

      newData.add(SalesData(
        period,
        (item['value'] as num?)?.toDouble() ?? 0.0,
      ));
    }

    print('Processed salesData: $newData');
    salesData.assignAll(newData);
  }

  void setTimeRange(String range) {
    print('Setting time range to: $range');
    final now = DateTime.now();

    switch (range) {
      case 'Day':
        dateFrom = now.subtract(const Duration(days: 6));
        dateTo = now;
        break;
      case 'Month':
        dateFrom = DateTime(now.year - 1, now.month + 1, 1);
        dateTo = now;
        break;
      case 'Quarter':
        dateFrom = DateTime(now.year - 2, now.month + 1, 1);
        dateTo = now;
        break;
      case 'Year':
        dateFrom = DateTime(now.year - 5, 1, 1);
        dateTo = now;
        break;
    }

    selectedRange.value = range;
    print('selectedRange updated to: ${selectedRange.value}');
    fetchData();
  }

  @override
  void onInit() {
    super.onInit();
    print('Controller initialized, setting initial range to Day');
    print('user_id: ${GetStorage().read('user_id')}, token: $token, apiUrl: $apiurl');
    setTimeRange('Day');
  }
}

class SalesChartView extends StatelessWidget {
  SalesChartView({super.key});

  final controller = Get.find<SalesChartController>();

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildChart(context),
          _buildSelectedBarInfo(context),
          const SizedBox(height: 12),
          _buildTimeSelector(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = S.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.salesOverview,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        Obx(() {
          if (controller.salesData.isEmpty) {
            return const SizedBox.shrink();
          }
          return Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  // backgroundColor: Colors.transparent,
                  iconColor: theme.colorScheme.primary,
                ),
                onPressed: () => controller.fetchData(),
                child: Icon(Icons.refresh),
              ),
                
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  controller.formatValue(controller.totalSales),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = S.of(context);

    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return SizedBox(
          height: 180,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              
              ],
            ),
          ),
        );
      }

      if (controller.salesData.isEmpty) {
        return SizedBox(
          height: 180,
          child: Center(child: Text(l10n.noSalesInThisTime)),
        );
      }

      double maxY = controller.maxYValue;
      return SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: false,
              touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                if (event is FlTapUpEvent && response != null && response.spot != null) {
                  final touchedIndex = response.spot!.touchedBarGroupIndex;
                  controller.selectBar(touchedIndex);
                }
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => theme.cardTheme.color?.withOpacity(0.95) ?? Colors.grey[200]!,
                tooltipBorderRadius: BorderRadius.circular(8),
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final item = controller.salesData[groupIndex];
                  return BarTooltipItem(
                    controller.formatValue(item.value),
                    theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ) ?? const TextStyle(),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= controller.salesData.length) return const SizedBox();

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Transform.rotate(
                        angle: (controller.selectedRange.value == 'Month' || controller.selectedRange.value == 'Quarter')
                            ? 25 * pi / 180
                            : 0,
                        child: Text(
                          controller.salesData[index].period,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7) ?? Colors.grey,
                            fontWeight: controller.selectedBarIndex.value == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: min(MediaQuery.of(context).size.width * 0.022, 10.0),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barGroups: List.generate(
              controller.salesData.length,
              (index) {
                final item = controller.salesData[index];
                double normalizedValue = maxY == 0 ? 0.5 : (item.value / maxY).clamp(0.0, 1.0);
                Color barColor = Color.lerp(Colors.redAccent, Colors.greenAccent, normalizedValue)!;
                final isSelected = controller.selectedBarIndex.value == index;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: item.value,
                      color: barColor,
                      width: MediaQuery.of(context).size.width / (controller.salesData.length * 3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      backDrawRodData: isSelected
                          ? BackgroundBarChartRodData(
                              show: true,
                              toY: maxY,
                              color: theme.colorScheme.primary.withOpacity(0.1),
                            )
                          : null,
                      rodStackItems: isSelected
                          ? [BarChartRodStackItem(0, item.value, Colors.white.withOpacity(0.3))]
                          : [],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSelectedBarInfo(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = S.of(context);

    return Obx(() {
      final selectedData = controller.selectedBarData;
      if (selectedData == null) return const SizedBox.shrink();

      String diff = controller.selectedDiffFromAvg.toStringAsFixed(1);
      String diffSign = controller.selectedDiffFromAvg >= 0 ? '+' : '';

      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.selected(selectedData.period),
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  controller.formatValue(selectedData.value),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.vsAverage(diffSign, diff),
              style: theme.textTheme.bodySmall?.copyWith(
                color: controller.selectedDiffFromAvg >= 0 ? Colors.green : Colors.redAccent,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTimeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = S.of(context);

    return Obx(() {
      print('Rebuilding time selector, selectedRange: ${controller.selectedRange.value}');
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              l10n.day,
              l10n.month,
              l10n.quarter,
              l10n.year
            ].asMap().entries.map((entry) {
              final index = entry.key;
              final period = entry.value;
              final isSelected = controller.selectedRange.value == ['Day', 'Month', 'Quarter', 'Year'][index];

              return GestureDetector(
                onTap: () {
                  print('Tapped $period');
                  controller.setTimeRange(['Day', 'Month', 'Quarter', 'Year'][index]);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
                    border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 1) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    period,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}