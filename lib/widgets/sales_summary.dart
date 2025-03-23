// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/customer_controller.dart';
// import '../controllers/customer_details_controller.dart';

// class SalesSummary extends StatelessWidget {
//   final CustomerController controller = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Total Sales',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: controller.isDarkMode.value ? Colors.white60 : Colors.black54,
//                 )),
//             Obx(() => Text(
//               '${controller.salesData.value?.currencySymbol ?? ''} '
//                   '${controller.salesData.value?.totalSales.toStringAsFixed(2) ?? '0.00'}',
//               style: TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: controller.isDarkMode.value ? Colors.white : Colors.black,
//               ),
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_controller.dart';

class SalesSummary extends GetView<CustomerController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final salesData = controller.salesData.value;
      if (salesData == null) return Container();

      return _buildCard(
        height: MediaQuery.of(context).size.height * 0.15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Sales',
              style: TextStyle(
                fontSize: 16,
                color: controller.isDarkMode.value
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${salesData.currencySymbol} ${salesData.totalSales.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: controller.isDarkMode.value ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCard({required double height, required Widget child}) {
    return Container(
      width: double.infinity,
      height: height,
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}