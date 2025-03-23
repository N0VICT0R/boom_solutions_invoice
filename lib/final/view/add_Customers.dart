import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerController extends GetxController {
  var name = ''.obs;
  var address = ''.obs;
  var city = ''.obs;
  var state = ''.obs;
  var country = ''.obs;
  var phone = ''.obs;
  var mobile = ''.obs;
  var paymentTerms = ''.obs;

  // Suggestions for auto-complete (for example, cities)
  final List<String> citySuggestions = [
    'Cairo',
    'Alexandria',
    'Giza',
    'Shubra',
    'Mansoura'
  ];
  var filteredCitySuggestions = <String>[].obs;

  // Filter suggestions based on user input
  void filterCitySuggestions(String input) {
    if (input.isEmpty) {
      filteredCitySuggestions.clear();
    } else {
      filteredCitySuggestions.value = citySuggestions
          .where((s) => s.toLowerCase().contains(input.toLowerCase()))
          .toList();
    }
  }

  // Simulated API call for adding a customer
  Future<void> addCustomer() async {
    // Simulate a delay from an API call
    await Future.delayed(Duration(seconds: 1));
    // For demo: if name is not empty, assume success; otherwise, error.
    if (name.value.trim().isNotEmpty) {
      Get.snackbar(
        'Success',
        'Customer added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Customer add failed: Name is required.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class CustomerAddPage extends StatelessWidget {
  final CustomerController controller = Get.put(CustomerController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CustomerAddPage({Key? key}) : super(key: key);

  // Helper to create a TextFormField with rounded borders and validation.
  // Removed Obx wrapper here since we only need to capture onChanged.
  Widget _buildTextFormField({
    required String label,
    required RxString fieldValue,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      initialValue: fieldValue.value,
      onChanged: (value) {
        fieldValue.value = value;
        if (onChanged != null) {
          onChanged(value);
        }
      },
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Customer'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextFormField(
                  label: 'Name',
                  fieldValue: controller.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Name is required';
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  label: 'Address',
                  fieldValue: controller.address,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Address is required';
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                // City with auto-complete suggestions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: controller.city.value,
                      onChanged: (value) {
                        controller.city.value = value;
                        controller.filterCitySuggestions(value);
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'City is required';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'City',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                    ),
                    Obx(() {
                      return controller.filteredCitySuggestions.isNotEmpty
                          ? Container(
                              constraints: BoxConstraints(maxHeight: 150),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                    controller.filteredCitySuggestions.length,
                                itemBuilder: (context, index) {
                                  final suggestion =
                                      controller.filteredCitySuggestions[index];
                                  return ListTile(
                                    title: Text(suggestion),
                                    onTap: () {
                                      controller.city.value = suggestion;
                                      controller.filteredCitySuggestions.clear();
                                      // Dismiss the keyboard
                                      FocusScope.of(context).unfocus();
                                    },
                                  );
                                },
                              ),
                            )
                          : SizedBox.shrink();
                    }),
                  ],
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  label: 'State',
                  fieldValue: controller.state,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'State is required';
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  label: 'Country',
                  fieldValue: controller.country,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Country is required';
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  label: 'Phone',
                  fieldValue: controller.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Phone is required';
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  label: 'Mobile',
                  fieldValue: controller.mobile,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Mobile is required';
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _buildTextFormField(
                  label: 'Payment Terms',
                  fieldValue: controller.paymentTerms,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Payment Terms is required';
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await controller.addCustomer();
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please fill all required fields',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text('Save'),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Reset form and controller fields
                          _formKey.currentState?.reset();
                          controller.name.value = '';
                          controller.address.value = '';
                          controller.city.value = '';
                          controller.state.value = '';
                          controller.country.value = '';
                          controller.phone.value = '';
                          controller.mobile.value = '';
                          controller.paymentTerms.value = '';
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
