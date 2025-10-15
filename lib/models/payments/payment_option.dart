// FILE: lib/models/payments/payment_option.dart
class PaymentOption {
  final String id;
  final String name;
  final String? logo; // URL to the logo image
  final bool isActive;

  PaymentOption({
    required this.id,
    required this.name,
    this.logo,
    required this.isActive,
  });

  factory PaymentOption.fromJson(Map<String, dynamic> json) {
    return PaymentOption(
      id: json['id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      isActive:
          json['is_active'] as bool? ??
          false, // Default to false if not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'logo': logo, 'is_active': isActive};
  }
}
