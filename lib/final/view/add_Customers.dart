import 'package:animate_do/animate_do.dart';
import 'package:boom_solutions_invoice/services/location_tracker.dart' show LocationTrackerController;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:boom_solutions_invoice/generated/l10n.dart';

class CustomerController extends GetxController {
  var name = ''.obs;
  var address = ''.obs;
  var city = ''.obs;
  var state = ''.obs;
  var country = ''.obs;
  var phone = ''.obs;
  var mobile = ''.obs;
  var paymentTerms = 0.obs;
  var isLoading = false.obs;

  final List<String> citySuggestions = [
    'Cairo',
    'Alexandria',
    'Giza',
    'Shubra',
    'Mansoura'
  ];
  var filteredCitySuggestions = <String>[].obs;

  void filterCitySuggestions(String input) {
    if (input.isEmpty) {
      filteredCitySuggestions.clear();
    } else {
      filteredCitySuggestions.value = citySuggestions
          .where((s) => s.toLowerCase().contains(input.toLowerCase()))
          .toList();
    }
  }

  Future<void> addCustomer() async {
    isLoading.value = true;
    final storage = GetStorage();
    final apiToken = storage.read('token');
    final apiUrl = storage.read('apiUrl') ?? 'https://onix.boom-solutions.co/api/v1/customers';

    if (apiToken == null) {
      Get.snackbar(
        S.current.error,
        S.current.no_token,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error: No API token found in GetStorage');
      isLoading.value = false;
      return;
    }

    print('API Token: $apiToken');
    print('API URL: $apiUrl');
    print('Request Body: {'
        'name: ${name.value}, '
        'address: ${address.value}, '
        'city: ${city.value}, '
        'state: ${int.tryParse(state.value) ?? 43}, '
        'country: ${int.tryParse(country.value) ?? 233}, '
        'phone: ${phone.value}, '
        'mobile: ${mobile.value}, '
        'payment_terms: ${int.tryParse(paymentTerms.value.toString()) ?? 1}, '
        'created_at: ${DateTime.now().toUtc().toIso8601String()}'
        '}');

    final body = {
      'name': name.value,
      'address': address.value,
      'city': city.value,
      'state': int.tryParse(state.value) ?? 43,
      'country': int.tryParse(country.value) ?? 233,
      'phone': phone.value,
      'mobile': mobile.value,
      'payment_terms': int.tryParse(paymentTerms.value.toString()) ?? 1,
      'created_at': DateTime.now().toUtc().toIso8601String(), // Add UTC timestamp
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiToken', // Move api_token to headers
        },
        body: jsonEncode(body),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true || data['status'] == 'success') {
          Get.snackbar(
            S.current.success,
            S.current.customer_added,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          name.value = '';
          address.value = '';
          city.value = '';
          state.value = '';
          country.value = '';
          phone.value = '';
          mobile.value = '';
          paymentTerms.value = 0;
        } else {
          Get.snackbar(
            S.current.error,
            S.current.api_error(data['message'] ?? 'Unknown error'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          S.current.error,
          S.current.api_error('Status ${response.statusCode}'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Exception: $e');
      Get.snackbar(
        S.current.error,
        S.current.connection_error(e.toString()),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}


double getResponsiveFontSize(BuildContext context, double baseFontSize) {
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth / 400;
  return (baseFontSize * scaleFactor).clamp(baseFontSize * 0.8, baseFontSize * 1.2);
}

class CustomerAddPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CustomerController controller = Get.put(CustomerController());
  final LocationTrackerController locationController = Get.find<LocationTrackerController>();

  CustomerAddPage({super.key});

  Widget _buildTextFormField({
    required BuildContext context,
    required String labelKey,
    required RxString fieldValue,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    bool isNumeric = false,
  }) {
    String translatedLabel = _translateLabel(context, labelKey);
    return Obx(() => TextFormField(
          initialValue: fieldValue.value,
          onChanged: (value) {
            fieldValue.value = value;
            if (onChanged != null) {
              onChanged(value);
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return S.of(context).field_required; // Replace with the correct property or method from S
            }
            if (isNumeric && int.tryParse(value) == null) {
              return S.of(context).invalid_number.toString(); // Convert to String explicitly
            }
            return validator?.call(value);
          },
          keyboardType: isNumeric ? TextInputType.number : keyboardType,
          decoration: InputDecoration(
            labelText: translatedLabel,
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xFFB0B0B0)
                  : Color(0xFF757575),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF4FC3F7)
                    : Color(0xFF1976D2),
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Color(0xFF1A1A1A)
                : Colors.white,
          ),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Color(0xFF212121),
          ),
        ));
  }

  String _translateLabel(BuildContext context, String labelKey) {
    switch (labelKey) {
      case 'name':
        return S.of(context).name;
      case 'address':
        return S.of(context).address;
      case 'city':
        return S.of(context).city;
      case 'state':
        return S.of(context).state;
      case 'country':
        return S.of(context).country;
      case 'phone':
        return S.of(context).phone;
      case 'mobile':
        return S.of(context).mobile;
      case 'payment_terms':
        return S.of(context).payment_terms;
      default:
        return labelKey;
    }
  }

  Widget _buildLocationStatusCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? Color(0xFF1A1A1A) : Colors.white;
    final cardBorder = isDark ? Color(0xFF2A2A2A) : Color(0xFFE0E0E0);
    final primaryTextColor = isDark ? Colors.white : Color(0xFF212121);

    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: isDark ? Color(0xFF4FC3F7) : Color(0xFF1976D2),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: Obx(() => Text(
                    '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                      fontSize: getResponsiveFontSize(context, 14),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Color(0xFF121212) : Color(0xFFFAFAFA);
    final cardBackground = isDark ? Color(0xFF1A1A1A) : Colors.white;
    final cardBorder = isDark ? Color(0xFF2A2A2A) : Color(0xFFE0E0E0);
    final primaryTextColor = isDark ? Colors.white : Color(0xFF212121);
    final secondaryTextColor = isDark ? Color(0xFFB0B0B0) : Color(0xFF757575);
    final accentColor = isDark ? Color(0xFF4FC3F7) : Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          S.of(context).add_customer,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: getResponsiveFontSize(context, 20),
            color: primaryTextColor,
          ),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              Get.updateLocale(Get.locale?.languageCode == 'ar'
                  ? Locale('en', 'US')
                  : Locale('ar', 'EG'));
            },
          ),
        ],
      ),
      body: FadeInUp(
        duration: Duration(milliseconds: 500),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationStatusCard(context),
                Container(
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextFormField(
                            context: context,
                            labelKey: 'name',
                            fieldValue: controller.name,
                            validator: null,
                          ),
                          SizedBox(height: 16.0),
                          _buildTextFormField(
                            context: context,
                            labelKey: 'address',
                            fieldValue: controller.address,
                            validator: null,
                          ),
                          SizedBox(height: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextFormField(
                                context: context,
                                labelKey: 'city',
                                fieldValue: controller.city,
                                onChanged: (value) =>
                                    controller.filterCitySuggestions(value),
                                validator: null,
                              ),
                              Obx(() => controller.filteredCitySuggestions.isNotEmpty
                                  ? Container(
                                      constraints: BoxConstraints(maxHeight: 150),
                                      decoration: BoxDecoration(
                                        color: cardBackground,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: cardBorder),
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount:
                                            controller.filteredCitySuggestions.length,
                                        itemBuilder: (context, index) {
                                          final suggestion =
                                              controller.filteredCitySuggestions[index];
                                          return ListTile(
                                            title: Text(
                                              suggestion,
                                              style: GoogleFonts.poppins(
                                                color: primaryTextColor,
                                              ),
                                            ),
                                            onTap: () {
                                              controller.city.value = suggestion;
                                              controller.filteredCitySuggestions
                                                  .clear();
                                              FocusScope.of(context).unfocus();
                                            },
                                          );
                                        },
                                      ),
                                    )
                                  : SizedBox.shrink()),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          _buildTextFormField(
                            context: context,
                            labelKey: 'state',
                            fieldValue: controller.state,
                            isNumeric: true,
                            validator: null,
                          ),
                          SizedBox(height: 16.0),
                          _buildTextFormField(
                            context: context,
                            labelKey: 'country',
                            fieldValue: controller.country,
                            isNumeric: true,
                            validator: null,
                          ),
                          SizedBox(height: 16.0),
                          _buildTextFormField(
                            context: context,
                            labelKey: 'phone',
                            fieldValue: controller.phone,
                            keyboardType: TextInputType.phone,
                            validator: null,
                          ),
                          SizedBox(height: 16.0),
                          _buildTextFormField(
                            context: context,
                            labelKey: 'mobile',
                            fieldValue: controller.mobile,
                            keyboardType: TextInputType.phone,
                            validator: null,
                          ),
                          SizedBox(height: 16.0),
                          Obx(() => TextFormField(
                                initialValue: controller.paymentTerms.value.toString(),
                                onChanged: (value) {
                                  controller.paymentTerms.value = int.tryParse(value) ?? 0;
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return S.of(context).field_required;
                                  }
                                  if (int.tryParse(value) == null) {
                                    return S.of(context).invalid_number.toString();
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: S.of(context).payment_terms,
                                  labelStyle: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Color(0xFFB0B0B0)
                                        : Color(0xFF757575),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Color(0xFF4FC3F7)
                                          : Color(0xFF1976D2),
                                      width: 2.0,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness == Brightness.dark
                                      ? Color(0xFF1A1A1A)
                                      : Colors.white,
                                ),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Color(0xFF212121),
                                ),
                              )),
                          SizedBox(height: 20.0),
                          Row(
                            children: [
                              Expanded(
                                child: Obx(() => ElevatedButton(
                                      onPressed: controller.isLoading.value
                                          ? null
                                          : () async {
                                              if (_formKey.currentState!.validate()) {
                                                await controller.addCustomer();
                                              } else {
                                                Get.snackbar(
                                                  S.of(context).error,
                                                  S.of(context).please_fill_fields,
                                                  snackPosition: SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 14.0),
                                      ),
                                      child: controller.isLoading.value
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              S.of(context).save,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontSize: getResponsiveFontSize(context, 14),
                                              ),
                                            ),
                                    )),
                              ),
                              SizedBox(width: 10.0),
                              Expanded(
                                child: Obx(() => ElevatedButton(
                                      onPressed: controller.isLoading.value
                                          ? null // Disable during loading
                                          : () {
                                              _formKey.currentState?.reset();
                                              controller.name.value = '';
                                              controller.address.value = '';
                                              controller.city.value = '';
                                              controller.state.value = '';
                                              controller.country.value = '';
                                              controller.phone.value = '';
                                              controller.mobile.value = '';
                                              controller.paymentTerms.value = 0;
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark ? Color(0xFF2A2A2A) : Colors.grey[300],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 14.0),
                                      ),
                                      child: Text(
                                        S.of(context).cancel,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Color(0xFFB0B0B0) : Colors.black87,
                                          fontSize: getResponsiveFontSize(context, 14),
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}