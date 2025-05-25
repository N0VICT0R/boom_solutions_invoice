import 'package:boom_solutions_invoice/controllers/customer_list_controller.dart'
    as customer_list;
import 'package:boom_solutions_invoice/final/controller/themeController.dart';
import 'package:boom_solutions_invoice/CustomerDetail/Screen/CustomerListScreen.dart';
import 'package:boom_solutions_invoice/final/view/add_Customers.dart';
import 'package:boom_solutions_invoice/final/view/web_view.dart';
import 'package:boom_solutions_invoice/screens/CustomerStatementPage.dart';
import 'package:boom_solutions_invoice/screens/PaymentPostScreen.dart';
import 'package:boom_solutions_invoice/screens/Stock.dart';

import 'package:boom_solutions_invoice/screens/SetteingsScreen.dart';
import 'package:boom_solutions_invoice/screens/customer_detail.dart';
import 'package:boom_solutions_invoice/screens/splashScreen.dart';
import 'package:boom_solutions_invoice/screens/maps/NearbyCustomer.dart';
import 'package:boom_solutions_invoice/screens/visitsScreens/CheckInScreen.dart';
import 'package:boom_solutions_invoice/screens/visitsScreens/visits_hestory_customer_Screen.dart';
import 'package:boom_solutions_invoice/services/ConnectivityService.dart';
import 'package:boom_solutions_invoice/services/location_tracker.dart';
import 'package:boom_solutions_invoice/widgets/line_syncf_chart.dart';
import 'package:boom_solutions_invoice/widgets/salesChart.dart'
    show SalesChartController;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:boom_solutions_invoice/final/controller/auth_controller.dart';
import 'package:boom_solutions_invoice/final/controller/dashbord_Controller.dart';
import 'package:boom_solutions_invoice/final/view/auth_Getx.dart';
import 'package:boom_solutions_invoice/final/view/homeScreen/dashboard_Getx.dart' hide ThemeController;
import 'package:shared_preferences/shared_preferences.dart';
import 'CustomerDetail/controllers/CustomerDetailController.dart';
import 'screens/invoice_detail_screen.dart';
import 'generated/l10n.dart';

void main() async {
    await GetStorage.init();
  GetStorage().writeIfNull('apiUrl', 'https://onix.boom-solutions.co');
  GetStorage().writeIfNull('token', 'gln5EU3jkGwBy7GZWnSpm9N7EffslYS5'); 
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Get.putAsync(() => SharedPreferences.getInstance());

  // Register controllers globally
  Get.put(addCustomerController(), permanent: true);
  final connectivityService = ConnectivityService();
  Get.put(connectivityService, permanent: true);
  connectivityService.onInit();

  Get.put(LocationTrackerController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController());
  Get.put(CustomerDetailController());
  Get.put(customer_list.CustomerListController());
  Get.put(CustomWebViewController(), permanent: true);
  Get.put(SalesController());
  Get.put(SalesChartController(), permanent: true);

  final locationTracker = Get.find<LocationTrackerController>();
  final token = GetStorage().read('token') ?? '';
  locationTracker.setApiToken('$token');
  GetStorage().writeIfNull('apiUrl', 'https://onix.boom-solutions.co/');

  runApp(InvoiceApp());
}

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController());
    Get.put(InvoiceController());
    Get.put(SalesController());
    Get.put(customer_list.CustomerListController());
 final themeController = Get.put(ThemeController());
    return GetMaterialApp(
      title: 'Invoice App',
      // locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeController.theme,
      // themeMode: Get.find<ThemeController>().theme,
      debugShowCheckedModeBanner: false,
      locale: Locale(GetStorage().read('language') ?? 'en'),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      initialRoute: '/splash',
      getPages: [

        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/auth', page: () => AuthScreen()),
        GetPage(name: '/dashboard', page: () => SalesDashboard()),
        GetPage(name: '/settings', page: () => SettingsScreen()),
        GetPage(name: '/login', page: () => AuthScreen()),
        GetPage(name: '/aaa', page: () => DashboardChartScreen()),
        GetPage(name: '/a', page: () => CustomerDetailScreen(partnerId: 0)),
        GetPage(name: '/addcustomer', page: () => CustomerAddPage()),
        GetPage(name: '/customers', page: () => CustomersListScreen()),
        GetPage(name: '/invoiceDetail', page: () => InvoiceDetailScreen()),
        GetPage(name: '/stock', page: () => InventoryScreen()),
        GetPage(name: '/nearbycustomer', page: () => MapScreen()),
        GetPage(name: '/visitsscreen', page: () => VisitsScreen()),
        GetPage(name: '/checkinscreen', page: () => CheckInScreen()),
        GetPage(
          name: '/dashboard',
          page: () => SalesDashboard(),
          transition: Transition.noTransition,
          preventDuplicates: false,
        ),
        GetPage(
          name: '/webview',
          page: () {
            final apiUrl = GetStorage().read('apiUrl');
            final url =
                '$apiUrl/web/login?redirect=%2Fodoo%3F';
            return WebViewScreen(url: url);
          },
          transition: Transition.leftToRightWithFade,
          preventDuplicates: false,
        ),
      ],
    );
  }
}