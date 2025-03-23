// lib/models/invoice.dart
import 'customer.dart';
import 'product.dart';

class Invoice {
  final int id;
  final Customer customer;
  final List<Product> products;
  final double total;

  Invoice({
    required this.id,
    required this.customer,
    required this.products,
    required this.total,
  });
}
