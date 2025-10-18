// FILE: lib/screens/my_transactions/my_transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';

// Import your custom theme files
import '../../theme/color.dart';
import '../../theme/styles.dart';

import '../../viewmodels/my_transactions_viewmodel.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/wallet_transaction.dart';

class MyTransactionsScreen extends StatefulWidget {
  const MyTransactionsScreen({super.key});

  @override
  State<MyTransactionsScreen> createState() => _MyTransactionsScreenState();
}

class _MyTransactionsScreenState extends State<MyTransactionsScreen>
    with TickerProviderStateMixin {
  late MyTransactionsViewModel _viewModel;
  late final AnimationController _gradientController;
  late final AnimationController _burstController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Animation controllers for the background
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _burstController.forward();
      }
    });

    // Tab controller for status filtering
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final newStatus = TransactionFilterStatus.values[_tabController.index];
        _viewModel.selectStatusFilter(newStatus);
      }
    });

    _viewModel = MyTransactionsViewModel(
      Provider.of<ApiService>(context, listen: false),
      Provider.of<AuthService>(context, listen: false),
    );
    _viewModel.fetchTransactions();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _burstController.dispose();
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String _getLocalizedTransactionStatus(
    BuildContext context,
    TransactionStatus status,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case TransactionStatus.completed:
        return l10n.transactionStatusCompleted;
      case TransactionStatus.pending:
        return l10n.transactionStatusPending;
      case TransactionStatus.failed:
        return l10n.transactionStatusFailed;
      default:
        return '';
    }
  }

  void _showAdvancedFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final viewModel = Provider.of<MyTransactionsViewModel>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        // Use a stateful builder to manage the local state of the bottom sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Wrap(
                runSpacing: 16,
                children: [
                  // Title and Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.moreFilters,
                        style: theme.textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),

                  // Date Range Filter
                  ListTile(
                    leading: const Icon(Icons.date_range_outlined),
                    title: Text(l10n.dateRange),
                    subtitle: Text(
                      viewModel.selectedDateRange == null
                          ? l10n.anyDate
                          : '${DateFormat.yMMMd().format(viewModel.selectedDateRange!.start)} - ${DateFormat.yMMMd().format(viewModel.selectedDateRange!.end)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final pickedRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: viewModel.selectedDateRange,
                      );
                      if (pickedRange != null) {
                        setModalState(() {
                          viewModel.selectDateRange(pickedRange);
                        });
                      }
                    },
                  ),

                  // Sort Order Filter
                  ListTile(
                    leading: const Icon(Icons.sort_by_alpha_outlined),
                    title: Text(l10n.sortBy),
                    trailing: DropdownButton<SortOrder>(
                      value: viewModel.sortOrder,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: SortOrder.newestFirst,
                          child: Text(l10n.sortNewestFirst),
                        ),
                        DropdownMenuItem(
                          value: SortOrder.oldestFirst,
                          child: Text(l10n.sortOldestFirst),
                        ),
                        DropdownMenuItem(
                          value: SortOrder.amountHighest,
                          child: Text(l10n.sortAmountHighest),
                        ),
                        DropdownMenuItem(
                          value: SortOrder.amountLowest,
                          child: Text(l10n.sortAmountLowest),
                        ),
                      ],
                      onChanged: (SortOrder? newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            viewModel.setSortOrder(newValue);
                          });
                        }
                      },
                    ),
                  ),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            viewModel.clearAllAdvancedFilters();
                          });
                        },
                        child: Text(l10n.clear),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.applyFilters),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ChangeNotifierProvider<MyTransactionsViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(l10n.myTransactions),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: theme.colorScheme.onSurface,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list_rounded),
              onPressed: () => _showAdvancedFilters(context),
              tooltip: l10n.moreFilters,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.all),
              Tab(text: l10n.paid),
              Tab(text: l10n.pending),
            ],
          ),
        ),
        body: Stack(
          children: [
            _buildAnimatedGradientBackground(),
            _buildCornerBurstEffect(),
            Consumer<MyTransactionsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null) {
                  return _buildErrorState(l10n, theme, viewModel);
                }

                return RefreshIndicator(
                  onRefresh: viewModel.fetchTransactions,
                  child: Column(
                    children: [
                      // Space for AppBar and TabBar
                      SizedBox(
                        height:
                            kToolbarHeight +
                            kTextTabBarHeight +
                            MediaQuery.of(context).padding.top,
                      ),

                      // Amount Filters
                      _buildAmountFilters(viewModel),

                      // Transaction List
                      Expanded(
                        child: _buildTransactionList(viewModel, l10n, theme),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountFilters(MyTransactionsViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    final amounts = [500.0, 1000.0, 5000.0, 10000.0];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: amounts.map((amount) {
          final isSelected = viewModel.selectedAmountFilter == amount;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(
                '${l10n.above} ${NumberFormat('#,##0').format(amount)}',
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                viewModel.selectAmountFilter(amount);
              },
              selectedColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList(
    MyTransactionsViewModel viewModel,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (!viewModel.hasAnyTransactions) {
      return _buildEmptyState(l10n, theme, isFilterRelated: false);
    }
    if (viewModel.filteredTransactions.isEmpty) {
      return _buildEmptyState(l10n, theme, isFilterRelated: true);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: viewModel.filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = viewModel.filteredTransactions[index];
        bool isCredit =
            transaction.type == TransactionType.topup ||
            transaction.type == TransactionType.refund;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
          elevation: 0,
          color: theme.colorScheme.surface.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionTile(
            shape: const Border(), // Remove default border on expansion
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: isCredit
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              child: Icon(
                isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                color: isCredit ? AppColors.success : AppColors.error,
              ),
            ),
            title: Text(
              transaction.description,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              DateFormat('MMM dd, yyyy').format(transaction.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'} ${viewModel.walletCurrency} ${transaction.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isCredit
                        ? AppColors.success
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStatusBadge(transaction.status, theme),
              ],
            ),
            children: [_buildTransactionDetails(transaction, theme, l10n)],
          ),
        ).animate().fadeIn(delay: (100 * (index % 10)).ms).slideX(begin: -0.1);
      },
    );
  }

  Widget _buildTransactionDetails(
    WalletTransaction transaction,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 20),
          _detailRow(l10n.transactionID, transaction.id, theme),
          _detailRow(l10n.paymentMethod, transaction.paymentMethod, theme),
          if (transaction.bookingId != null)
            _detailRow(l10n.bookingID, transaction.bookingId!, theme),
          _detailRow(
            l10n.date,
            DateFormat('MMM dd, yyyy HH:mm:ss').format(transaction.createdAt),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Container _buildStatusBadge(TransactionStatus status, ThemeData theme) {
    Color color;
    Color bgColor;
    switch (status) {
      case TransactionStatus.completed:
        color = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.1);
        break;
      case TransactionStatus.pending:
        color = AppColors.warning;
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        break;
      default:
        color = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.1);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getLocalizedTransactionStatus(context, status),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    AppLocalizations l10n,
    ThemeData theme, {
    required bool isFilterRelated,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFilterRelated
                ? Icons.filter_alt_off_outlined
                : Icons.receipt_long_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            isFilterRelated
                ? l10n.noMatchingTransactions
                : l10n.noTransactionsYet,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            isFilterRelated
                ? l10n.tryAdjustingFilters
                : l10n.yourRecentTransactionsWillAppearHere,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    AppLocalizations l10n,
    ThemeData theme,
    MyTransactionsViewModel viewModel,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 50),
            const SizedBox(height: 10),
            Text(
              '${l10n.errorPrefix}: ${viewModel.errorMessage}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: viewModel.fetchTransactions,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets for animated background (unchanged)
  Widget _buildAnimatedGradientBackground() {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                -1.0 + (_gradientController.value * 2),
                1.0 - (_gradientController.value * 2),
              ),
              radius: 1.5,
              colors: [
                theme.colorScheme.secondary.withValues(alpha: 0.7),
                theme.scaffoldBackgroundColor,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCornerBurstEffect() {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _burstController,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: _burstController,
          curve: Curves.easeOutCubic,
        );
        return ClipPath(
          clipper: _CircleClipper(
            radius: animation.value * MediaQuery.of(context).size.width * 1.5,
            position: const Offset(double.infinity, 0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  theme.colorScheme.secondary.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
                center: const Alignment(1.0, -1.0),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom clipper class (unchanged)
class _CircleClipper extends CustomClipper<Path> {
  final double radius;
  final Offset position;
  _CircleClipper({required this.radius, required this.position});
  @override
  Path getClip(Size size) {
    final path = Path();
    final effectivePosition = Offset(
      position.dx.isInfinite ? size.width : position.dx,
      position.dy,
    );
    path.addOval(Rect.fromCircle(center: effectivePosition, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
