import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InvoicePaymentPage extends StatefulWidget {
  final int partnerId;

  const InvoicePaymentPage({Key? key, required this.partnerId}) : super(key: key);

  @override
  State<InvoicePaymentPage> createState() => _InvoicePaymentPageState();
}

class _InvoicePaymentPageState extends State<InvoicePaymentPage> {
  final InvoiceController controller = Get.put(InvoiceController());
  final token = GetStorage().read('token') ?? '';

  @override
  void initState() {
    super.initState();
    controller.fetchInvoices(widget.partnerId, token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          "${controller.partnerName.value}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Obx(() => Text(
                  //   "Total: ${controller.totalPayment.toStringAsFixed(2)} ${controller.currency.value}",
                  //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // )),
                  ElevatedButton(
                    onPressed: () => controller.payAllInvoices(widget.partnerId, token),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:  Text("    Pay All    ",style:TextStyle(color: Colors.green[600],fontWeight:FontWeight.bold),),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
  Widget _buildBoardingPassCard(BuildContext context, InvoiceData invoice) {
    final textController = controller.textControllers[invoice.id]!;
    final theme = Theme.of(context);

    // Determine border style based on invoice state
    Border cardBorder;
    switch (invoice.state.toLowerCase()) {
      case 'paid':
        cardBorder = Border.all(color: theme.dividerColor, width: 1);
        break;
      case 'partial':
        cardBorder = Border.all(color: theme.dividerColor.withOpacity(0.8), width: 1);
        break;
      case 'overdue':
        cardBorder = Border.all(color: theme.dividerColor.withOpacity(0.6), width: 1);
        break;
      default:
        cardBorder = Border.all(color: theme.dividerColor, width: 1);
    }

    final invoiceDate = invoice.date.split(' ')[0];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        children: [
          // Left half circle
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
          // Right half circle
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
                      // Header with invoice number and amount
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

                      // Dates section with flight-like layout
                      Row(
                        children: [
                          // Invoice date (departure)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'INVOICE DATE',
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

                          // Flight icons
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
                                Icon(Icons.receipt, size: 18, color: theme.iconTheme.color),
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

                          // Due date (arrival)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'DUE DATE',
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

                      // Status and payment status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

                          // Pending amount
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'PENDING',
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

                // Dashed line separator
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

                // Payment section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: textController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          MaxAmountInputFormatter(maxValue: invoice.pendingAmount),
                        ],
                        decoration: InputDecoration(
                          labelText: "Payment amount",
                          hintText: "Max ${invoice.pendingAmount.toStringAsFixed(2)}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          filled: true,
                          fillColor: theme.cardTheme.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Due Now: ${invoice.dueNow.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Text(
                            "Due Later: ${invoice.dueLater.toStringAsFixed(2)}",
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
  }  // Widget _buildBoardingPassCard(BuildContext context, InvoiceData invoice) {
  //   final textController = controller.textControllers[invoice.id]!;
  //   final theme = Theme.of(context);
  //
  //   // Determine border style based on invoice state
  //   Border cardBorder;
  //   switch (invoice.state.toLowerCase()) {
  //     case 'paid':
  //       cardBorder = Border.all(color: theme.dividerColor, width: 1);
  //       break;
  //     case 'partial':
  //       cardBorder = Border.all(color: theme.dividerColor.withOpacity(0.8), width: 1);
  //       break;
  //     case 'overdue':
  //       cardBorder = Border.all(color: theme.dividerColor.withOpacity(0.6), width: 1);
  //       break;
  //     default:
  //       cardBorder = Border.all(color: theme.dividerColor, width: 1);
  //   }
  //
  //   final invoiceDate = invoice.date.split(' ')[0];
  //
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16.0),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(16),
  //         border: cardBorder,
  //         boxShadow: [
  //           BoxShadow(
  //             color: theme.shadowColor.withOpacity(0.05),
  //             blurRadius: 4,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               children: [
  //                 // Header with invoice number and amount
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       invoice.number,
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 14,
  //                       ),
  //                     ),
  //                     Text(
  //                       '${invoice.originalAmount.toStringAsFixed(2)} ${invoice.currency}',
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 16,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
  //
  //                 // Dates section with flight-like layout
  //                 Row(
  //                   children: [
  //                     // Invoice date (departure)
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             'INVOICE DATE',
  //                             style: TextStyle(
  //                               fontSize: 10,
  //                               fontWeight: FontWeight.w500,
  //                               color: theme.textTheme.bodySmall?.color,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 4),
  //                           Text(
  //                             invoiceDate,
  //                             style: const TextStyle(
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //
  //                     // Flight icons
  //                     Expanded(
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Container(
  //                             width: 8,
  //                             height: 8,
  //                             decoration: BoxDecoration(
  //                               shape: BoxShape.circle,
  //                               color: theme.dividerColor,
  //                             ),
  //                           ),
  //                           Expanded(
  //                             child: Container(
  //                               height: 1,
  //                               color: theme.dividerColor,
  //                             ),
  //                           ),
  //                           Icon(Icons.receipt, size: 18, color: theme.iconTheme.color),
  //                           Expanded(
  //                             child: Container(
  //                               height: 1,
  //                               color: theme.dividerColor,
  //                             ),
  //                           ),
  //                           Container(
  //                             width: 8,
  //                             height: 8,
  //                             decoration: BoxDecoration(
  //                               shape: BoxShape.circle,
  //                               color: theme.dividerColor,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //
  //                     // Due date (arrival)
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.end,
  //                         children: [
  //                           Text(
  //                             'DUE DATE',
  //                             style: TextStyle(
  //                               fontSize: 10,
  //                               fontWeight: FontWeight.w500,
  //                               color: theme.textTheme.bodySmall?.color,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 4),
  //                           Text(
  //                             invoice.dueDate,
  //                             style: const TextStyle(
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //
  //                 const SizedBox(height: 16),
  //
  //                 // Status and payment status
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     // Status indicator
  //                     Container(
  //                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: Text(
  //                         invoice.state.toUpperCase(),
  //                         style: TextStyle(
  //                           fontSize: 12,
  //                           fontWeight: FontWeight.bold,
  //                           color: theme.textTheme.bodyMedium?.color,
  //                         ),
  //                       ),
  //                     ),
  //
  //                     // Pending amount
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.end,
  //                       children: [
  //                         Text(
  //                           'PENDING',
  //                           style: TextStyle(
  //                             fontSize: 10,
  //                             fontWeight: FontWeight.w500,
  //                             color: theme.textTheme.bodySmall?.color,
  //                           ),
  //                         ),
  //                         Text(
  //                           '${invoice.pendingAmount.toStringAsFixed(2)} ${invoice.currency}',
  //                           style: const TextStyle(
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //
  //           // Dashed line separator
  //           Container(
  //             margin: const EdgeInsets.symmetric(horizontal: 16),
  //             height: 1,
  //             child: LayoutBuilder(
  //               builder: (context, constraints) {
  //                 return Flex(
  //                   direction: Axis.horizontal,
  //                   mainAxisSize: MainAxisSize.max,
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: List.generate(
  //                     (constraints.constrainWidth() / 10).floor(),
  //                         (index) => Container(
  //                       width: 5,
  //                       color: theme.dividerColor,
  //                       height: 1,
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //
  //           // Payment section
  //           Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               children: [
  //                 TextField(
  //                   controller: textController,
  //                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //                   inputFormatters: [
  //                     FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
  //                     MaxAmountInputFormatter(maxValue: invoice.pendingAmount),
  //                   ],
  //                   decoration: InputDecoration(
  //                     labelText: "Payment amount",
  //                     hintText: "Max ${invoice.pendingAmount.toStringAsFixed(2)}",
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                       borderSide: BorderSide(color: theme.dividerColor),
  //                     ),
  //                     filled: true,
  //                     fillColor: theme.cardTheme.color,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       "Due Now: ${invoice.dueNow.toStringAsFixed(2)}",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.w500,
  //                         color: theme.textTheme.bodySmall?.color,
  //                       ),
  //                     ),
  //                     Text(
  //                       "Due Later: ${invoice.dueLater.toStringAsFixed(2)}",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.w500,
  //                         color: theme.textTheme.bodySmall?.color,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class InvoiceController extends GetxController {
  var isLoading = false.obs;
  var invoices = <InvoiceData>[].obs;
  var partnerName = ''.obs;
  var currency = ''.obs;

  final Map<int, TextEditingController> textControllers = {};

  double get totalPayment {
    double sum = 0.0;
    for (var controller in textControllers.values) {
      final value = double.tryParse(controller.text) ?? 0.0;
      sum += value;
    }
    return sum;
  }

  Future<void> fetchInvoices(int partnerId, String token) async {
    isLoading.value = true;
    try {
      final url = Uri.parse('http://137.184.205.67:2710/api/v1/partners/$partnerId/invoices?api_token=$token');
      final response = await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var invoiceList = (data['invoices'] as List)
            .map((json) => InvoiceData.fromJson(json))
            .toList();
        invoices.assignAll(invoiceList);
        partnerName.value = data['partner_name'] ?? '';
        currency.value = data['currency'] ?? '';

        // Initialize controllers
        for (var invoice in invoiceList) {
        textControllers.putIfAbsent(invoice.id, () {
          final controller = TextEditingController();
          controller.addListener(() => update()); // Add listener to trigger update
          return controller;
        });
      }}
    } catch (e) {
      Get.snackbar("Error", "An error occurred: ");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> payAllInvoices(int partnerId, String token) async {
    if (token.isEmpty) {
      Get.snackbar("Error", "Authentication token not found");
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
      Get.snackbar("Error", "Please enter valid amounts for at least one invoice");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://137.184.205.67:2710/api/v1/partners/$partnerId/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'api_token': token,
          'amount': totalPayment,
          'payment_method_id': 2,
          'memo': "Payment for ${invoicePayments.length} invoices",
          'post_immediately': true,
          'invoices': invoicePayments,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Payment posted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Clear input fields after successful payment
        for (var controller in textControllers.values) {
          controller.clear();
        }
        // Refresh invoices
        fetchInvoices(partnerId, token);
      } else {
        Get.snackbar(
          'Error',
          json.decode(response.body)['message'] ?? 'Payment failed',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred',
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