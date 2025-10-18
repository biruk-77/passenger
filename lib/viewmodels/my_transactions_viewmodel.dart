// FILE: lib/viewmodels/my_transactions_viewmodel.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/wallet_transaction.dart';
import '../utils/api_exception.dart';

// Enums to manage filter states for better readability and type safety
enum TransactionFilterStatus { all, paid, pending }

enum SortOrder { newestFirst, oldestFirst, amountHighest, amountLowest }

class MyTransactionsViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;

  MyTransactionsViewModel(this._apiService, this._authService);

  // --- State Variables ---
  bool _isLoading = false;
  String? _errorMessage;
  List<WalletTransaction> _allTransactions = [];

  // --- Filter State Variables ---
  TransactionFilterStatus _selectedStatus = TransactionFilterStatus.all;
  double? _selectedAmountFilter; // e.g., 500 means amount > 500
  DateTimeRange? _selectedDateRange;
  SortOrder _sortOrder = SortOrder.newestFirst;
  String _walletCurrency = 'ETB'; // Default currency

  // --- Public Getters for UI ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get walletCurrency => _walletCurrency;
  TransactionFilterStatus get selectedStatus => _selectedStatus;
  double? get selectedAmountFilter => _selectedAmountFilter;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  SortOrder get sortOrder => _sortOrder;

  /// Returns true if there are any transactions fetched, regardless of filters.
  bool get hasAnyTransactions => _allTransactions.isNotEmpty;

  /// The main getter for the UI. It applies all active filters to the list.
  List<WalletTransaction> get filteredTransactions {
    List<WalletTransaction> transactions = List.from(_allTransactions);

    // 1. Filter by Status (Paid/Pending)
    if (_selectedStatus == TransactionFilterStatus.paid) {
      transactions = transactions
          .where((t) => t.status == TransactionStatus.completed)
          .toList();
    } else if (_selectedStatus == TransactionFilterStatus.pending) {
      transactions = transactions
          .where((t) => t.status == TransactionStatus.pending)
          .toList();
    }

    // 2. Filter by Amount
    if (_selectedAmountFilter != null) {
      transactions = transactions
          .where((t) => t.amount >= _selectedAmountFilter!)
          .toList();
    }

    // 3. Filter by Date Range
    if (_selectedDateRange != null) {
      transactions = transactions.where((t) {
        // Ensure the transaction date is after the start and before the end of the selected range.
        // We add a day to the end date to make it inclusive of the entire day.
        final isAfterStart = t.createdAt.isAfter(_selectedDateRange!.start);
        final isBeforeEnd = t.createdAt.isBefore(
          _selectedDateRange!.end.add(const Duration(days: 1)),
        );
        return isAfterStart && isBeforeEnd;
      }).toList();
    }

    // 4. Apply Sorting
    transactions.sort((a, b) {
      switch (_sortOrder) {
        case SortOrder.newestFirst:
          return b.createdAt.compareTo(a.createdAt);
        case SortOrder.oldestFirst:
          return a.createdAt.compareTo(b.createdAt);
        case SortOrder.amountHighest:
          return b.amount.compareTo(a.amount);
        case SortOrder.amountLowest:
          return a.amount.compareTo(b.amount);
      }
    });

    return transactions;
  }

  // --- Public Methods to Update State & Data ---

  /// Fetches transactions from the API.
  Future<void> fetchTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // We only fetch transactions now. Wallet balance is not needed on this screen.
      final results = await _apiService.getWalletTransactions();
      _allTransactions = results;

      // Assume currency from the first transaction or default
      if (_allTransactions.isNotEmpty) {
        // A real app might get this from a wallet/profile endpoint.
        // For now, we can keep a default or try to infer it.
        _walletCurrency = 'ETB';
      }
    } on ApiException catch (e) {
      _errorMessage = "Failed to load transactions: ${e.message}";
    } catch (e) {
      _errorMessage = "An unexpected error occurred: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Methods to update filters ---

  void selectStatusFilter(TransactionFilterStatus status) {
    if (_selectedStatus != status) {
      _selectedStatus = status;
      notifyListeners();
    }
  }

  void selectAmountFilter(double? amount) {
    // If the same amount is tapped again, treat it as "clear filter"
    if (_selectedAmountFilter == amount) {
      _selectedAmountFilter = null;
    } else {
      _selectedAmountFilter = amount;
    }
    notifyListeners();
  }

  void selectDateRange(DateTimeRange? range) {
    _selectedDateRange = range;
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void clearAllAdvancedFilters() {
    _selectedDateRange = null;
    _sortOrder = SortOrder.newestFirst;
    notifyListeners();
  }
}
