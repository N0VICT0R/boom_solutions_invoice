// //=======================
// // Customer List Screen
// //=======================
// import 'package:boom_solutions_invoice/CustomerDetail/Datamodels/PartnerListModel.dart';
// import 'package:boom_solutions_invoice/CustomerDetail/Screen/CustomerDetailScreen.dart';
// import 'package:boom_solutions_invoice/CustomerDetail/controllers/CustomerListController.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class CustomersListScreen extends StatelessWidget {
//   final CustomerListController controller = Get.put(CustomerListController());

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Scaffold(
     
//       appBar: AppBar(
//         title: Text('Customers',
//           style: TextStyle(
//             // color: controller.isDarkMode.value ? Colors.white : Colors.black
//           ),
//         ),
//         // backgroundColor: controller.isDarkMode.value ? Colors.black : Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(
//               controller.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
//               // color: controller.isDarkMode.value ? Colors.white : Colors.black,
//             ),
//             onPressed: controller.toggleTheme,
//           ),
//         ],
//       ),
//       body: _buildBody(),
//     ));
//   }

//   Widget _buildBody() {
//     return Obx(() {
//       if (controller.isLoading.value) return _buildLoading();
//       if (controller.hasError.value) return _buildError();
//       if (controller.partners.isEmpty) return _buildEmptyState();
//       return _buildCustomerList();
//     });
//   }

//   Widget _buildLoading() {
//     return Center(
//       child: CircularProgressIndicator(
//         // color: controller.isDarkMode.value ? Colors.white : Colors.black,
//       ),
//     );
//   }

//   Widget _buildError() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Failed to load customers',
//             style: TextStyle(
//               // color: controller.isDarkMode.value ? Colors.white : Colors.black,
//             ),
//           ),
//           ElevatedButton(
//             onPressed: controller.fetchCustomers,
//             child: Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.people_alt_outlined, size: 64,
//            ),
//           SizedBox(height: 16),
//           Text(
//             'No customers found',
//             style: TextStyle(
//               fontSize: 18,
//               // color: controller.isDarkMode.value ? Colors.white : Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCustomerList() {
//     return ListView.builder(
//       padding: EdgeInsets.all(16),
//       itemCount: controller.partners.length,
//       itemBuilder: (context, index) {
//         final partner = controller.partners[index];
//         return _buildCustomerCard(partner);
//       },
//     );
//   }

//   Widget _buildCustomerCard(PartnerList partner) {
//     return Card(
//       // color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.all(16),
//         title: Text(partner.name,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
           
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 8),
//             if (partner.address?.isNotEmpty ?? false)
//               _buildInfoRow(Icons.location_on, partner.address!),
//             if (partner.city?.isNotEmpty ?? false)
//               _buildInfoRow(Icons.location_city, partner.city!),
//             if (partner.state?.isNotEmpty ?? false)
//               _buildInfoRow(Icons.map, partner.state!),
//             if (partner.country?.isNotEmpty ?? false)
//               _buildInfoRow(Icons.public, partner.country!),
//             if (partner.phone != null && partner.phone != false)
//               _buildInfoRow(Icons.phone, partner.phone.toString()),
//             if (partner.mobile != null && partner.mobile != false)
//               _buildInfoRow(Icons.phone_iphone, partner.mobile.toString()),
//           ],
//         ),
//         trailing: Icon(Icons.chevron_right,
//           // color: controller.isDarkMode.value ? Colors.white54 : Colors.black54,
//         ),
//         onTap: () {
//           Get.to(() => CustomerDetailScreen(), 
//             arguments: {'partnerId': partner.id}
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Visibility(
//       visible: text.isNotEmpty,
//       child: Row(
//         children: [
//           Icon(icon, 
//             size: 16, 
//             // color: controller.isDarkMode.value ? Colors.white54 : Colors.black54
//           ),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(text,
//               style: TextStyle(
//                 // color: controller.isDarkMode.value ? Colors.white54 : Colors.black54
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//=======================
// Screens
//=======================
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:boom_solutions_invoice/screens/customer_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';



class PartnerList {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final dynamic phone;
  final dynamic mobile;

  PartnerList({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.state,
    this.country,
    this.phone,
    this.mobile,
  });

  factory PartnerList.fromJson(Map<String, dynamic> json) {
    return PartnerList(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      address: _parseString(json['address']),
      city: _parseString(json['city']),
      state: _parseString(json['state']),
      country: _parseString(json['country']),
      phone: json['phone'],
      mobile: json['mobile'],
    );
  }

  static String? _parseString(dynamic value) {
    if (value is String) return value;
    if (value == false) return null;
    return value?.toString();
  }
}

class CustomersListScreen extends StatefulWidget {
  @override
  _CustomersListScreenState createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen>
    with WidgetsBindingObserver {
  final CustomerListController controller = Get.put(CustomerListController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.fetchCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text('Customers'),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                  controller.isDarkMode.value ? Icons.add_outlined : Icons.add),
              onPressed: () {
                Get.toNamed("addcustomer");
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchAndSort(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndSort() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: controller.searchCustomers,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.sort_by_alpha),
            onPressed: controller.sortCustomers,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) return _buildLoading();
      if (controller.hasError.value) return _buildError();
      if (controller.filteredPartners.isEmpty) return _buildEmptyState();
      return RefreshIndicator(
        onRefresh: controller.fetchCustomers,
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.filteredPartners.length,
          itemBuilder: (context, index) {
            final partner = controller.filteredPartners[index];
            return _buildCustomerCard(partner);
          },
        ),
      );
    });
  }

  Widget _buildLoading() => Center(child: CircularProgressIndicator());

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('please load customers',
          style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 15,),
          ElevatedButton(
            onPressed: controller.fetchCustomers,
            child: Text('Load'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined, size: 64),
          SizedBox(height: 16),
          Text('No customers found', style: TextStyle(fontSize: 18)),
          ElevatedButton(
            onPressed: controller.fetchCustomers,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(PartnerList partner) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          partner.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            if (partner.address?.isNotEmpty ?? false)
              _buildInfoRow(Icons.location_on, partner.address!),
            if (partner.phone != null)
              _buildInfoRow(Icons.phone, partner.phone.toString()),
            if (partner.mobile != null)
            if (partner.country?.isNotEmpty ?? false)
              _buildInfoRow(Icons.public, partner.country!),
            if (partner.phone != null)
              _buildInfoRow(Icons.phone, partner.phone.toString()),
            if (partner.mobile != null)
              _buildInfoRow(Icons.phone_iphone, partner.mobile.toString()),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () => Get.to(() => CustomerDetailScreen(partnerId: partner.id),
            arguments: {'partnerId': partner.id}),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Visibility(
      visible: text.isNotEmpty,
      child: Row(
        children: [
          Icon(icon, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
//=======================
// Controllers
//=======================
class CustomerListController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  final partners = <PartnerList>[].obs;
  final filteredPartners = <PartnerList>[].obs;
  final isDarkMode = true.obs;

  void toggleTheme() => isDarkMode.value = !isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading(true);
      hasError(false);
            final apiurl = GetStorage().read("apiUrl");
      final token = GetStorage().read('token') ?? '';
      final url =
          '$apiurl/api/v1/partners?api_token=$token&limit=10&page=1&state_id=';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['partners'] is List) {
          partners.assignAll(
            (data['partners'] as List)
                .map((e) => PartnerList.fromJson(e))
                .toList(),
          );
          filteredPartners.assignAll(partners);
        }
      } else {
        hasError(true);
      }
    } catch (e) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  void searchCustomers(String query) {
    if (query.isEmpty) {
      filteredPartners.assignAll(partners);
    } else {
      filteredPartners.assignAll(
        partners
            .where((partner) =>
                partner.name.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  void sortCustomers() {
    filteredPartners.sort((a, b) => a.name.compareTo(b.name));
  }
}