// FILE: /lib/models/payments/payment.dart
/* CRITICAL: DO NOT REMOVE OR ABBREVIATE.
This file must be delivered complete.
Any changes must preserve the exported public API. */

class PendingPayment {
  final String id;
  final String subscriptionId;
  final String passengerId;
  final double amount;
  final String paymentMethod;
  final String transactionReference;
  final String status;
  final String passengerName;
  final String passengerPhone;
  final String passengerEmail;

  PendingPayment({
    required this.id,
    required this.subscriptionId,
    required this.passengerId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionReference,
    required this.status,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerEmail,
  });

  factory PendingPayment.fromJson(Map<String, dynamic> json) {
    // A more robust fromJson factory
    num amount = 0;
    if (json['amount'] is num) {
      amount = json['amount'];
    } else if (json['amount'] is String) {
      amount = double.tryParse(json['amount']) ?? 0.0;
    }

    return PendingPayment(
      id: json['id'] as String? ?? '',
      subscriptionId: json['subscription_id'] as String? ?? '',
      passengerId: json['passenger_id'] as String? ?? '',
      amount: amount.toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'N/A',
      transactionReference: json['transaction_reference'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'PENDING',
      passengerName: json['passenger_name'] as String? ?? 'N/A',
      passengerPhone: json['passenger_phone'] as String? ?? 'N/A',
      passengerEmail: json['passenger_email'] as String? ?? 'N/A',
    );
  }
}
