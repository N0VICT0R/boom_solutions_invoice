import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPostController extends GetxController {
  final isLoading = false.obs;
  final isSuccess = false.obs;
  final errorMessage = ''.obs;

  Future<void> postPayment({
    required double amount,
    required int paymentMethodId,
    String memo = '',
  }) async {
    try {
      isLoading(true);
      isSuccess(false);
      errorMessage('');

      final response = await http.post(
        Uri.parse('http://137.184.205.67:2710//api/v1/partners/10/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'api_token': 'VKwmwcRzwAIY9ef6A7Gp2qBOISwwPCke',
          'amount': amount,
          'payment_method_id': paymentMethodId,
          'memo': memo,
          'post_immediately': true,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        isSuccess(true);
        Get.snackbar(
          'Success', 
          'Payment posted successfully',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        errorMessage(json.decode(response.body)['message'] ?? 'Payment failed');
        Get.snackbar(
          'Error', 
          errorMessage.value,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage('An error occurred: $e');
      Get.snackbar(
        'Error', 
        errorMessage.value,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }
}

class PaymentPostScreen extends StatelessWidget {
  final PaymentPostController controller = Get.put(PaymentPostController());
  final TextEditingController amountController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final RxInt selectedPaymentMethod = 2.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
       
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Post Payment',
          style: TextStyle(
            
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAmountField(),
              SizedBox(height: 16),
              _buildMemoField(),
              SizedBox(height: 16),
              _buildPaymentMethodDropdown(),
              Spacer(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: amountController,
      decoration: InputDecoration(
        labelText: 'Amount',
        labelStyle: TextStyle(),
        prefixText: 'EGP ',
        prefixStyle: TextStyle(
          
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide( width: 1.5),
        ),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
      
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildMemoField() {
    return TextField(
      controller: memoController,
      decoration: InputDecoration(
        labelText: 'Memo',
        labelStyle: TextStyle(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide( width: 1.5),
        ),
      ),
      style: TextStyle(
       
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedPaymentMethod.value,
          isExpanded: true,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          style: TextStyle(
           
            fontWeight: FontWeight.w500,
          ),
          // dropdownColor: Colors.white,
          icon: Icon(Icons.arrow_drop_down,),
          items: [
            DropdownMenuItem(
              child: Text('Cash', style: TextStyle(color: Colors.grey.shade600)),
              value: 1,
            ),
      
            DropdownMenuItem(
              child: Text('Credit Card', style: TextStyle(color: Colors.grey.shade600)),
              value: 2,
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              selectedPaymentMethod.value = value;
            }
          },
        ),
      ),
    ));
  }

  Widget _buildSubmitButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value 
          ? null 
          : () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                controller.postPayment(
                  amount: amount,
                  paymentMethodId: selectedPaymentMethod.value,
                  memo: memoController.text,
                );
              } else {
                Get.snackbar(
                  'Error', 
                  'Please enter a valid amount',
                  backgroundColor: Colors.red.shade600,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
      child: controller.isLoading.value
          ? CircularProgressIndicator()
          : Text(
              'Post Payment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                
              ),
              overflow: TextOverflow.ellipsis,
            ),
      style: ElevatedButton.styleFrom(
        // backgroundColor: Colors.black,
        // foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        // disabledBackgroundColor: Colors.grey.shade400,
      ),
    ));
  }
}