// import 'package:boom_solutions_invoice/final/view/add_Customers.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../models/customer.dart';
// import '../models/product.dart';
// import '../controllers/invoice_controller.dart';
// import '../controllers/customer_controller.dart';
// import 'add_customer_screen.dart';

// class CreateInvoiceScreen extends StatelessWidget {
//   final InvoiceController invoiceController = Get.put(InvoiceController());
//   final CustomerAddPage customerController = Get.find<CustomerController>() as CustomerAddPage;

//   final List<Product> products = [
//     Product(
//         id: 1,
//         name: 'منتج 1',
//         price: 10.0,
//         imageUrl: 'assets/product1.png',
//         description: 'وصف المنتج 1'),
//     Product(
//         id: 2,
//         name: 'منتج 2',
//         price: 15.0,
//         imageUrl: 'assets/product2.png',
//         description: 'وصف المنتج 2'),
//     Product(
//         id: 3,
//         name: 'منتج 3',
//         price: 20.0,
//         imageUrl: 'assets/product3.png',
//         description: 'وصف المنتج 3'),
//     Product(
//         id: 4,
//         name: 'منتج 6',
//         price: 25.0,
//         imageUrl: 'assets/product4.png',
//         description: 'وصف المنتج 6'),
//     Product(
//         id: 5,
//         name: 'منتج 7',
//         price: 25.0,
//         imageUrl: 'assets/product5.png',
//         description: 'وصف المنتج 7'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('إنشاء فاتورة'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('اختر العميل',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Obx(
//               () => DropdownButtonFormField<Customer>(
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                 ),
//                 value: invoiceController.selectedCustomer.value,
//                 items: customerController.customers.map((customer) {
//                   return DropdownMenuItem<Customer>(
//                     value: customer,
//                     child: Text(customer.name),
//                   );
//                 }).toList(),
//                 onChanged: (Customer? newValue) {
//                   if (newValue != null) {
//                     invoiceController.selectedCustomer.value = newValue;
//                   }
//                 },
//                 hint: Text('اختر العميل'),
//               ),
//             ),
//             SizedBox(height: 16),
//             Text('اختر المنتجات',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Expanded(
//               child: ListView.builder(

//                 itemCount: products.length,
//                 itemBuilder: (context, index) {
//                   final product = products[index];
//                   return Obx(() {
//                     int quantity =
//                         invoiceController.selectedProducts[product] ?? 0;
//                     return GestureDetector(
//                       onTap: () {},
//                       child: Card(
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.only(
//                                 bottomRight: Radius.circular(25),
//                                 topRight: Radius.circular(25),
//                                 topLeft: Radius.circular(25),
//                                 bottomLeft: Radius.circular(25),

//                             ),

//                             side: BorderSide(width: .25, color: Colors.grey)),
//                         color: Colors.black,
//                         elevation: 4,
//                         child: Row(
//                           children: [

//                             Expanded(
//                               flex: 3,
//                               child: Padding(
//                                 padding: EdgeInsets.all(12),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     CircleAvatar(

//                                         radius: 55,
//                                       backgroundImage:
//                                       NetworkImage("https://scontent.fcai21-2.fna.fbcdn.net/v/t39.30808-1/304810921_387441886891490_5611026610704900750_n.png?stp=dst-png_s200x200&_nc_cat=106&ccb=1-7&_nc_sid=2d3e12&_nc_eui2=AeFgpMKZumnH0SogSa0GWXEXslIFt3ZZHMiyUgW3dlkcyPFohHJyss-538PbF2n6R2I76iiREF_eDUQ6QadsZKX2&_nc_ohc=XYo2_GT7d0MQ7kNvgHrjdni&_nc_oc=Adixuq9SVBo88t7s6HM9u1PRQ5Cx7-Pxq753v2M7cCMMBQG6E0zAuX6GUx8ubbzIXGI&_nc_zt=24&_nc_ht=scontent.fcai21-2.fna&_nc_gid=Ayo6ND-xAEs4zRdUtsXHErf&oh=00_AYCyC_omX7eTUcB6vQ6duOpQH9usflJfeEQkyTWpavEuHg&oe=67B1A91A"),
//                                       backgroundColor: Colors.transparent,


//                                     ),
//                                     SizedBox(height: 8),
//                                     Column(
//                                       children: [
//                                         Text(product.name,
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 20)),
//                                         SizedBox(height: 4),
//                                         Text(product.description,
//                                             style: TextStyle(
//                                                 fontSize: 16, color: Colors.grey)),

//                                       ],
//                                     ),
//                                     SizedBox(height: 8),

//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: () {
//                                   invoiceController
//                                       .decreaseProductQuantity(product);
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       end:  Alignment.centerRight,
//                                       begin: Alignment.centerLeft,
//                                       colors: [Colors.red,Colors.redAccent,],
//                                     ),
//                                     borderRadius: BorderRadius.only(topLeft: Radius.circular(25),bottomLeft:Radius.circular(25),),
//                                   ),
//                                   padding: EdgeInsets.all(50),

//                                   child: Center(
//                                     child: Text('-',
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 24,
//                                             fontWeight: FontWeight.bold)),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Center(
//                                 child: Text("$quantity",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                         fontSize: 30,
//                                         fontWeight: FontWeight.bold))),
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: () {
//                                   invoiceController
//                                       .increaseProductQuantity(product);
//                                 },
//                                 child: Container(

//                                   decoration: BoxDecoration(

//                                     gradient: LinearGradient(
//                                       end:  Alignment.centerLeft,
//                                       begin: Alignment.centerRight,
//                                       colors: [Colors.green,Colors.green ,],
//                                     ),
//                                     borderRadius: BorderRadius.only(topRight: Radius.circular(25),bottomRight:Radius.circular(25),),
//                                   ),

//                                   padding: EdgeInsets.all(50),

//                                   child: Center(
//                                     child: Text('+',
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 24,
//                                             fontWeight: FontWeight.bold)),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   });
//                 },
//               ),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 if (invoiceController.selectedCustomer.value == null) {
//                   Get.snackbar('خطأ', 'الرجاء اختيار العميل');
//                   return;
//                 }
//                 if (invoiceController.selectedProducts.isEmpty) {
//                   Get.snackbar('خطأ', 'الرجاء اختيار منتج واحد على الأقل');
//                   return;
//                 }
//                 invoiceController.createInvoice();
//                 final newInvoice = invoiceController.invoices.last;
//                 Get.toNamed('/invoiceDetail', arguments: newInvoice);
//               },
//               child: Text('متابعة التفاصيل'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: Size(double.infinity, 50),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
