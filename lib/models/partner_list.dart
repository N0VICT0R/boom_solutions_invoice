
// lib/models/partner.dart
class Partner {
  final int id;
  final String name;

  Partner({required this.id, required this.name});

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'],
      name: json['name'],
    );
  }
}

// lib/models/statement.dart
class Statement {
  final String dateFrom;
  final String dateTo;
  final String currency;
  final double endingBalance;
  final List<Transaction> transactions;
  final int invoiceCount;
  final int paymentCount;

  Statement({
    required this.dateFrom,
    required this.dateTo,
    required this.currency,
    required this.endingBalance,
    required this.transactions,
    required this.invoiceCount,
    required this.paymentCount,
  });

  factory Statement.fromJson(Map<String, dynamic> json) {
    return Statement(
      dateFrom: json['date_from'],
      dateTo: json['date_to'],
      currency: json['currency'],
      endingBalance: json['ending_balance'].toDouble(),
      transactions: List<Transaction>.from(json['transactions'].map((x) => Transaction.fromJson(x))),
      invoiceCount: json['invoice_count'],
      paymentCount: json['payment_count'],
    );
  }
}

// lib/models/transaction.dart
class Transaction {
  final String date;
  final String reference;
  final String transactionType;
  final String accountCode;
  final String accountName;
  final double debit;
  final double credit;
  final String description;
  final double balance;

  Transaction({
    required this.date,
    required this.reference,
    required this.transactionType,
    required this.accountCode,
    required this.accountName,
    required this.debit,
    required this.credit,
    required this.description,
    required this.balance,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      date: json['date'],
      reference: json['reference'],
      transactionType: json['transaction_type'],
      accountCode: json['account_code'],
      accountName: json['account_name'],
      debit: json['debit'].toDouble(),
      credit: json['credit'].toDouble(),
      description: json['description'],
      balance: json['balance'].toDouble(),
    );
  }
}



class PartnerList {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final dynamic phone;
  final dynamic mobile;

  // String email;

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
      id: json['id'] ?? 10,
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