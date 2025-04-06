import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  const InventoryScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    fetchInventoryData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchInventoryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
         final token = GetStorage().read('token') ?? '';
      // Replace with your actual API endpoint
      final response = await http.get(Uri.parse('http://137.184.205.67:2710//api/v1/inventory/quantities?api_token=$token'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _inventoryData = InventoryData.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load inventory data. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error:';
        _isLoading = false;
      });
      
      // For demo purposes - load sample data when API fails
      // loadSampleData();
    }
  }

  // void loadSampleData() {
  //   // Sample data for demonstration
  //   final sampleData = {
  //     "success": true,
  //     "location": {"id": 8, "name": "Stock", "complete_name": "WH/Stock"},
  //     "user": {"id": 2, "name": "Administrator"},
  //     "count": 5,
  //     "products": [
  //       {
  //         "product_id": 2,
  //         "name": "Item 1",
  //         "default_code": "",
  //         "barcode": "",
  //         "category_id": 1,
  //         "category_name": "All",
  //         "quantity": 296.0,
  //         "reserved_quantity": 0.0,
  //         "available_quantity": 296.0,
  //         "uom": "Units",
  //         "price": 1.0,
  //         "image_url": ""
  //       },
  //       {
  //         "product_id": 3,
  //         "name": "Item 2",
  //         "default_code": "",
  //         "barcode": "",
  //         "category_id": 1,
  //         "category_name": "All",
  //         "quantity": 299.0,
  //         "reserved_quantity": 0.0,
  //         "available_quantity": 299.0,
  //         "uom": "Units",
  //         "price": 1.0,
  //         "image_url": ""
  //       },
  //       {
  //         "product_id": 4,
  //         "name": "Item 3",
  //         "default_code": "",
  //         "barcode": "",
  //         "category_id": 1,
  //         "category_name": "All",
  //         "quantity": 300.0,
  //         "reserved_quantity": 0.0,
  //         "available_quantity": 300.0,
  //         "uom": "Units",
  //         "price": 1.0,
  //         "image_url": ""
  //       },
  //       {
  //         "product_id": 5,
  //         "name": "Item 4",
  //         "default_code": "",
  //         "barcode": "",
  //         "category_id": 1,
  //         "category_name": "All",
  //         "quantity": 300.0,
  //         "reserved_quantity": 0.0,
  //         "available_quantity": 300.0,
  //         "uom": "Units",
  //         "price": 1.0,
  //         "image_url": ""
  //       },
  //       {
  //         "product_id": 6,
  //         "name": "Item 5",
  //         "default_code": "",
  //         "barcode": "",
  //         "category_id": 1,
  //         "category_name": "All",
  //         "quantity": 300.0,
  //         "reserved_quantity": 0.0,
  //         "available_quantity": 300.0,
  //         "uom": "Units",
  //         "price": 1.0,
  //         "image_url": ""
  //       }
  //     ]
  //   };

  //   setState(() {
  //     _inventoryData = InventoryData.fromJson(sampleData);
  //     _isLoading = false;
  //   });
  // }

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
    // Use theme colors
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final secondaryColor = theme.colorScheme.secondary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = theme.textTheme.bodyMedium?.color ?? Colors.black54;
    
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (_errorMessage != null && _inventoryData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Error Loading Data',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: fetchInventoryData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Retry'),
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
                decoration: InputDecoration(
                  hintText: "Search inventory...",
                  hintStyle: TextStyle(color: subtitleColor.withOpacity(0.7), fontSize: 16),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: textColor, fontSize: 16),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(
                "${_inventoryData?.location.name ?? 'Inventory'}",
                style: theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Location: ${_inventoryData?.location.completeName ?? ''}",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "User: ${_inventoryData?.user.name ?? ''}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                        ),
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
                    "Items: ${_inventoryData?.count ?? 0}",
                    style: theme.textTheme.bodySmall?.copyWith(
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
                    "PRODUCT",
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "QTY",
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "AVAILABLE",
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "PRICE",
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.end,
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
                          color: subtitleColor.withOpacity(0.3)
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                              ? "No inventory items found" 
                              : "No matching items found",
                          style: theme.textTheme.titleMedium?.copyWith(
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
                            // Show product details or actions
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Selected: ${product.name}"),
                                backgroundColor: primaryColor,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (product.categoryName.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          product.categoryName,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: subtitleColor,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "${product.quantity.toStringAsFixed(0)} ${product.uom}",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "${product.availableQuantity.toStringAsFixed(0)} ${product.uom}",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "\$${product.price.toStringAsFixed(2)}",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.end,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
        onPressed: () {
          // Add new inventory item
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Add new inventory item"),
              backgroundColor: primaryColor,
            ),
          );
        },
      ),
    );
  }
}

// Add this screen to your app
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Your app theme
        primaryColor: const Color(0xFF212121),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF212121),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF212121),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF212121),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        dividerTheme: const DividerThemeData(
          thickness: 1,
          color: Color(0xFFEEEEEE),
        ),
      ),
      home: const InventoryScreen(),
    );
  }
}