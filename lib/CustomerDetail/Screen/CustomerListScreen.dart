//=======================
// Customer List Screen
//=======================
import 'package:boom_solutions_invoice/CustomerDetail/Datamodels/PartnerListModel.dart';
import 'package:boom_solutions_invoice/CustomerDetail/Screen/CustomerDetailScreen.dart';
import 'package:boom_solutions_invoice/CustomerDetail/controllers/CustomerListController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomersListScreen extends StatelessWidget {
  final CustomerListController controller = Get.put(CustomerListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
     
      appBar: AppBar(
        title: Text('Customers',
          style: TextStyle(
            // color: controller.isDarkMode.value ? Colors.white : Colors.black
          ),
        ),
        // backgroundColor: controller.isDarkMode.value ? Colors.black : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              controller.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
              // color: controller.isDarkMode.value ? Colors.white : Colors.black,
            ),
            onPressed: controller.toggleTheme,
          ),
        ],
      ),
      body: _buildBody(),
    ));
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) return _buildLoading();
      if (controller.hasError.value) return _buildError();
      if (controller.partners.isEmpty) return _buildEmptyState();
      return _buildCustomerList();
    });
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        // color: controller.isDarkMode.value ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Failed to load customers',
            style: TextStyle(
              // color: controller.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          ElevatedButton(
            onPressed: controller.fetchCustomers,
            child: Text('Retry'),
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
          Icon(Icons.people_alt_outlined, size: 64,
           ),
          SizedBox(height: 16),
          Text(
            'No customers found',
            style: TextStyle(
              fontSize: 18,
              // color: controller.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: controller.partners.length,
      itemBuilder: (context, index) {
        final partner = controller.partners[index];
        return _buildCustomerCard(partner);
      },
    );
  }

  Widget _buildCustomerCard(PartnerList partner) {
    return Card(
      // color: controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(partner.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
           
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            if (partner.address?.isNotEmpty ?? false)
              _buildInfoRow(Icons.location_on, partner.address!),
            if (partner.city?.isNotEmpty ?? false)
              _buildInfoRow(Icons.location_city, partner.city!),
            if (partner.state?.isNotEmpty ?? false)
              _buildInfoRow(Icons.map, partner.state!),
            if (partner.country?.isNotEmpty ?? false)
              _buildInfoRow(Icons.public, partner.country!),
            if (partner.phone != null && partner.phone != false)
              _buildInfoRow(Icons.phone, partner.phone.toString()),
            if (partner.mobile != null && partner.mobile != false)
              _buildInfoRow(Icons.phone_iphone, partner.mobile.toString()),
          ],
        ),
        trailing: Icon(Icons.chevron_right,
          // color: controller.isDarkMode.value ? Colors.white54 : Colors.black54,
        ),
        onTap: () {
          Get.to(() => CustomerDetailScreen(), 
            arguments: {'partnerId': partner.id}
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Visibility(
      visible: text.isNotEmpty,
      child: Row(
        children: [
          Icon(icon, 
            size: 16, 
            // color: controller.isDarkMode.value ? Colors.white54 : Colors.black54
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(text,
              style: TextStyle(
                // color: controller.isDarkMode.value ? Colors.white54 : Colors.black54
              ),
            ),
          ),
        ],
      ),
    );
  }
}