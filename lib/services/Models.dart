// lib/models/models.dart

// User & Auth
class User {
  final int id;
  final String name;
  final String login;
  final String email;
  final int partnerId;
  final int storeId;
  final String storeName;

  User({
    required this.id,
    required this.name,
    required this.login,
    required this.email,
    required this.partnerId,
    required this.storeId,
    required this.storeName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      login: json['login'],
      email: json['email'],
      partnerId: json['partner_id'],
      storeId: json['store_id'],
      storeName: json['store_name'],
    );
  }
}

class AuthResponse {
  final String apiToken;
  final User user;

  AuthResponse({
    required this.apiToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      apiToken: json['api_token'],
      user: User.fromJson(json['user']),
    );
  }
}

// Partner, Partner Statement & Statement
class Partner {
  final int id;
  final String name;
  // You can add other fields if available

  Partner({required this.id, required this.name});

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Transaction {
  final String date;
  final String reference;
  final String transactionType;
  final double debit;
  final double credit;
  final String description;
  final double balance;

  Transaction({
    required this.date,
    required this.reference,
    required this.transactionType,
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
      debit: (json['debit'] as num).toDouble(),
      credit: (json['credit'] as num).toDouble(),
      description: json['description'] ?? '',
      balance: (json['balance'] as num).toDouble(),
    );
  }
}

class Statement {
  final String dateFrom;
  final String dateTo;
  final String currency;
  final double endingBalance;
  final List<Transaction> transactions;

  Statement({
    required this.dateFrom,
    required this.dateTo,
    required this.currency,
    required this.endingBalance,
    required this.transactions,
  });

  factory Statement.fromJson(Map<String, dynamic> json) {
    var txList = (json['transactions'] as List)
        .map((tx) => Transaction.fromJson(tx))
        .toList();
    return Statement(
      dateFrom: json['date_from'],
      dateTo: json['date_to'],
      currency: json['currency'],
      endingBalance: (json['ending_balance'] as num).toDouble(),
      transactions: txList,
    );
  }
}

class PartnerStatement {
  final Partner partner;
  final Statement statement;

  PartnerStatement({required this.partner, required this.statement});
}

// Partners List
class PartnersList {
  final bool success;
  final int count;
  final int total;
  final int page;
  final int pages;
  final List<Partner> partners;

  PartnersList({
    required this.success,
    required this.count,
    required this.total,
    required this.page,
    required this.pages,
    required this.partners,
  });

  factory PartnersList.fromJson(Map<String, dynamic> json) {
    var list = (json['partners'] as List)
        .map((e) => Partner.fromJson(e))
        .toList();
    return PartnersList(
      success: json['success'],
      count: json['count'],
      total: json['total'],
      page: json['page'],
      pages: json['pages'],
      partners: list,
    );
  }
}

// States
class StateModel {
  final int id;
  final String name;
  final String code;

  StateModel({required this.id, required this.name, required this.code});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class StatesResponse {
  final bool success;
  final Map<String, dynamic> country;
  final int count;
  final List<StateModel> states;

  StatesResponse({
    required this.success,
    required this.country,
    required this.count,
    required this.states,
  });

  factory StatesResponse.fromJson(Map<String, dynamic> json) {
    var list = (json['states'] as List)
        .map((e) => StateModel.fromJson(e))
        .toList();
    return StatesResponse(
      success: json['success'],
      country: json['country'],
      count: json['count'],
      states: list,
    );
  }
}

// Customer Balance
class CustomerBalance {
  final int id;
  final String name;
  final double balance;
  final double amountDueToday;
  final double aov;
  final double oct;
  final int orderCount;
  final String currency;

  CustomerBalance({
    required this.id,
    required this.name,
    required this.balance,
    required this.amountDueToday,
    required this.aov,
    required this.oct,
    required this.orderCount,
    required this.currency,
  });

  factory CustomerBalance.fromJson(Map<String, dynamic> json) {
    final partner = json['partner'];
    return CustomerBalance(
      id: partner['id'],
      name: partner['name'],
      balance: (partner['balance'] as num).toDouble(),
      amountDueToday: (partner['amount_due_today'] as num).toDouble(),
      aov: (partner['aov'] as num).toDouble(),
      oct: (partner['oct'] as num).toDouble(),
      orderCount: partner['order_count'],
      currency: partner['currency'],
    );
  }
}

// Sales Customer Products Chart
class SalesProduct {
  final String name;
  final double amount;
  final double percentage;

