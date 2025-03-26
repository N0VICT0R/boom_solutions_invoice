class PartnerList {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final dynamic phone;
  final dynamic mobile;

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
      id: json['id'] ?? 0,
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
