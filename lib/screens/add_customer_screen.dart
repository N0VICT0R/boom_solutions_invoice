// // lib/screens/create_customer_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../models/customer.dart';
// import '../controllers/customer_controller.dart';

// class CreateCustomerScreen extends StatelessWidget {
//   final CustomerController customerController = Get.find<CustomerController>();
//   final TextEditingController nameController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('إضافة عميل جديد'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(
//                 labelText: 'اسم العميل',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 if (nameController.text.isEmpty) {
//                   Get.snackbar('خطأ', 'الرجاء إدخال اسم العميل');
//                   return;
//                 }
//                 // Create a new customer
//                 final newCustomer = Customer(
//                   id: customerController.customers.length + 1,
//                   name: nameController.text, email: 'ةخشئ',
//                 );
//                 // Add the new customer to the list
//                 customerController.addCustomer(newCustomer);
//                 // Return to the previous screen with the new customer
//                 Get.back(result: newCustomer);
//               },
//               child: Text('حفظ العميل'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }