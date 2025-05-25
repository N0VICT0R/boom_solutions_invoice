import 'dart:convert';
import 'package:boom_solutions_invoice/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class InvoicePaymentPage extends StatefulWidget {
  final int partnerId;

  const InvoicePaymentPage({super.key, required this.partnerId});

  @override
  State<InvoicePaymentPage> createState() => _InvoicePaymentPageState();
}

class _InvoicePaymentPageState extends State<InvoicePaymentPage> {
  final InvoiceController controller = Get.put(InvoiceController());
  String token = GetStorage().read('token') ?? '';
  String? selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    GetStorage.init().then((_) {
      controller.fetchInvoices(widget.partnerId, token);
      controller.fetchPaymentMethods(token).then((_) {
        if (controller.paymentMethods.isNotEmpty && mounted) {
          setState(() {
            selectedPaymentMethod = controller.paymentMethods.first['id'];
          });
        }
      });
    });

    GetStorage().listenKey('token', (value) {
      final newToken = value as String? ?? '';
      if (mounted) {
        setState(() {
          token = newToken;
        });
        controller.fetchPaymentMethods(newToken);
        controller.fetchInvoices(widget.partnerId, newToken);
        setState(() {
          selectedPaymentMethod = controller.paymentMethods.isNotEmpty ? controller.paymentMethods.first['id'] : null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.partnerName.value.isEmpty ? 'Loading...' : controller.partnerName.value,
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
              child: controller.invoices.isEmpty
                  ? const Center(child: Text('No invoices available'))
                  : ListView.builder(
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
                        labelText: S.of(context).payment_method,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: controller.paymentMethods.map((method) {
                        return DropdownMenuItem<String>(
                          value: method['id'],
                          child: Text('${method['name']} (${method['type']})'),
                        );
                      }).toList(),
                      onChanged: controller.paymentMethods.isEmpty
                          ? null
                          : (String? newValue) {
                              if (mounted) {
                                setState(() {
                                  selectedPaymentMethod = newValue;
                                });
                              }
                            },
                      validator: (value) => value == null ? S.of(context).please_select_payment_method : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                            "${S.of(context).total}: ${controller.totalPayment.value.toStringAsFixed(2)} ${controller.currency.value}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                      ElevatedButton(
                        onPressed: controller.paymentMethods.isEmpty || selectedPaymentMethod == null
                            ? null
                            : () async {
                                try {
                                  print('Calling payAllInvoices with partnerId: ${widget.partnerId}');
                                  await controller.payAllInvoices(context, widget.partnerId, token);
                                } catch (e, stackTrace) {
                                  print('Error in payAllInvoices: $e\nStack trace: $stackTrace');
                                  Get.snackbar(
                                    S.of(context).error,
                                    'Failed to process payment: $e',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          "    ${S.of(context).pay_all}    ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
    final textController = controller.textControllers[invoice.id] ?? TextEditingController();
    final theme = Theme.of(context);

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

    final invoiceDate = invoice.date.split(' ').first;

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
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
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
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '${invoice.originalAmount.toStringAsFixed(2)} ${invoice.currency}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                  S.of(context).invoice_date,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  invoiceDate,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                Expanded(child: Container(height: 1, color: theme.dividerColor)),
                                Icon(Icons.receipt, size: 18, color: theme.iconTheme.color),
                                Expanded(child: Container(height: 1, color: theme.dividerColor)),
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
                                  S.of(context).due_date,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  invoice.dueDate,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
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
                                S.of(context).pending,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                              Text(
                                '${invoice.pendingAmount.toStringAsFixed(2)} ${invoice.currency}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                          (index) => Container(width: 5, color: theme.dividerColor, height: 1),
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          MaxAmountInputFormatter(maxValue: invoice.pendingAmount),
                        ],
                        decoration: InputDecoration(
                          fillColor: theme.colorScheme.primaryContainer,
                          filled: true,
                          focusColor: theme.colorScheme.primary,
                          labelText: S.of(context).payment_amount,
                          hintText: "${S.of(context).max} ${invoice.pendingAmount.toStringAsFixed(2)}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
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

class MaxAmountInputFormatter extends TextInputFormatter {
  final double maxValue;

  MaxAmountInputFormatter({required this.maxValue});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final entered = double.tryParse(newValue.text);
    if (entered == null || entered > maxValue) return oldValue;
    return newValue;
  }
}

class InvoiceController extends GetxController {
  var isLoading = false.obs;
  var invoices = <InvoiceData>[].obs;
  var partnerName = ''.obs;
  var currency = ''.obs;
  var totalPayment = 0.0.obs;
  var paymentMethods = <Map<String, dynamic>>[].obs;
  final Map<int, TextEditingController> textControllers = {};

  double getTotalPayment() {
    double sum = 0.0;
    for (var controller in textControllers.values) {
      sum += double.tryParse(controller.text) ?? 0.0;
    }
    totalPayment.value = sum;
    return sum;
  }

  Future<void> fetchInvoices(int partnerId, String token) async {
    isLoading.value = true;
    try {
      final apiUrl = GetStorage().read('apiUrl') ?? 'https://onix.boom-solutions.co';
      final url = Uri.parse('$apiUrl/api/v1/partners/$partnerId/invoices?api_token=$token');
      print('Fetching invoices: $url');
      final response = await http
          .get(url, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 10));

      print('Invoices response: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final invoiceList = (data['invoices'] as List?)?.map((json) => InvoiceData.fromJson(json)).toList() ?? [];
        invoices.assignAll(invoiceList);
        partnerName.value = data['partner_name'] as String? ?? '';
        currency.value = data['currency'] as String? ?? '';

        textControllers.clear();
        for (var invoice in invoiceList) {
          textControllers.putIfAbsent(invoice.id, () {
            final controller = TextEditingController();
            controller.addListener(getTotalPayment);
            return controller;
          });
        }
        getTotalPayment();
      } else {
        throw Exception(response.statusCode == 401
            ? 'Unauthorized: Invalid or expired token'
            : 'Failed to fetch invoices: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching invoices: $e\nStack trace: $stackTrace');
      Get.snackbar(
        'Error',
        e.toString().contains('Unauthorized') ? 'Please log in again' : 'Failed to fetch invoices: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPaymentMethods(String token) async {
    try {
      final apiUrl = GetStorage().read('apiUrl') ?? 'https://onix.boom-solutions.co';
      final url = Uri.parse('$apiUrl/api/v1/payment-methods?api_token=$token');
      print('Fetching payment methods: $url');
      final response = await http
          .get(url, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 10));

      print('Payment methods response: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          paymentMethods.assignAll((data['payment_methods'] as List?)?.map((method) => {
                'id': method['id']?.toString() ?? '',
                'name': method['name'] as String? ?? 'Unknown Method',
                'type': method['type'] as String? ?? 'Unknown',
              }).toList() ??
              []);
          if (paymentMethods.isEmpty) {
            print('No payment methods available');
            Get.snackbar(
              'Warning',
              'No payment methods available. Please contact support.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        } else {
          throw Exception('Failed to fetch payment methods: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception(response.statusCode == 401
            ? 'Unauthorized: Invalid or expired token'
            : 'Failed to fetch payment methods: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching payment methods: $e\nStack trace: $stackTrace');
      Get.snackbar(
        'Error',
        e.toString().contains('Unauthorized') ? 'Please log in again' : 'Failed to fetch payment methods: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> payAllInvoices(BuildContext context, int partnerId, String token) async {
    print('Starting payAllInvoices: partnerId=$partnerId, token=$token');
    if (token.isEmpty) {
      print('Empty token detected');
      Get.snackbar(
        S.of(context).error,
        S.of(context).no_token,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final journalId = GetStorage().read('journalId') as int? ?? 0;
    if (journalId == 0) {
      print('No journal ID in GetStorage');
      Get.snackbar(
        S.of(context).error,
        S.of(context).no_journal_id,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final invoicePayments = <Map<String, dynamic>>[];
    for (var invoice in invoices) {
      final amount = double.tryParse(textControllers[invoice.id]?.text ?? '') ?? 0.0;
      if (amount > 0 && amount <= invoice.pendingAmount) {
        invoicePayments.add({
          'invoice_id': invoice.number,
          'amount': amount,
        });
      }
    }

    if (invoicePayments.isEmpty) {
      print('No valid invoice payments');
      Get.snackbar(
        S.of(context).error,
        S.of(context).please_enter_valid_amounts,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final apiUrl = GetStorage().read('apiUrl') ?? 'https://onix.boom-solutions.co';
      final url = Uri.parse('$apiUrl/api/v1/partners/$partnerId/payments');
      final requestBody = jsonEncode({
        'api_token': token,
        'amount': totalPayment.value,
        'journal_id': journalId,
        'memo': 'xxxxxx',
        'invoices': invoicePayments,
      });
      print('Posting payment: $url\nBody: $requestBody');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      print('Payment response: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        for (var controller in textControllers.values) {
          controller.clear();
        }
        await fetchInvoices(partnerId, token);

        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(S.of(context).success),
              content: Text(S.of(context).payment_successful),
              actions: [
                TextButton(
                  child: Text(S.of(context).ok),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );

          if (context.mounted) {
            Navigator.of(context).pop(true);
          }
        }
      } else {
        final errorMessage = jsonDecode(response.body)['message'] as String? ?? S.of(context).payment_failed;
        print('Payment error: $errorMessage');
        Get.snackbar(
          S.of(context).error,
          response.statusCode == 401 ? 'Please log in again' : errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      print('Error posting payment: $e\nStack trace: $stackTrace');
      Get.snackbar(
        S.of(context).error,
        'Failed to process payment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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

  factory InvoiceData.fromJson(Map<String, dynamic> json) => InvoiceData(
        id: json['id'] as int? ?? 0,
        number: json['number'] as String? ?? '',
        date: json['date'] as String? ?? '',
        dueDate: json['due_date'] as String? ?? '',
        originalAmount: (json['original_amount'] as num?)?.toDouble() ?? 0.0,
        pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0.0,
        dueNow: (json['due_now'] as num?)?.toDouble() ?? 0.0,
        dueLater: (json['due_later'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? '',
        state: json['state'] as String? ?? '',
      );
}

// class S {
//   static S of(BuildContext context) => S();
//   String get payment_method => 'Payment Method';
//   String get please_select_payment_method => 'Please select a payment method';
//   String get total => 'Total';
//   String get pay_all => 'Pay All';
//   String get invoice_date => 'Invoice Date';
//   String get due_date => 'Due Date';
//   String get pending => 'Pending';
//   String get payment_amount => 'Payment Amount';
//   String get max => 'Max';
//   String get due_now => 'Due Now';
//   String get due_later => 'Due Later';
//   String get error => 'Error';
//   String get no_token => 'No token provided';
//   String get please_enter_valid_amounts => 'Please enter valid amounts';
//   String get payment_successful => 'Payment Successful';
//   String get payment_failed => 'Payment Failed';
//   String get success => 'Success';
//   String get ok => 'OK';
//   String get invalid_payment_method => 'Invalid payment method selected';
//   String get no_journal_id => 'No journal ID available';
// }
