// lib/services/api_service.dart
import 'package:boom_solutions_invoice/models/partner_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ApiService {
  static const String baseUrl = 'http://137.184.205.67:2710/';
  static const String apiToken = 'VKwmwcRzwAIY9ef6A7Gp2qBOISwwPCke';
  static const int partnerId = 10;

  Future<PartnerStatement> fetchPartnerStatement() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/partners/$partnerId/statement?api_token=$apiToken'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final Partner partner = Partner.fromJson(data['partner']);
      final Statement statement = Statement.fromJson(data['statement']);
      return PartnerStatement(partner: partner, statement: statement);
    } else {
      throw Exception('Failed to load partner statement');
    }
  }
}

class PartnerStatement {
  final Partner partner;
  final Statement statement;

  PartnerStatement({required this.partner, required this.statement});
}