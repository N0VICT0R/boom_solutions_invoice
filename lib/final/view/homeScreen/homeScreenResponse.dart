class HomeScreenResponse {
  final bool success;
  final User user;
  final MonthlySales monthlySales;
  final Receivables receivables;
  final AdditionalMetrics additionalMetrics;

  HomeScreenResponse({
    required this.success,
    required this.user,
    required this.monthlySales,
    required this.receivables,
    required this.additionalMetrics,
  });

  factory HomeScreenResponse.fromJson(Map<String, dynamic> json) {
    return HomeScreenResponse(
      success: json['success'] ?? false,
      user: User.fromJson(json['user'] ?? {}),
      monthlySales: MonthlySales.fromJson(json['monthly_sales'] ?? {}),
      receivables: Receivables.fromJson(json['receivables'] ?? {}),
      additionalMetrics:
          AdditionalMetrics.fromJson(json['additional_metrics'] ?? {}),
    );
  }
}

class User {
  final int id;
  final String name;
  final int year;
  final int month;

  User({
    required this.id,
    required this.name,
    required this.year,
    required this.month,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
    );
  }
}

class MonthlySales {
  final Metrics metrics;

  MonthlySales({required this.metrics});

  factory MonthlySales.fromJson(Map<String, dynamic> json) {
    return MonthlySales(
      metrics: Metrics.fromJson(json['metrics'] ?? {}),
    );
  }
}

class Metrics {
  final int orderCount;
  final double totalAmount;
  final double monthTarget;
  final double achievementPercentage;

  Metrics({
    required this.orderCount,
    required this.totalAmount,
    required this.monthTarget,
    required this.achievementPercentage,
  });

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      orderCount: json['order_count'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      monthTarget: (json['month_target'] ?? 0.0).toDouble(),
      achievementPercentage: (json['achievement_percentage'] ?? 0.0).toDouble(),
    );
  }
}

class Receivables {
  final double amountDueToday;
  final int partnerCount;
  final int invoiceCount;
  final List<Partner> partnersWithDues;

  Receivables({
    required this.amountDueToday,
    required this.partnerCount,
    required this.invoiceCount,
    required this.partnersWithDues,
  });

  factory Receivables.fromJson(Map<String, dynamic> json) {
    var partnersJson = json['partners_with_dues'] ?? [];
    List<Partner> partners = List<Partner>.from(
        partnersJson.map((partner) => Partner.fromJson(partner)));
    return Receivables(
      amountDueToday: (json['amount_due_today'] ?? 0.0).toDouble(),
      partnerCount: json['partner_count'] ?? 0,
      invoiceCount: json['invoice_count'] ?? 0,
      partnersWithDues: partners,
    );
  }
}

class Partner {
  final int id;
  final String name;
  final double amountDue;

  Partner({
    required this.id,
    required this.name,
    required this.amountDue,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      amountDue: (json['amount_due'] ?? 0.0).toDouble(),
    );
  }
}

class AdditionalMetrics {
  final int totalCustomers;
  final int todayVisits;
  final int newCustomersThisMonth;

  AdditionalMetrics({
    required this.totalCustomers,
    required this.todayVisits,
    required this.newCustomersThisMonth,
  });

  factory AdditionalMetrics.fromJson(Map<String, dynamic> json) {
    return AdditionalMetrics(
      totalCustomers: json['total_customers'] ?? 0,
      todayVisits: json['today_visits'] ,
      newCustomersThisMonth: json['new_customers_this_month'] ?? 0,
    );
  }
}