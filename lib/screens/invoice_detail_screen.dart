import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/invoice.dart';

class InvoiceDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // استقبال الفاتورة من الـ arguments
    final Invoice invoice = Get.arguments as Invoice;
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الفاتورة'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('العميل: ${invoice.customer.name}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('المنتجات:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: invoice.products.length,
                itemBuilder: (context, index) {
                  final product = invoice.products[index];
                  return ListTile(
                    title: Text(product.name),
                    trailing:
                    Text('\$${product.price.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'الإجمالي',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                '\$${invoice.total.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.snackbar('نجاح', 'تم إنشاء الفاتورة بنجاح');
                // الرجوع إلى صفحة لوحة التحكم
                Get.offAllNamed('/');
              },
              child: Text('إنشاء الفاتورة'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
