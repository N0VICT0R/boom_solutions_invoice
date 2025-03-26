import 'package:boom_solutions_invoice/CustomerDetail/Datamodels/partnerModel.dart';
import 'package:boom_solutions_invoice/CustomerDetail/Datamodels/productDataModel.dart';

class SalesData {
  final Partner partner;
  final double totalSales;
  final String currency;
  final String currencySymbol;
  final List<Product> products;

  SalesData({
    required this.partner,
    required this.totalSales,
    required this.currency,
    required this.currencySymbol,
    required this.products,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      partner: Partner.fromJson(json['partner']),
      totalSales: json['total_sales']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'EGP',
      currencySymbol: json['currency_symbol'] ?? 'LE',
      products: (json['products'] as List?)
              ?.map((e) => Product.fromJson(e))
              .toList() ??
          [],
    );
  }
}
