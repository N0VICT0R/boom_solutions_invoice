import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        brightness: Brightness.light,
      ),
      home: const TimeSeriesChartPage(),
    );
  }
}

class TimeSeriesChartPage extends StatefulWidget {
  const TimeSeriesChartPage({super.key});

  @override
  State<TimeSeriesChartPage> createState() => _TimeSeriesChartPageState();
}

class _TimeSeriesChartPageState extends State<TimeSeriesChartPage> {
  String selectedRange = '7d';
  List<Map<String, dynamic>> fullData = [];
  List<Map<String, dynamic>> displayData = [];
  DateTime? startDate;
  DateTime? endDate;
  bool showDatePicker = false;
  
  @override
  void initState() {
    super.initState();
    _generateSampleData();
    _filterDataByTimeRange('7d');
  }

  void _generateSampleData() {
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

    switch(range) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Activity', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    color: Colors.grey[100],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRange,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16),
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
                        DropdownMenuItem(value: '7d', child: Text('7 Days')),
                        DropdownMenuItem(value: '1m', child: Text('1 Month')),
                        DropdownMenuItem(value: '3m', child: Text('3 Months')),
                        DropdownMenuItem(value: 'q', child: Text('Quarter')),
                        DropdownMenuItem(value: '1y', child: Text('Year')),
                        DropdownMenuItem(value: 'custom', child: Text('Custom')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180, // Reduced height for minimalism
              width: double.infinity,
              child: displayData.isEmpty
                ? const Center(child: Text('No data available'))
                : MinimalLineChart(data: displayData, timeRange: selectedRange),
            ),
          ],
        ),
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
    super.key, 
    required this.data, 
    required this.timeRange,
  });

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
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final date = data[spot.x.toInt()]['date'] as DateTime;
                final value = spot.y;
                return LineTooltipItem(
                  '${DateFormat('MMM d, yyyy').format(date)}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
    if (timeRange == '3m' || timeRange == 'q') return max(1, (data.length / 3).floor().toDouble());
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
                     lastDate.month - firstDate.month;
    
    return monthsDiff >= 6;
  }
}