  SalesProduct({
    required this.name,
    required this.amount,
    required this.percentage,
  });

  factory SalesProduct.fromJson(Map<String, dynamic> json) {
    return SalesProduct(
      name: json['name']['en_US'],
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class SalesCustomerProductsChart {
  final Partner partner;
  final double totalSales;
  final String currency;
  final String currencySymbol;
  final List<SalesProduct> products;

  SalesCustomerProductsChart({
    required this.partner,
    required this.totalSales,
    required this.currency,
    required this.currencySymbol,
    required this.products,
  });

  factory SalesCustomerProductsChart.fromJson(Map<String, dynamic> json) {
    var prods = (json['products'] as List)
        .map((e) => SalesProduct.fromJson(e))
        .toList();
    return SalesCustomerProductsChart(
      partner: Partner.fromJson(json['partner']),
      totalSales: (json['total_sales'] as num).toDouble(),
      currency: json['currency'],
      currencySymbol: json['currency_symbol'],
      products: prods,
    );
  }
}

// Customer Payments
class PaymentModel {
  final int id;
  final String name;
  final double amount;
  final String date;
  final String state;
  final String journalName;
  final String createDate;
  final String memo;

  PaymentModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.state,
    required this.journalName,
    required this.createDate,
    required this.memo,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      date: json['date'],
      state: json['state'],
      journalName: json['journal_name'],
      createDate: json['create_date'],
      memo: json['memo'],
    );
  }
}

class CustomerPayments {
  final bool success;
  final int count;
  final int total;
  final int page;
  final int pages;
  final int partnerId;
  final String partnerName;
  final String currency;
  final List<PaymentModel> payments;

  CustomerPayments({
    required this.success,
    required this.count,
    required this.total,
    required this.page,
    required this.pages,
    required this.partnerId,
    required this.partnerName,
    required this.currency,
    required this.payments,
  });

  factory CustomerPayments.fromJson(Map<String, dynamic> json) {
    var pays = (json['payments'] as List)
        .map((e) => PaymentModel.fromJson(e))
        .toList();
    return CustomerPayments(
      success: json['success'],
      count: json['count'],
      total: json['total'],
      page: json['page'],
      pages: json['pages'],
      partnerId: json['partner_id'],
      partnerName: json['partner_name'],
      currency: json['currency'],
      payments: pays,
    );
  }
}

// Current Stock
class Location {
  final int id;
  final String name;
  final String completeName;

  Location({
    required this.id,
    required this.name,
    required this.completeName,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      completeName: json['complete_name'],
    );
  }
}

class StockProduct {
  final int productId;
  final String name;
  final String defaultCode;
  final String barcode;
  final int categoryId;
  final String categoryName;
  final double quantity;
  final double reservedQuantity;
  final double availableQuantity;
  final String uom;
  final double price;
  final String imageUrl;

  StockProduct({
    required this.productId,
    required this.name,
    required this.defaultCode,
    required this.barcode,
    required this.categoryId,
    required this.categoryName,
    required this.quantity,
    required this.reservedQuantity,
    required this.availableQuantity,
    required this.uom,
    required this.price,
    required this.imageUrl,
  });

  factory StockProduct.fromJson(Map<String, dynamic> json) {
    return StockProduct(
      productId: json['product_id'],
      name: json['name'],
      defaultCode: json['default_code'] ?? '',
      barcode: json['barcode'] ?? '',
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      quantity: (json['quantity'] as num).toDouble(),
      reservedQuantity: (json['reserved_quantity'] as num).toDouble(),
      availableQuantity: (json['available_quantity'] as num).toDouble(),
      uom: json['uom'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
    );
  }
}

class CurrentStock {
  final Location location;
  final User user;
  final int count;
  final List<StockProduct> products;

  CurrentStock({
    required this.location,
    required this.user,
    required this.count,
    required this.products,
  });

  factory CurrentStock.fromJson(Map<String, dynamic> json) {
    var prods = (json['products'] as List)
        .map((e) => StockProduct.fromJson(e))
        .toList();
    return CurrentStock(
      location: Location.fromJson(json['location']),
      user: User.fromJson(json['user']),
      count: json['count'],
      products: prods,
    );
  }
}
