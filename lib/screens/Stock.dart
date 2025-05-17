import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:boom_solutions_invoice/generated/l10n.dart';
import 'package:google_fonts/google_fonts.dart';

// Utility for responsive font sizes
double getResponsiveFontSize(BuildContext context, double baseFontSize) {
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth / 400;
  return (baseFontSize * scaleFactor).clamp(baseFontSize * 0.8, baseFontSize * 1.2);
}

// Utility for formatting numbers with Arabic suffixes
String formatNumber(double value, {bool isCurrency = true}) {
  final bool isArabic = Get.locale?.languageCode == 'ar';

  if (value < 1000) {
    if (isCurrency) {
      return intl.NumberFormat("#,##0.00", isArabic ? 'ar' : 'en').format(value);
    }
    return intl.NumberFormat("#,##0", isArabic ? 'ar' : 'en').format(value);
  }

  if (isArabic) {
    const suffixes = [' ألف', ' مليون', ' مليار', ' تريليون'];
    int suffixIndex = -1;
    double scaledValue = value;
    while (scaledValue >= 1000 && suffixIndex < suffixes.length - 1) {
      scaledValue /= 1000;
      suffixIndex++;
    }
    String formatted = intl.NumberFormat("#,##0.00", 'ar').format(scaledValue);
    if (formatted.endsWith('.00')) {
      formatted = formatted.substring(0, formatted.length - 3);
    }
    return '$formatted${suffixes[suffixIndex]}';
  }

  const suffixes = ['k', 'M', 'B', 'T'];
  int suffixIndex = -1;
  double scaledValue = value;
  while (scaledValue >= 1000 && suffixIndex < suffixes.length - 1) {
    scaledValue /= 1000;
    suffixIndex++;
  }
  String formatted = intl.NumberFormat("#,##0.00", 'en').format(scaledValue);
  if (formatted.endsWith('.00')) {
    formatted = formatted.substring(0, formatted.length - 3);
  }
  return '$formatted${suffixes[suffixIndex]}';
}

// Utility to detect text direction based on content
TextDirection getTextDirection(String text) {
  if (text.isEmpty) return TextDirection.ltr;
  // Check if the text contains Arabic characters (Unicode range for Arabic)
  final hasArabic = text.contains(RegExp(r'[\u0600-\u06FF]'));
  return hasArabic ? TextDirection.rtl : TextDirection.ltr;
}

// Define a model class for our inventory data
class InventoryData {
  final bool success;
  final LocationInfo location;
  final UserInfo user;
  final int count;
  final List<Product> products;

  InventoryData({
    required this.success,
    required this.location,
    required this.user,
    required this.count,
    required this.products,
  });

  factory InventoryData.fromJson(Map<String, dynamic> json) {
    return InventoryData(
      success: json['success'] ?? false,
      location: LocationInfo.fromJson(json['location'] ?? {}),
      user: UserInfo.fromJson(json['user'] ?? {}),
      count: json['count'] ?? 0,
      products: (json['products'] as List?)
          ?.map((product) => Product.fromJson(product))
          .toList() ?? [],
    );
  }
}

class LocationInfo {
  final int id;
  final String name;
  final String completeName;

  LocationInfo({
    required this.id,
    required this.name,
    required this.completeName,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      completeName: json['complete_name'] ?? '',
    );
  }
}

class UserInfo {
  final int id;
  final String name;

