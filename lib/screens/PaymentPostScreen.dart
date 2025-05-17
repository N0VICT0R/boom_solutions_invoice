import 'package:boom_solutions_invoice/screens/customer_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:boom_solutions_invoice/generated/l10n.dart'; // Import localization

class InvoicePaymentPage extends StatefulWidget {
  final int partnerId;

  const InvoicePaymentPage({super.key, required this.partnerId});

  @override
  State<InvoicePaymentPage> createState() => _InvoicePaymentPageState();
}

class _InvoicePaymentPageState extends State<InvoicePaymentPage> {
  final InvoiceController controller = Get.put(InvoiceController());
  final token = GetStorage().read('token') ?? '';
  String? selectedPaymentMethod;

  final List<Map<String, dynamic>> paymentMethods = [
    {'id': '1', 'name': S.current.cash}, // Localized
    {'id': '2', 'name': S.current.card}, // Localized
  ];

  @override
  void initState() {
    super.initState();
    controller.fetchInvoices(widget.partnerId, token);
    selectedPaymentMethod = '1'; // Default to Cash
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.partnerName.value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Container(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = controller.invoices[index];
                    return _buildBoardingPassCard(context, invoice);
                  },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: DropdownButtonFormField<String>(
                        value: selectedPaymentMethod,
                        decoration: InputDecoration(
                          labelText: S.of(context).payment_method, // Localized
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: paymentMethods.map((method) {
                          return DropdownMenuItem<String>(
                            value: method['id'],
                            child: Text(method['name']),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPaymentMethod = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return S.of(context).please_select_payment_method; // Localized
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                              "${S.of(context).total}: ${controller.totalPayment.value.toStringAsFixed(2)} ${controller.currency.value}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedPaymentMethod == null) {
                              Get.snackbar(
                                  S.of(context).error, // Localized
                                  S.of(context).please_select_payment_method); // Localized
                              return;
                            }
                            final paymentMethodId =
                                int.parse(selectedPaymentMethod!);
                            controller.payAllInvoices(
                              widget.partnerId,
                              token,
                              paymentMethodId,
                            );
                            Get.lazyPut<CustomerController>(
                                () => CustomerController(),
                                fenix: true);
                            Get.lazyPut<PartnerController>(
                                () => PartnerController());
                            final partnerController =
                                Get.find<PartnerController>();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "    ${S.of(context).pay_all}    ", // Localized
                            style: TextStyle(
                              // color: Colors.green[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBoardingPassCard(BuildContext context, InvoiceData invoice) {
    final textController = controller.textControllers[invoice.id]!;
    final theme = Theme.of(context);

    Border cardBorder;
    switch (invoice.state.toLowerCase()) {
      case 'paid':
        cardBorder = Border.all(color: theme.dividerColor, width: 1);
        break;
      case 'partial':
        cardBorder =
            Border.all(color: theme.dividerColor.withOpacity(0.8), width: 1);
        break;
      case 'overdue':
        cardBorder =
            Border.all(color: theme.dividerColor.withOpacity(0.6), width: 1);
        break;
      default:
        cardBorder = Border.all(color: theme.dividerColor, width: 1);
    }

    final invoiceDate = invoice.date.split(' ')[0];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 16,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 16,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: cardBorder,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              color: theme.cardColor,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            invoice.number,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${invoice.originalAmount.toStringAsFixed(2)} ${invoice.currency}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).invoice_date, // Localized
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  invoiceDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.dividerColor,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: theme.dividerColor,
                                  ),
                                ),
                                Icon(Icons.receipt,
                                    size: 18, color: theme.iconTheme.color),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: theme.dividerColor,
                                  ),
                                ),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.dividerColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  S.of(context).due_date, // Localized
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  invoice.dueDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              invoice.state.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                S.of(context).pending, // Localized
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                              Text(
                                '${invoice.pendingAmount.toStringAsFixed(2)} ${invoice.currency}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Flex(
                        direction: Axis.horizontal,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          (constraints.constrainWidth() / 10).floor(),
                          (index) => Container(
                            width: 5,
                            color: theme.dividerColor,
                            height: 1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: textController,
                        
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                          MaxAmountInputFormatter(
                              maxValue: invoice.pendingAmount),
                        ],
                        decoration: InputDecoration(
                          
              fillColor:  theme.colorScheme.primaryContainer,
              filled: true,
                          focusColor: theme.colorScheme.primary,
                          labelText: S.of(context).payment_amount, // Localized
                          hintText:
                              "${S.of(context).max} ${invoice.pendingAmount.toStringAsFixed(2)}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          // filled: true,
                          // fillColor: theme.canvasColor.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${S.of(context).due_now}: ${invoice.dueNow.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Text(
                            "${S.of(context).due_later}: ${invoice.dueLater.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceController extends GetxController {
  var isLoading = false.obs;
  var invoices = <InvoiceData>[].obs;
  var partnerName = ''.obs;
  var currency = ''.obs;
  var totalPayment = 0.0.obs; // Made reactive

  final Map<int, TextEditingController> textControllers = {};

  double getTotalPayment() {
    double sum = 0.0;
    for (var controller in textControllers.values) {
      final value = double.tryParse(controller.text) ?? 0.0;
      sum += value;
    }
    totalPayment.value = sum;
    return sum;
  }

  Future<void> fetchInvoices(int partnerId, String token) async {
    isLoading.value = true;
    try {
      final apiurl = GetStorage().read("apiUrl");
      final url = Uri.parse(
          '$apiurl/api/v1/partners/$partnerId/invoices?api_token=$token');
      final response =
          await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var invoiceList = (data['invoices'] as List)
            .map((json) => InvoiceData.fromJson(json))
            .toList();
        invoices.assignAll(invoiceList);
        partnerName.value = data['partner_name'] ?? '';
        currency.value = data['currency'] ?? '';

        textControllers.clear();

        for (var invoice in invoiceList) {
          textControllers.putIfAbsent(invoice.id, () {
            final controller = TextEditingController();
            controller.addListener(() {
              getTotalPayment();
            });
            return controller;
          });
        }
        getTotalPayment(); // Initial calculation
      }
    } catch (e) {
      Get.snackbar(S.of(Get.context!).error, S.of(Get.context!).an_error_occurred); // Localized
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> payAllInvoices(
      int partnerId, String token, int paymentMethodId) async {
    if (token.isEmpty) {
      Get.snackbar(S.of(Get.context!).error, S.of(Get.context!).auth_token_not_found); // Localized
      return;
    }

    List<Map<String, dynamic>> invoicePayments = [];
    for (var invoice in invoices) {
      final amount = double.tryParse(textControllers[invoice.id]!.text) ?? 0.0;
      if (amount > 0) {
        invoicePayments.add({
          "invoice_id": invoice.number,
          "amount": amount,
        });
      }
    }

    if (invoicePayments.isEmpty) {
      Get.snackbar(
          S.of(Get.context!).error, S.of(Get.context!).please_enter_valid_amounts); // Localized
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'http://137.184.205.67:2710/api/v1/partners/$partnerId/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'api_token': token,
          'amount': totalPayment.value,
          'payment_method_id': paymentMethodId,
          'memo': "${S.of(Get.context!).payment_for} ${invoicePayments.length} ${S.of(Get.context!).invoices}",
          'post_immediately': true,
          'invoices': invoicePayments,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        for (var controller in textControllers.values) {
          controller.clear();
        }
        fetchInvoices(partnerId, token);
        await Future.delayed(const Duration(seconds: 2));
        Get.back(result: true);
      } else {
        Get.snackbar(
          S.of(Get.context!).error,
          json.decode(response.body)['message'] ?? S.of(Get.context!).payment_failed, // Localized
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        S.of(Get.context!).error,
        S.of(Get.context!).an_error_occurred,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class InvoiceData {
  final int id;
  final String number;
  final String date;
  final String dueDate;
  final double originalAmount;
  final double pendingAmount;
  final double dueNow;
  final double dueLater;
  final String currency;
  final String state;

  InvoiceData({
    required this.id,
    required this.number,
    required this.date,
    required this.dueDate,
    required this.originalAmount,
    required this.pendingAmount,
    required this.dueNow,
    required this.dueLater,
    required this.currency,
    required this.state,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      id: json['id'],
      number: json['number'],
      date: json['date'],
      dueDate: json['due_date'],
      originalAmount: (json['original_amount'] as num).toDouble(),
      pendingAmount: (json['pending_amount'] as num).toDouble(),
      dueNow: (json['due_now'] as num).toDouble(),
      dueLater: (json['due_later'] as num).toDouble(),
      currency: json['currency'],
      state: json['state'],
    );
  }
}

class MaxAmountInputFormatter extends TextInputFormatter {
  final double maxValue;
  MaxAmountInputFormatter({required this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    double? entered = double.tryParse(newValue.text);
    if (entered == null) return oldValue;
    if (entered > maxValue) return oldValue;
    return newValue;
  }
}