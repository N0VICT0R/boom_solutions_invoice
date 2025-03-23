import 'package:boom_solutions_invoice/final/view/add_Customers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import 'invoice_detail_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Invoice Dashboard',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    PerformanceCard(),
    Center(child: CustomerAddPage()),
    Center(child: Text('Create Invoice Page')),
    Center(child: InvoiceDetailScreen()),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('da'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Get.to(() => SettingsScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
        ],
      ),
    );
  }
}

class PerformanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // Adjusted to 2 since only two tabs are provided.
      length: 2,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveWidget.isMobile(context) ? 16 : 24,
            vertical: 16,
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Performance",
                    style: TextStyle(
                      fontSize:
                      ResponsiveWidget.isMobile(context) ? 18 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.more_horiz, color: Colors.grey),
                ],
              ),
              SizedBox(height: 20),
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 35.0, right: 30),
                        child: Tab(text: "Sales"),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 35.0, right: 30),
                        child: Tab(text: "Collections"),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Product Stats & Sales Info
              ResponsiveWidget(
                mobile: Column(
                  children: [
                    _buildProductStats(),
                    SizedBox(height: 20),
                    _buildSalesInfo(),
                  ],
                ),
                desktop: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildProductStats()),
                    SizedBox(width: 20),
                    Expanded(child: _buildSalesInfo()),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Chart
              Container(
                height: 200,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildChart(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductStats() {
    return Row(
      children: [
        _productStat("🔥 Digital Product", "8,490", Colors.orange),
        SizedBox(width: 10),
        _productStat("📦 Physical Product", "9,250", Colors.green),
      ],
    );
  }

  Widget _buildSalesInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Total Online Sales",
            style: TextStyle(color: Colors.grey)),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              "\$59,410",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Row(
              children: [
                Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                Text("15.52%",
                    style: TextStyle(color: Colors.green)),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        Text("18% until your target this month",
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _productStat(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              )),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final List<FlSpot> thisMonthData = [
      FlSpot(0, 1.8),
      FlSpot(1, 2.2),
      FlSpot(2, 1.7),
      FlSpot(3, 2.4),
      FlSpot(4, 2.1),
      FlSpot(5, 2.5),
    ];

    final List<FlSpot> lastMonthData = [
      FlSpot(0, 1.5),
      FlSpot(1, 1.8),
      FlSpot(2, 1.6),
      FlSpot(3, 2.0),
      FlSpot(4, 1.8),
      FlSpot(5, 2.0),
      FlSpot(5, 2.0),
      FlSpot(5, 2.0),
      FlSpot(5, 2.0),
      FlSpot(5, 2.0),
      FlSpot(5, 2.0),
      FlSpot(5, 2.0),
      FlSpot(5, 2.0),
      FlSpot(5, 2.0),
      FlSpot(5, 2.0),
    ];

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false), // Hide grid lines
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  List<String> months = [
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
                  int currentMonth = DateTime.now().month - 1;
                  List<String> displayedMonths;

                  // If screen width is large, show all months, otherwise show last 5
                  if (MediaQuery.of(context).size.width > 200) {
                    displayedMonths = months;
                  } else {
                    displayedMonths = months.sublist(
                      (currentMonth -0
                      ).clamp(0, months.length - 1),
                      currentMonth + 1,
                    );
                  }

                  return Text(
                    displayedMonths.contains(months[value.toInt()])
                        ? months[value.toInt()]
                        : "",
                    style: TextStyle(fontSize: 12),
                  );
                },
                reservedSize: 22,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false, // Hides all chart borders
          ),
          lineBarsData: [
            LineChartBarData(
              spots: thisMonthData,
              isCurved: true,
              color: Colors.purple,
              barWidth: 4,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withOpacity(0.4),
                    Colors.purple.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Light Theme'),
            onTap: () => Get.changeThemeMode(ThemeMode.light),
          ),
          ListTile(
            title: Text('Dark Theme'),
            onTap: () => Get.changeThemeMode(ThemeMode.dark),
          ),
          ListTile(
            title: Text('System Theme'),
            onTap: () => Get.changeThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const ResponsiveWidget({
    required this.mobile,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}