  UserInfo({
    required this.id,
    required this.name,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Product {
  final int productId;
  final String name;
  final String defaultCode;
  final String barcode;
  final int categoryId;
  final String categoryName;
  final double quantity;
  final double reservedQuantity;
  final double availableQuantity;
  final String uom;
  final double price;
  final String imageUrl;

  Product({
    required this.productId,
    required this.name,
    required this.defaultCode,
    required this.barcode,
    required this.categoryId,
    required this.categoryName,
    required this.quantity,
    required this.reservedQuantity,
    required this.availableQuantity,
    required this.uom,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      defaultCode: json['default_code'] ?? '',
      barcode: json['barcode'] ?? '',
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      reservedQuantity: (json['reserved_quantity'] ?? 0).toDouble(),
      availableQuantity: (json['available_quantity'] ?? 0).toDouble(),
      uom: json['uom'] ?? 'Units',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isLoading = true;
  InventoryData? _inventoryData;
  String? _errorMessage;
  String? _csrfToken;

  @override
  void initState() {
    super.initState();
    _fetchCsrfToken().then((_) => fetchInventoryData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCsrfToken() async {
    try {
      final apiUrl = GetStorage().read("apiUrl") ?? "";
      if (apiUrl.isEmpty) return;
      final url = Uri.parse('$apiUrl/api/v1/csrf-token');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _csrfToken = jsonData['csrf_token'];
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch CSRF token: $e');
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final apiUrl = GetStorage().read("apiUrl") ?? "";
      final userId = GetStorage().read('user_id');
      if (apiUrl.isEmpty || userId == null) return false;
      final url = Uri.parse('$apiUrl/api/v1/users/$userId/refresh-token');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_csrfToken != null) 'X-CSRF-Token': _csrfToken!,
        },
        body: jsonEncode({}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final newToken = jsonData['token'];
        GetStorage().write('token', newToken);
        await _fetchCsrfToken();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return false;
    }
  }

  Future<void> fetchInventoryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = GetStorage().read('token') ?? '';
      final apiUrl = GetStorage().read("apiUrl") ?? 'http://137.184.205.67:2710';
      if (token.isEmpty) {
        throw Exception('Missing token');
      }
      final response = await http.get(
        Uri.parse('$apiUrl/api/v1/inventory/quantities?api_token=$token'),
        headers: {
          'Authorization': 'Bearer $token',
          if (_csrfToken != null) 'X-CSRF-Token': _csrfToken!,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _inventoryData = InventoryData.fromJson(data);
          _isLoading = false;
        });
      } else if (response.statusCode == 400 && response.body.contains('invalid CSRF token')) {
        if (await _refreshToken()) {
          await fetchInventoryData();
          return;
        }
        throw Exception('Failed to refresh token');
      } else {
        setState(() {
          _errorMessage = S.of(context).errorLoadingData(response.statusCode);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = S.of(context).errorGeneric(e.toString());
        _isLoading = false;
      });
    }
  }

  List<Product> _getFilteredProducts() {
    if (_inventoryData == null) return [];

    if (_searchQuery.isEmpty) {
      return _inventoryData!.products;
    }

    return _inventoryData!.products
        .where((product) => product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final secondaryColor = theme.colorScheme.secondary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = theme.textTheme.bodyMedium?.color ?? Colors.black54;
    final isRTL = Get.locale?.languageCode == 'ar';
    final l10n = S.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (_errorMessage != null && _inventoryData == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingDataTitle,
                style: GoogleFonts.poppins(
                  fontSize: getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  fontSize: getResponsiveFontSize(context, 14),
                  color: subtitleColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: fetchInventoryData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  l10n.retry,
                  style: GoogleFonts.poppins(
                    fontSize: getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: l10n.searchInventory,
                  hintStyle: GoogleFonts.poppins(
                    color: subtitleColor.withOpacity(0.7),
                    fontSize: getResponsiveFontSize(context, 16),
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: getResponsiveFontSize(context, 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(
                _inventoryData?.location.name ?? l10n.inventory,
                style: GoogleFonts.poppins(
                  fontSize: getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                ),
                textDirection: getTextDirection(_inventoryData?.location.name ?? l10n.inventory),
              ),
        leading: _isSearchActive
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                onPressed: () {
                  setState(() {
                    _isSearchActive = false;
                    _searchQuery = "";
                    _searchController.clear();
                  });
                },
              )
            : null,
        actions: [
          if (!_isSearchActive) ...[
            IconButton(
              icon: Icon(Icons.search, color: theme.iconTheme.color),
              onPressed: () {
                setState(() {
                  _isSearchActive = true;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: theme.iconTheme.color),
              onPressed: fetchInventoryData,
            ),
          ],
        ],
        elevation: theme.appBarTheme.elevation ?? 0,
      ),
      body: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Header info section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${l10n.location}: ${_inventoryData?.location.completeName ?? ''}",
                          style: GoogleFonts.poppins(
                            fontSize: getResponsiveFontSize(context, 14),
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                          textDirection: getTextDirection(_inventoryData?.location.completeName ?? ''),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${l10n.user}: ${_inventoryData?.user.name ?? ''}",
                          style: GoogleFonts.poppins(
                            fontSize: getResponsiveFontSize(context, 12),
                            color: subtitleColor,
                          ),
                          textDirection: getTextDirection(_inventoryData?.user.name ?? ''),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "${l10n.items}: ${formatNumber(_inventoryData?.count.toDouble() ?? 0, isCurrency: false)}",
                      style: GoogleFonts.poppins(
                        fontSize: getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.colorScheme.surface.withOpacity(0.5),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      l10n.product,
                      style: GoogleFonts.poppins(
                        fontSize: getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: textColor,
                      ),
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      l10n.quantity,
                      style: GoogleFonts.poppins(
                        fontSize: getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      l10n.available,
                      style: GoogleFonts.poppins(
                        fontSize: getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      l10n.price,
                      style: GoogleFonts.poppins(
                        fontSize: getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: textColor,
                      ),
                      textAlign: isRTL ? TextAlign.left : TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            // List of products
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: subtitleColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? l10n.noInventoryItems
                                : l10n.noMatchingItems,
                            style: GoogleFonts.poppins(
                              fontSize: getResponsiveFontSize(context, 16),
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final bool isEven = index % 2 == 0;

                        return Material(
                          color: isEven
                              ? backgroundColor
                              : theme.colorScheme.surface.withOpacity(0.2),
                          child: InkWell(
                            onTap: () {
                              debugPrint('Tapped product: ${product.name}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.selectedProduct(product.name),
                                    style: GoogleFonts.poppins(
                                      fontSize: getResponsiveFontSize(context, 14),
                                      color: Colors.white,
                                    ),
                                    textDirection: getTextDirection(product.name),
                                  ),
                                  backgroundColor: primaryColor,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: isRTL ? 8 : 16,
                                right: isRTL ? 16 : 8,
                                top: 12,
                                bottom: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          product.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: getResponsiveFontSize(context, 16),
                                            fontWeight: FontWeight.w500,
                                            color: textColor,
                                          ),
                                          textDirection: getTextDirection(product.name),
                                          textAlign: isRTL ? TextAlign.right : TextAlign.left,
                                        ),
                                        if (product.categoryName.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            product.categoryName,
                                            style: GoogleFonts.poppins(
                                              fontSize: getResponsiveFontSize(context, 12),
                                              color: subtitleColor,
                                            ),
                                            textDirection: getTextDirection(product.categoryName),
                                            textAlign: isRTL ? TextAlign.right : TextAlign.left,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${formatNumber(product.quantity, isCurrency: false)} ${product.uom}",
                                      style: GoogleFonts.poppins(
                                        fontSize: getResponsiveFontSize(context, 14),
                                        color: textColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${formatNumber(product.availableQuantity, isCurrency: false)} ${product.uom}",
                                      style: GoogleFonts.poppins(
                                        fontSize: getResponsiveFontSize(context, 14),
                                        color: textColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "${formatNumber(product.price)}",
                                      style: GoogleFonts.poppins(
                                        fontSize: getResponsiveFontSize(context, 14),
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                      ),
                                      textAlign: isRTL ? TextAlign.left : TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// // Add this screen to your app
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Inventory App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF212121),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF212121),
//           brightness: Brightness.light,
//         ),
//         scaffoldBackgroundColor: Colors.white,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.white,
//           foregroundColor: Color(0xFF212121),
//           elevation: 0,
//           centerTitle: false,
//           titleTextStyle: TextStyle(
//             color: Color(0xFF212121),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         dividerTheme: const DividerThemeData(
//           thickness: 1,
//           color: Color(0xFFEEEEEE),
//         ),
//         textTheme: GoogleFonts.poppinsTextTheme(),
//       ),
//       localizationsDelegates: const [
//         S.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: S.delegate.supportedLocales,
//       home: const InventoryScreen(),
//     );
//   }
// }