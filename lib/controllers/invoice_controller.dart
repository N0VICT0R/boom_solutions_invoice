// lib/controllers/invoice_controller.dart
import 'package:get/get.dart';
import '../models/invoice.dart';
import '../models/customer.dart';
import '../models/product.dart';

class InvoiceController extends GetxController {
  // قائمة الفواتير
 late var invoices = <Invoice>[].obs;

  // العميل المختار
  var selectedCustomer = Rxn<Customer>();

  // خريطة المنتجات المختارة مع الكمية (Product -> quantity)
  // استخدام RxMap لتحديث الواجهة تلقائياً
  var selectedProducts = <Product, int>{}.obs;

  // زيادة كمية المنتج
  void increaseProductQuantity(Product product) {
    if (selectedProducts.containsKey(product)) {
      selectedProducts[product] = selectedProducts[product]! + 1;
    } else {
      selectedProducts[product] = 1;
    }
  }

  // إنقاص كمية المنتج
  void decreaseProductQuantity(Product product) {
    if (selectedProducts.containsKey(product) && selectedProducts[product]! > 1) {
      selectedProducts[product] = selectedProducts[product]! - 1;
    } else {
      // إذا كانت الكمية 1 أو غير موجودة، نقوم بحذف المنتج من الخريطة
      selectedProducts.remove(product);
    }
  }

  // إنشاء الفاتورة النهائية
  void createInvoice() {
    if (selectedCustomer.value == null || selectedProducts.isEmpty) return;

    // حساب الإجمالي بناءً على الكميات
    double total = selectedProducts.entries
        .map((entry) => entry.key.price * entry.value)
        .fold(0, (sum, price) => sum + price);

    // إنشاء الفاتورة (يتم تكرار المنتج بحسب الكمية)
    Invoice invoice = Invoice(
      id: DateTime.now().millisecondsSinceEpoch,
      customer: selectedCustomer.value!,
      products: selectedProducts.entries
          .expand((entry) => List.filled(entry.value, entry.key))
          .toList(),
      total: total,
    );

    invoices.add(invoice);
    // إعادة تعيين القيم بعد الإنشاء
    selectedCustomer.value = null;
    selectedProducts.clear();
  }
}
