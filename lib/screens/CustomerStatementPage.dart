import 'dart:convert';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class Transaction {
  final String date;
  final double balance;
  final double paid;
  final String reference;
  final String transactionType;

  Transaction({
    required this.date,
    required this.balance,
    this.paid = 0.0,
    this.reference = '',
    this.transactionType = '',
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      date: json['date'],
      balance: (json['balance'] as num).toDouble(),
      paid: (json['credit'] as num).toDouble(),
      reference: json['reference'] ?? '',
      transactionType: json['transaction_type'] ?? '',
    );
  }
}

double symlog(double y) => y == 0 ? 0 : y.sign * math.log(1 + y.abs());
double symexp(double x) => x == 0 ? 0 : x.sign * (math.exp(x.abs()) - 1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const DashboardChartScreen(),
    );
  }
}

class DashboardChartScreen extends StatefulWidget {
  const DashboardChartScreen({super.key});

  @override
  _DashboardChartScreenState createState() => _DashboardChartScreenState();
}

class _DashboardChartScreenState extends State<DashboardChartScreen> {
  final List<String> timeRanges = [
    'Last 7 Days',
    'Last 30 Days',
    'This Month',
    'This Quarter',
    'This Year',
    'Last Month',
    'Last Quarter',
    'Last Year',
    'All Time',
    'Custom',
  ];

  String selectedRange = 'Last 30 Days';
  String customRangeLabel = '';
  DateTime? startDate;
  DateTime? endDate;
List<Transaction> allTransactions = [
  Transaction(
    date: "2025-03-07",
    reference: "INV/2025/00006",
    transactionType: "Invoice",
    balance: 0.0,
  ),
  Transaction(
    date: "2025-03-07",
    reference: "INV/2025/00006",
    transactionType: "Invoice",
    balance: 100.0,
  ),
  Transaction(
    date: "2025-03-07",
    reference: "INV/2025/00006",
    transactionType: "Invoice",
    balance: 500.0,
  ),
  Transaction(
    date: "2025-03-08",
    reference: "INV/2025/00006",
    transactionType: "Invoice",
    balance: 600.0,
  ),
  Transaction(
    date: "2025-03-09",
    reference: "INV/2025/00006",
    transactionType: "Invoice",
    balance: 730.0,
  ),
  Transaction(
    date: "2025-03-10",
    reference: "INV/2025/00006",
    transactionType: "Invoice",
    balance: 800.0,
  ),
  Transaction(
    date: "2025-03-11",
    reference: "INV/2025/00006",
    transactionType: "Invoice",
    balance: 200.0,
  ),
  Transaction(
    date: "2025-03-12",
    reference: "INV/2025/00006",
    transactionType: "Invoice",
    balance: 1000.0,
  ),
  Transaction(
    date: "2025-03-13",
    reference: "INV/2025/00006",
    transactionType: "Invoice",
    balance: 2000.0,
  ),
  Transaction(
    date: "2025-03-14",
    reference: "INV/2025/00008",
    transactionType: "Invoice",
    balance: 3500.0,
  ),
  Transaction(
    date: "2025-03-15",
    reference: "INV/2025/00009",
    transactionType: "Invoice",
    balance: 4000.0,
  ),
  Transaction(
    date: "2025-03-16",
    reference: "INV/2025/00010",
    transactionType: "Invoice",
    balance: 4200.0,
  ),
  Transaction(
    date: "2025-03-17",
    reference: "INV/2025/00011",
    transactionType: "Invoice",
    balance: 4400.0,
  ),
  Transaction(
    date: "2025-03-18",
    reference: "INV/2025/00012",
    transactionType: "Invoice",
    balance: 4600.0,
  ),
  Transaction(
    date: "2025-03-19",
    reference: "INV/2025/00013",
    transactionType: "Invoice",
    balance: 4800.0,
  ),
  Transaction(
    date: "2025-03-20",
    reference: "INV/2025/00014",
    transactionType: "Invoice",
    balance: 5000.0,
  ),
  Transaction(
    date: "2025-03-21",
    reference: "INV/2025/00015",
    transactionType: "Invoice",
    balance: 5200.0,
  ),
  Transaction(
    date: "2025-03-22",
    reference: "INV/2025/00016",
    transactionType: "Invoice",
    balance: 5400.0,
  ),
  Transaction(
    date: "2025-03-23",
    reference: "INV/2025/00017",
    transactionType: "Invoice",
    balance: 5600.0,
  ),
  Transaction(
    date: "2025-03-24",
    reference: "INV/2025/00018",
    transactionType: "Invoice",
    balance: 5800.0,
  ),
];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    await Future.delayed(const Duration(seconds: 1));
    const String responseData = '''[Your JSON Data Here]''';
    
