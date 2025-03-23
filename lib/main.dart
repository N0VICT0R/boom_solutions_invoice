// import 'package:boom_solutions_invoice/final/view/add_Customers.dart';
import 'package:boom_solutions_invoice/final/view/web_view.dart';
import 'package:boom_solutions_invoice/screens/CustomerStatementPage.dart';
import 'package:boom_solutions_invoice/screens/customer_detail.dart';
import 'package:boom_solutions_invoice/screens/new1.dart';
import 'package:boom_solutions_invoice/widgets/line_syncf_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:boom_solutions_invoice/final/controller/auth_controller.dart';
import 'package:boom_solutions_invoice/final/controller/dashbord_Controller.dart';
import 'package:boom_solutions_invoice/final/controller/themeController.dart';
import 'package:boom_solutions_invoice/final/view/auth_Getx.dart';
import 'package:boom_solutions_invoice/final/view/dashboard_Getx.dart';

// import 'controllers/customer_details_controller.dart';
import 'screens/invoice_detail_screen.dart';
import 'screens/invoice_list_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize controllers that need to persist throughout the app's lifecycle
  Get.put(ThemeController(), permanent: true);
  Get.put(CustomWebViewController(), permanent: true); // Add this line
 final controller = Get.put(SalesController());
  runApp(InvoiceApp());
}

class InvoiceApp extends StatelessWidget {
  InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Register other controllers
   
    Get.put(CustomerController());
    Get.put(DashboardController());
    Get.lazyPut(() => AuthController());

    return GetMaterialApp(
      title: 'Invoice App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Get.find<ThemeController>().theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SalesDashboard()),
        // GetPage(name: '/', page: () => TimeSeriesChartPage()),
        GetPage(name: '/aaa', page: () => DashboardChartScreen()),
        GetPage(name: '/a', page: () => CustomerDetailScreen()),
        GetPage(name: '/settings ', page: () => CustomerDetailScreen()),
         GetPage(name: '/customers', page: () => CustomersListScreen()),
        // GetPage(name: '/addCustomer', page: () => CustomerAddPage()),
        GetPage(name: '/invoiceDetail', page: () => InvoiceDetailScreen()),
        GetPage(name: '/invoices', page: () => InvoiceListScreen()),
        GetPage(
          name: '/dashboard',
          page: () => SalesDashboard(),
          transition: Transition.noTransition,
          preventDuplicates: false,
        ),
        GetPage(
          name: '/webView',
          page: () => WebViewScreen(url: 'http://137.184.205.67:2710/web/login?redirect=%2Fodoo%3F'),
          transition: Transition.fade,
          preventDuplicates: false,
        ),
      ],
    );
  }
}


