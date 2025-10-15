// FILE: lib/models/wallet_transaction.dart
// (Add or update this file)

class WalletTransaction {
  final String id;
  final String type; // e.g., 'CREDIT', 'DEBIT'
  final double amount;
  final String currency;
  final String description;
  final DateTime date; // <--- ADD THIS FIELD
  final String? referenceId; // Optional, e.g., subscription ID, payment ID

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.date, // <--- Add to constructor
    this.referenceId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String), // <--- Parse 'date'
      referenceId: json['reference_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'currency': currency,
      'description': description,
      'date': date.toIso8601String(), // <--- Add to toJson
      'reference_id': referenceId,
    };
  }
}