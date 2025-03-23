// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/customer_controller.dart';
// import '../controllers/customer_details_controller.dart';
//
// class CustomerDropdown extends StatelessWidget {
//   final CustomerController controller = Get.find();
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => DropdownButton<int>(
//       value: controller.selectedCustomerId.value,
//       items: controller.customerIds.map((int value) {
//         return DropdownMenuItem<int>(
//           value: value,
//           child: Text('Customer $value'),
//         );
//       }).toList(),
//       onChanged: (int? newValue) {
//         if (newValue != null) {
//           controller.updateCustomerId(newValue);
//         }
//       },
//       style: TextStyle(
//         color: controller.isDarkMode.value ? Colors.white : Colors.black,
//       ),
//       dropdownColor: controller.isDarkMode.value ? Colors.grey[800] : Colors.white,
//     ));
//   }
// }