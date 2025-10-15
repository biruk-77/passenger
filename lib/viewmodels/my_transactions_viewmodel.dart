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

  List<WalletTransaction> _allTransactions = [];
  TransactionStatus? _selectedFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TransactionStatus? get selectedFilter => _selectedFilter;

  // Filter transactions based on selected status
  List<WalletTransaction> get transactions {
    if (_selectedFilter == null) {
      return _allTransactions;
    }
    return _allTransactions
        .where((transaction) => transaction.status == _selectedFilter)
        .toList();
  }

  // Get transaction counts for each status
  int get allCount => _allTransactions.length;
  int get pendingCount => _allTransactions
      .where((t) => t.status == TransactionStatus.pending)
      .length;
  int get completedCount => _allTransactions
      .where((t) => t.status == TransactionStatus.completed)
      .length;
  int get failedCount => _allTransactions
      .where((t) => t.status == TransactionStatus.failed)
      .length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Set filter for transactions
  void setFilter(TransactionStatus? status) {
    _selectedFilter = status;
    notifyListeners();
  }

  // Clear filter
  void clearFilter() {
    _selectedFilter = null;
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _setLoading(true);
    setErrorMessage(null);
    try {
      _allTransactions = await _apiService.getWalletTransactions();
      _allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on ApiException catch (e) {
      setErrorMessage("Failed to load transactions: ${e.message}");
    } catch (e) {
      setErrorMessage("An unexpected error occurred: $e");
    } finally {
      _setLoading(false);
    }
  }
}
