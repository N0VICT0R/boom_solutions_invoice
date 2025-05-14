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
    Get.toNamed('/new-deal');
  }

  void collectPayment() {
    Get.toNamed('/collect-payment');
  }

  void logVisit() {
    Get.toNamed('/log-visit');
  }
}

class AppColors {
  // Core neutral colors for professionalism
  static const Color primary = Color(0xFF1976D2); // Professional blue for accents
  static const Color secondary = Color(0xFF757575); // Neutral gray for secondary elements

  // Light theme colors
  static const Color backgroundLight = Color(0xFFF5F5F5); // Soft off-white
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white for cards
  static const Color textPrimaryLight = Color(0xFF212121); // Near-black for text
  static const Color textSecondaryLight = Color(0xFF757575); // Gray for secondary text
  static const Color buttonLight = Color(0xFF1976D2); // Blue for buttons
  static const Color buttonTextLight = Color(0xFFFFFFFF); // White text on buttons

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF121212); // Deep dark for background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Slightly lighter for cards
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White for text
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // Light gray for secondary text
  static const Color buttonDark = Color(0xFF1976D2); // Same blue for buttons
  static const Color buttonTextDark = Color(0xFFFFFFFF); // White text on buttons
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  cardColor: AppColors.surfaceLight,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surfaceLight,
    onPrimary: AppColors.buttonTextLight,
    onSurface: AppColors.textPrimaryLight,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryLight,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textPrimaryLight,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.textSecondaryLight,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.buttonTextLight,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonLight,
      foregroundColor: AppColors.buttonTextLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      elevation: 2,
    ),
  ),
  iconTheme: IconThemeData(
    color: AppColors.textPrimaryLight,
    size: 24,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surfaceLight,
    foregroundColor: AppColors.textPrimaryLight,
    elevation: 0,
    centerTitle: true,
  ),
  dividerColor: AppColors.textSecondaryLight.withOpacity(0.2),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  cardColor: AppColors.surfaceDark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surfaceDark,
    onPrimary: AppColors.buttonTextDark,
    onSurface: AppColors.textPrimaryDark,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryDark,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textPrimaryDark,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.textSecondaryDark,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.buttonTextDark,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonDark,
      foregroundColor: AppColors.buttonTextDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      elevation: 2,
    ),
  ),
  iconTheme: IconThemeData(
    color: AppColors.textPrimaryDark,
    size: 24,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textPrimaryDark,
    elevation: 0,
    centerTitle: true,
  ),
  dividerColor: AppColors.textSecondaryDark.withOpacity(0.2),
);

class AppTheme {
  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;
}