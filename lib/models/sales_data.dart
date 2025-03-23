class SalesData {
  final int customerId;
  final String partnerName;
  final double totalSales;
  final String currency;
  final String currencySymbol;
  final List<Product> products;

  SalesData({
    required this.customerId,
    required this.partnerName,
    required this.totalSales,
    required this.currency,
    required this.currencySymbol,
    required this.products,
  });

  factory SalesData.fromJson(Map<String, dynamic> json, int customerId) {
    return SalesData(
      customerId: customerId,
      partnerName: json['partner']['name'],
      totalSales: json['total_sales'].toDouble(),
      currency: json['currency'],
      currencySymbol: json['currency_symbol'],
      products: List<Product>.from(
          json['products'].map((x) => Product.fromJson(x))),
    );
  }
}

class Product {
  final String name;
  final double amount;
  final double percentage;

  Product({
    required this.name,
    required this.amount,
    required this.percentage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name']['en_US'],
      amount: json['amount'].toDouble(),
      percentage: json['percentage'].toDouble(),
    );
  }
}
