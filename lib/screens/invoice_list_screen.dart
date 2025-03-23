import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/invoice_controller.dart';

class InvoiceListScreen extends StatelessWidget {
  final InvoiceController invoiceController = Get.find<InvoiceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الفواتير'),
      ),
      body: Obx(
            () => ListView.builder(
          itemCount: invoiceController.invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoiceController.invoices[index];
            return ListTile(
              leading: Icon(Icons.receipt),
              title: Text('فاتورة رقم ${invoice.id}'),
              subtitle: Text(invoice.customer.name),
              trailing:
              Text('\$${invoice.total.toStringAsFixed(2)}'),
              onTap: () {
                Get.toNamed('/invoiceDetail', arguments: invoice);
              },
            );
          },
        ),
      ),
    );
  }
}
