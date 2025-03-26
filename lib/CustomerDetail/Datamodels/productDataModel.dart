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
      name: json['name']?['en_US'] ?? 'Unnamed Product',
      amount: json['amount']?.toDouble() ?? 0.0,
      percentage: json['percentage']?.toDouble() ?? 0.0,
    );
  }
}