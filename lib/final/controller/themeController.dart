import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  ThemeMode get theme => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    _isDarkMode.value = _box.read('isDarkMode') ?? false;
    super.onInit();
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _box.write('isDarkMode', _isDarkMode.value);
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void createNewDeal() {
    // Handle new deal creation
    Get.toNamed('/new-deal');
  }

  void collectPayment() {
    // Handle payment collection
    Get.toNamed('/collect-payment');
  }

  void logVisit() {
    // Handle visit logging
    Get.toNamed('/log-visit');
  }
}

class AppColors {
  static const Color primaryLight = Colors.black;
  static const Color primaryDark = Colors.white;
  static const Color backgroundLight = Color.fromARGB(237, 255, 255, 255);
  static const Color backgroundDark = Color(0xff141414);
  static const Color textLight = Colors.black;
  static const Color textDark = Colors.white;
  static const Color cardLight = Color.fromARGB(255, 255, 255, 255);
  static Color cardDark =  Color.fromARGB(255, 26, 25, 25);
  static const Color buttonLight = Colors.black;
  static Color buttonDark = Colors.black54;
  static const Color containerLight = Colors.white70;
  static const Color containerDark = Colors.black54;
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.textLight),
  ),
  cardColor: AppColors.cardLight,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonLight,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  iconTheme: IconThemeData(
    color: Colors.black,
    
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.textDark),
  ),
  cardColor: AppColors.cardDark,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonDark,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  iconTheme: IconThemeData(
    color: AppColors.textDark,
  ),
);

class AppTheme {
  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;
}
