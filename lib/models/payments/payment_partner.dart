// FILE: lib/models/payments/payment_partner.dart
class PaymentPartner {
  final String id;
  final String name;
  final String? logoUrl;

  PaymentPartner({required this.id, required this.name, this.logoUrl});

  factory PaymentPartner.fromJson(Map<String, dynamic> json) {
    return PaymentPartner(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'logo_url': logoUrl};
  }
}
