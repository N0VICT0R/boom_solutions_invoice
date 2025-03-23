import 'package:flutter/material.dart';



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  String selectedLanguage = 'english';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? _darkTheme : _lightTheme,
      home: Directionality(
        // Change text direction based on language
        textDirection: selectedLanguage == 'arabic' ? TextDirection.rtl : TextDirection.ltr,
        child: SettingsScreen(
          isDarkMode: isDarkMode,
          selectedLanguage: selectedLanguage,
          onThemeChanged: (value) {
            setState(() {
              isDarkMode = value;
            });
          },
          onLanguageChanged: (value) {
            setState(() {
              selectedLanguage = value;
            });
          },
        ),
      ),
    );
  }
}

// Light theme definition
final _lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: const Color(0xFFF7F7F7),
    surface: Colors.white,
    primary: Colors.grey.shade800,
    onSurface: const Color(0xFF333333),
  ),
  dividerColor: const Color(0xFFE0E0E0),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF333333),
    elevation: 0,
  ),
  fontFamily: 'Roboto',
);

// Dark theme definition
final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: const Color(0xFF121212),
    surface: const Color(0xFF242424),
    primary: Colors.grey.shade400,
    onSurface: const Color(0xFFE0E0E0),
  ),
  dividerColor: const Color(0xFF3A3A3A),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: const Color(0xFF242424),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF242424),
    foregroundColor: Color(0xFFE0E0E0),
    elevation: 0,
  ),
  fontFamily: 'Roboto',
);

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final String selectedLanguage;
  final Function(bool) onThemeChanged;
  final Function(String) onLanguageChanged;

  const SettingsScreen({
    Key? key,
    required this.isDarkMode,
    required this.selectedLanguage,
    required this.onThemeChanged,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = selectedLanguage == 'arabic';

    // Localized strings
    final strings = {
      'settings': isArabic ? 'الإعدادات' : 'Settings',
      'language': isArabic ? 'اللغة' : 'Language',
      'english': isArabic ? 'الإنجليزية' : 'English',
      'arabic': isArabic ? 'العربية' : 'Arabic',
      'appearance': isArabic ? 'المظهر' : 'Appearance',
      'darkMode': isArabic ? 'الوضع الداكن' : 'Dark Mode',
      'themeDescription': isArabic
          ? 'التبديل بين السمات الفاتحة والداكنة'
          : 'Switch between light and dark themes',
      'back': isArabic ? 'رجوع' : 'Back',
    };

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          strings['settings']!,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward : Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () {
            // Handle back navigation
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings['language']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildRadioTile(
                          context,
                          title: strings['english']!,
                          value: 'english',
                          groupValue: selectedLanguage,
                          onChanged: (value) => onLanguageChanged(value!),
                        ),
                        _buildRadioTile(
                          context,
                          title: strings['arabic']!,
                          value: 'arabic',
                          groupValue: selectedLanguage,
                          onChanged: (value) => onLanguageChanged(value!),
                          isArabic: true,
                        ),
                      ],
                    ),
                  ),
                  Divider(color: theme.dividerColor),
                  // Appearance Section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings['appearance']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildSwitchTile(
                          context,
                          title: strings['darkMode']!,
                          subtitle: strings['themeDescription']!,
                          value: isDarkMode,
                          onChanged: onThemeChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Handle back navigation
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(color: theme.dividerColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(strings['back']!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile(
    BuildContext context, {
    required String title,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
    bool isArabic = false,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
              fontFamily: isArabic ? 'Tajawal' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}