    final Map<String, dynamic> data = jsonDecode(responseData);
    final List transactionsJson = data['statement']['transactions'];
    
    setState(() {
      allTransactions = transactionsJson
          .map((json) => Transaction.fromJson(json))
          .toList();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: (startDate != null && endDate != null)
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        customRangeLabel =
            "${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}";
      });
    }
  }

  (DateTime?, DateTime?) _getSelectedDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedRange) {
      case 'Last 7 Days':
        return (today.subtract(const Duration(days: 7)), today);
      case 'Last 30 Days':
        return (today.subtract(const Duration(days: 30)), today);
      case 'This Month':
        return (DateTime(today.year, today.month, 1), today);
      case 'This Quarter':
        final quarterStartMonth = ((today.month - 1) ~/ 3) * 3 + 1;
        return (DateTime(today.year, quarterStartMonth, 1), today);
      case 'This Year':
        return (DateTime(today.year, 1, 1), today);
      case 'Last Month':
        final lastMonth = today.month == 1 
            ? DateTime(today.year - 1, 12, 1) 
            : DateTime(today.year, today.month - 1, 1);
        return (lastMonth, DateTime(lastMonth.year, lastMonth.month + 1, 0));
      case 'Last Quarter':
        final lastQuarter = ((today.month - 1) ~/ 3) - 1;
        final year = lastQuarter < 0 ? today.year - 1 : today.year;
        final quarterStartMonth = (lastQuarter % 4) * 3 + 1;
        return (
          DateTime(year, quarterStartMonth, 1),
          DateTime(year, quarterStartMonth + 3, 0)
        );
      case 'Last Year':
        return (DateTime(today.year - 1, 1, 1), DateTime(today.year - 1, 12, 31));
      case 'All Time':
        return (null, null);
      case 'Custom':
        return (startDate, endDate);
      default:
        return (null, null);
    }
  }

  List<Transaction> get filteredTransactions {
    if (allTransactions.isEmpty) return [];
    final (rangeStart, rangeEnd) = _getSelectedDateRange();
    
    return allTransactions.where((t) {
      try {
        final txDate = DateFormat('yyyy-MM-dd').parse(t.date);
        return (rangeStart == null || txDate.isAfter(rangeStart.subtract(const Duration(days: 1)))) &&
               (rangeEnd == null || txDate.isBefore(rangeEnd.add(const Duration(days: 1))));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDateFilter(),
            const SizedBox(height: 16),
            _buildStatsCards(),
            const SizedBox(height: 16),
            Expanded(child: _buildChartCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
       ) ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedRange,
        items: timeRanges.map((range) => DropdownMenuItem(
          value: range,
          child: Text(range),
        )).toList(),
        onChanged: (value) => setState(() {
          selectedRange = value!;
          if (selectedRange == 'Custom') _selectDateRange();
        }),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: Icon(Icons.calendar_today, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildStatCard('Total Sales', Icons.bar_chart, '£0.00'),
              const SizedBox(height: 16),
              _buildStatCard('Total Paid', Icons.attach_money, '£0.00'),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: _buildStatCard('Total Sales', Icons.bar_chart, '£0.00')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Total Paid', Icons.attach_money, '£0.00')),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, IconData icon, String value) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: Colors.grey[800]),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
            ]),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('0 invoices', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sales Trending', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SalesTrendingDetailScreen(
                        transactions: filteredTransactions,
                        dateRange: selectedRange,
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text('More Details'),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SalesLineChart(transactions: filteredTransactions),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesLineChart extends StatelessWidget {
  final List<Transaction> transactions;

  const SalesLineChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions available'));
    }

    final sortedTransactions = [...transactions]
      ..sort((a, b) => a.date.compareTo(b.date));

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = math.max(sortedTransactions.length * 60.0, constraints.maxWidth);
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: constraints.maxHeight,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((spot) {
                      final index = spot.x.toInt();
                      return LineTooltipItem(
                        '${sortedTransactions[index].date}\nBalance: ${sortedTransactions[index].balance}',
                        const TextStyle(color: Colors.black),
                      );
                    }).toList(),
                  ),
                ),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedTransactions.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('dd/MM').format(
                              DateTime.parse(sortedTransactions[index].date)),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: sortedTransactions
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), symlog(e.value.balance)))
                        .toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SalesTrendingDetailScreen extends StatelessWidget {
  final List<Transaction> transactions;
  final String dateRange;

  const SalesTrendingDetailScreen({
    super.key,
    required this.transactions,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Date Range: $dateRange', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Expanded(
              child: SalesLineChart(transactions: transactions),
            ),
          ],
        ),
      ),
    );
  }
}