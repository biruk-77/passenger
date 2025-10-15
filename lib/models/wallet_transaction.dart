// lib/models/wallet_transaction.dart

import 'package:flutter/foundation.dart';

/// An enum to represent the type of a wallet transaction.
enum TransactionType {
  topup,
  withdrawal,
  payment,
  refund,
  unknown,
  debit,
  credit,
}

/// An enum to represent the status of a wallet transaction.
enum TransactionStatus { pending, completed, failed, cancelled }

/// A data model representing a single transaction in a user's wallet.
@immutable
class WalletTransaction {
  /// The unique identifier for the transaction.
  final String id;

  /// The amount of the transaction.
  final double amount;

  /// The type of transaction (e.g., topup, payment).
  final TransactionType type;

  /// The status of the transaction (e.g., pending, completed).
  final TransactionStatus status;

  /// A human-readable description or reason for the transaction.
  final String description;

  /// The date and time when the transaction occurred.
  final DateTime createdAt;

  /// Optional reference to a booking ID if the transaction is a ride payment.
  final String? bookingId;

  /// The payment method used for the transaction (e.g., "Telebirr", "Wallet Balance").
  final String paymentMethod;

  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    required this.createdAt,
    this.bookingId,
    required this.paymentMethod,
  });

  /// Creates a [WalletTransaction] instance from a JSON map.
  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    // Helper to safely extract description from metadata
    String _getDescription(Map<String, dynamic> jsonData) {
      if (jsonData['metadata'] is Map &&
          jsonData['metadata']['reason'] != null) {
        return jsonData['metadata']['reason'] as String;
      }
      return 'Wallet Transaction'; // Fallback description
    }

    // ✅ FIX: This new helper function can parse an amount whether it's a
    // String ("50.00") or a number (50.00). This solves the crash.
    double _parseAmount(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return WalletTransaction(
      // Safely convert ID to string regardless of its original type (num or string)
      id: json['id']?.toString() ?? '0',

      // Use our new robust parsing function for the amount.
      amount: _parseAmount(json['amount']),

      description: _getDescription(json),
      bookingId: json['bookingId'] as String?,
      paymentMethod: json['method'] as String? ?? 'N/A',
      type: _parseTransactionType(json['type'] as String?),
      status: _parseTransactionStatus(json['status'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static TransactionType _parseTransactionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'topup':
      case 'credit': // Treat 'credit' as a top-up
        return TransactionType.topup;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'payment':
      case 'debit': // Treat 'debit' as a payment
        return TransactionType.payment;
      case 'refund':
        return TransactionType.refund;
      default:
        return TransactionType.unknown;
    }
  }

  static TransactionStatus _parseTransactionStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
      case 'success':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  @override
  String toString() {
    return 'WalletTransaction(id: $id, amount: $amount, type: $type, status: $status, createdAt: $createdAt)';
  }
}
