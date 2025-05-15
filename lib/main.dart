import 'package:boom_solutions_invoice/controllers/customer_list_controller.dart'
    as customer_list;
import 'package:boom_solutions_invoice/final/view/add_Customers.dart'
    as add_customers;
import 'package:boom_solutions_invoice/CustomerDetail/Screen/CustomerListScreen.dart';
import 'package:boom_solutions_invoice/final/view/add_Customers.dart';
import 'package:boom_solutions_invoice/final/view/web_view.dart';
import 'package:boom_solutions_invoice/screens/CustomerStatementPage.dart';
import 'package:boom_solutions_invoice/screens/OfflineScreen.dart';
import 'package:boom_solutions_invoice/screens/PaymentPostScreen.dart';
import 'package:boom_solutions_invoice/screens/Stock.dart';
import 'package:boom_solutions_invoice/screens/customer_detail.dart'
    as customer_detail;
import 'package:boom_solutions_invoice/screens/SetteingsScreen.dart';
import 'package:boom_solutions_invoice/screens/customer_detail.dart';
import 'package:boom_solutions_invoice/screens/liveTracking.dart';
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
import 'package:boom_solutions_invoice/final/controller/themeController.dart';
import 'package:boom_solutions_invoice/final/view/auth_Getx.dart';
import 'package:boom_solutions_invoice/final/view/homeScreen/dashboard_Getx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CustomerDetail/controllers/CustomerDetailController.dart';
import 'screens/invoice_detail_screen.dart';
import 'screens/invoice_list_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';

void main() async {
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
  Get.put(SalesChartController());

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

    return GetMaterialApp(
      title: 'Invoice App',
      
      locale: Get.deviceLocale,
      
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: Get.find<ThemeController>().theme,
      debugShowCheckedModeBanner: false,
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
                'https://onix.boom-solutions.co/web/login?redirect=%2Fodoo%3F';
            return WebViewScreen(url: url);
          },
          transition: Transition.leftToRightWithFade,
          preventDuplicates: false,
        ),
      ],
    );
  }
}



// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();
//   await Get.putAsync(() => SharedPreferences.getInstance());

//   // Initialize ConnectivitySpervice
//   final connectivityService = ConnectivityService();
//   Get.put(connectivityService, permanent: true);
//   connectivityService.onInit(); // Ensure onInit is called

//   // Initialize other controllers and services
//   Get.put(LocationTrackerController(), permanent: true);
//   Get.put(ThemeController(), permanent: true);
//   Get.put(AuthController());
//   Get.put(CustomerDetailController());
//   Get.put(customer_list.CustomerListController());
//   Get.put(CustomWebViewController(), permanent: true);
//   Get.put(SalesController());
//   Get.put(SalesChartController());

//   // Register LocationTrackerController
//   Get.put(LocationTrackerController(), permanent: true);

//   // Initialize LocationTrackerController
//   final locationTracker = Get.find<LocationTrackerController>();
//   final token = GetStorage().read('token') ?? '';

//   locationTracker.setApiToken('$token');
//   GetStorage().writeIfNull('apiUrl', 'https://onix.boom-solutions.co/');
//   runApp(InvoiceApp());
// }

// class InvoiceApp extends StatelessWidget {
//   const InvoiceApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Register additional controllers
//     Get.put(DashboardController());
//     Get.put(InvoiceController());
//     Get.put(SalesController());
//     Get.put(customer_detail.CustomerController()); 
//     // Get.put(CustomerListController());
//     Get.put(customer_list.CustomerListController());

//     return GetMaterialApp(
//       title: 'Invoice App',
//       theme: lightTheme,
//       locale: Get.deviceLocale,
//       fallbackLocale:  Locale('en', 'US'),
//       darkTheme: darkTheme,
//       themeMode: Get.find<ThemeController>().theme,
//       debugShowCheckedModeBanner: false,
//       localizationsDelegates: [
//         S.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: S.delegate.supportedLocales,
//       initialRoute: '/splash',
//       getPages: [
//         GetPage(name: '/splash', page: () => SplashScreen()),
//         GetPage(name: '/auth', page: () => AuthScreen()),
//         GetPage(name: '/dashboard', page: () => SalesDashboard()),
//         GetPage(name: '/settings', page: () => SettingsScreen()),
//         GetPage(name: '/login', page: () => AuthScreen()),
//         GetPage(name: '/aaa', page: () => DashboardChartScreen()),
//         GetPage(name: '/a', page: () => customer_detail.CustomerDetailScreen(partnerId: 0)),
//         GetPage(name: '/addcustomer', page: () => add_customers.CustomerAddPage()),
//         GetPage(name: '/customers', page: () => CustomersListScreen()),
//         GetPage(name: '/invoiceDetail', page: () => InvoiceDetailScreen()),
//         GetPage(name: '/Stock', page: () => InventoryScreen()),
//         GetPage(name: '/NearByCustomer', page: () => MapScreen()),
//         GetPage(name: '/VisitsScreen', page: () => VisitsScreen()),
//         GetPage(name: '/CheckInScreen', page: () => CheckInScreen()),
//         GetPage(
//           name: '/dashboard',
//           page: () => SalesDashboard(),
//           transition: Transition.noTransition,
//           preventDuplicates: false,
//         ),
//         GetPage(
//           name: '/webView',
//           page: () {
//             final apiurl = GetStorage().read("apiUrl");
//             final url =
//                 'https://onix.boom-solutions.co/web/login?redirect=%2Fodoo%3F';
//             return WebViewScreen(url: url);
//           },
//           transition: Transition.leftToRightWithFade,
//           preventDuplicates: false,
//         ),
//       ],
//     );
//   }
// }