// FILE: lib/viewmodels/my_transactions_viewmodel.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/wallet_transaction.dart';
import '../utils/api_exception.dart';

class MyTransactionsViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;

  MyTransactionsViewModel(this._apiService, this._authService);

  bool _isLoading = false;
  String? _errorMessage;

  // ============================ FIX STARTS HERE ===========================
  // Change from a double to a Map to hold the full wallet data.
  Map<String, dynamic> _walletData = {'balance': 0.0, 'currency': '...'};
  // ============================= FIX ENDS HERE ============================

  List<WalletTransaction> _transactions = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ============================ FIX STARTS HERE ===========================
  // Create getters for easier UI access.
  double get walletBalance =>
      (_walletData['balance'] as num?)?.toDouble() ?? 0.0;
  String get walletCurrency => _walletData['currency'] as String? ?? 'ETB';
  // ============================= FIX ENDS HERE ============================

  List<WalletTransaction> get transactions => _transactions;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchTransactionsAndBalance() async {
    _setLoading(true);
    setErrorMessage(null);
    try {
      // Use Future.wait to fetch both pieces of data concurrently for better performance.
      final results = await Future.wait([
        _apiService.getPassengerWalletBalance(),
        _apiService.getWalletTransactions(),
      ]);

      // ============================ FIX STARTS HERE ===========================
      // Assign the results to the correct variables.
      _walletData = results[0] as Map<String, dynamic>;
      _transactions = results[1] as List<WalletTransaction>;
      // ============================= FIX ENDS HERE ============================

      _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on ApiException catch (e) {
      setErrorMessage("Failed to load data: ${e.message}");
    } catch (e) {
      setErrorMessage("An unexpected error occurred: $e");
    } finally {
      _setLoading(false);
    }
  }
}
