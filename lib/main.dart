// import 'package:boom_solutions_invoice/final/view/add_Customers.dart';

import 'package:boom_solutions_invoice/CustomerDetail/Screen/CustomerListScreen.dart';
import 'package:boom_solutions_invoice/final/view/add_Customers.dart';
import 'package:boom_solutions_invoice/final/view/web_view.dart';
import 'package:boom_solutions_invoice/screens/CustomerStatementPage.dart';
import 'package:boom_solutions_invoice/screens/PaymentPostScreen.dart';
import 'package:boom_solutions_invoice/screens/Stock.dart';
import 'package:boom_solutions_invoice/screens/customer_detail.dart';
import 'package:boom_solutions_invoice/screens/SetteingsScreen.dart';
import 'package:boom_solutions_invoice/screens/liveTracking.dart';

import 'package:boom_solutions_invoice/screens/splashScreen.dart';
import 'package:boom_solutions_invoice/screens/maps/NearbyCustomer.dart';
import 'package:boom_solutions_invoice/screens/visits_hestory_customer_Screen.dart';
import 'package:boom_solutions_invoice/widgets/line_syncf_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:boom_solutions_invoice/final/controller/auth_controller.dart';
import 'package:boom_solutions_invoice/final/controller/dashbord_Controller.dart';
import 'package:boom_solutions_invoice/final/controller/themeController.dart';
import 'package:boom_solutions_invoice/final/view/auth_Getx.dart';
import 'package:boom_solutions_invoice/final/view/dashboard_Getx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CustomerDetail/controllers/CustomerDetailController.dart';
import 'screens/invoice_detail_screen.dart';
import 'screens/invoice_list_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Get.putAsync(() => SharedPreferences.getInstance());
  
  // Initialize controllers
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(CustomerDetailController());
  Get.put(CustomerListController());
  // Controllers that should persist throughout the app
  Get.put(ThemeController(), permanent: true);
  Get.put(CustomWebViewController(), permanent: true);
  Get.put(SalesController()); 
  
   
  runApp(InvoiceApp());
}

class InvoiceApp extends StatelessWidget {
  InvoiceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Register additional controllers
    Get.put(DashboardController());
    // Get.put(PartnerController());
    Get.put(InvoiceController());
    Get.put(SalesController());

    return GetMaterialApp(
      title: 'Invoice App' ,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Get.find<ThemeController>().theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/auth', page: () =>  AuthScreen()),
        GetPage(name: '/dashboard', page: () => SalesDashboard()),
        GetPage(name: '/settings', page: () => SettingsScreen()),
        GetPage(name: '/login', page: () =>  AuthScreen()),
        GetPage(name: '/aaa', page: () => DashboardChartScreen()),
        // GetPage(name: '/PaymentPost', page: () => InvoicePaymentPage()),
        GetPage(name: '/a', page: () => CustomerDetailScreen(partnerId: 0,)),
        GetPage(name: '/addcustomer', page: () => CustomerAddPage()),
        GetPage(name: '/customers', page: () => CustomersListScreen()),
        GetPage(name: '/invoiceDetail', page: () => InvoiceDetailScreen()),
        GetPage(name: '/invoices', page: () => InvoiceListScreen()),
        GetPage(name: '/Stock', page: () => InventoryScreen()),
        GetPage(name: '/NearByCustomer', page: () => MapScreen()),
        GetPage(name: '/VisitsScreen', page: () => VisitsScreen()),
        // GetPage(name: '/Stock', page: () => LiveTrackingPage()),
        GetPage(
          name: '/dashboard',
          page: () => SalesDashboard(),
          transition: Transition.noTransition,
          preventDuplicates: false,
        ),
        GetPage(
          name: '/webView',
          page: () => WebViewScreen(
              url: 'http://137.184.205.67:2710/web/login?redirect=%2Fodoo%3F'),
          transition: Transition.leftToRightWithFade,
          preventDuplicates: false,
        ),
      ],
    );
  }
}