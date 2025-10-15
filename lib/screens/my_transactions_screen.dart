import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // ✅ IMPORT ADDED
import 'package:flutter_animate/flutter_animate.dart'; // ✅ IMPORT ADDED

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
  // ✅ ADDED TickerProviderStateMixin
  late MyTransactionsViewModel _viewModel;
  // ✅ ADDED: Animation controllers for the new background
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    // ✅ INITIALIZED: New background controllers
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

    // This ViewModel will call apiService.getWalletTransactions(), which correctly
    // hits the GET /wallet/transactions endpoint.
    _viewModel = MyTransactionsViewModel(
      Provider.of<ApiService>(context, listen: false),
      Provider.of<AuthService>(context, listen: false),
    );
    _viewModel.fetchTransactions();
  }

  @override
  void dispose() {
    // ✅ DISPOSED: New background controllers
    _gradientController.dispose();
    _burstController.dispose();
    _viewModel.dispose(); // Also dispose the view model to clean up listeners
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ChangeNotifierProvider<MyTransactionsViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        // ✅ REFACTORED: Background is now transparent to allow Stack to be visible
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true, // Let body go behind the AppBar
        appBar: AppBar(
          title: Text(l10n.myTransactions),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: theme.colorScheme.onBackground,
        ),
        body: Stack(
          children: [
            // ✅ ADDED: New animated background layers
            _buildAnimatedGradientBackground(),
            _buildCornerBurstEffect(),

            // Original Body Content
            Consumer<MyTransactionsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                            size: 50,
                          ),
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

                return RefreshIndicator(
                  onRefresh: viewModel.fetchTransactions,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pushed down by AppBar height + padding
                      SizedBox(
                        height:
                            kToolbarHeight + MediaQuery.of(context).padding.top,
                      ),

                      // Transaction Header with Count
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.transactionHistory,
                              style: theme.textTheme.headlineSmall,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${viewModel.transactions.length} ${viewModel.transactions.length == 1 ? 'transaction' : 'transactions'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            _buildFilterChip(
                              context,
                              label: 'All',
                              count: viewModel.allCount,
                              isSelected: viewModel.selectedFilter == null,
                              onTap: () => viewModel.clearFilter(),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              context,
                              label: 'Pending',
                              count: viewModel.pendingCount,
                              isSelected: viewModel.selectedFilter ==
                                  TransactionStatus.pending,
                              onTap: () => viewModel
                                  .setFilter(TransactionStatus.pending),
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              context,
                              label: 'Completed',
                              count: viewModel.completedCount,
                              isSelected: viewModel.selectedFilter ==
                                  TransactionStatus.completed,
                              onTap: () => viewModel
                                  .setFilter(TransactionStatus.completed),
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              context,
                              label: 'Failed',
                              count: viewModel.failedCount,
                              isSelected: viewModel.selectedFilter ==
                                  TransactionStatus.failed,
                              onTap: () =>
                                  viewModel.setFilter(TransactionStatus.failed),
                              color: AppColors.error,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: viewModel.transactions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 80,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.2),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.noTransactionsYet,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.yourRecentTransactionsWillAppearHere,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.5),
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: viewModel.transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction =
                                      viewModel.transactions[index];
                                  bool isCredit =
                                      transaction.type ==
                                          TransactionType.topup ||
                                      transaction.type ==
                                          TransactionType.refund;

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                      horizontal: 16.0,
                                    ),
                                    elevation: 0,
                                    color: theme.colorScheme.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      leading: CircleAvatar(
                                        backgroundColor: isCredit
                                            ? AppColors.success.withOpacity(0.1)
                                            : AppColors.error.withOpacity(0.1),
                                        child: Icon(
                                          isCredit
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          color: isCredit
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                      ),
                                      title: Text(
                                        transaction.description,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      subtitle: Text(
                                        DateFormat(
                                          'MMM dd, yyyy HH:mm',
                                        ).format(transaction.createdAt),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.7),
                                            ),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${isCredit ? '+' : '-'} ETB ${transaction.amount.toStringAsFixed(2)}',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  color: isCredit
                                                      ? AppColors.success
                                                      : theme
                                                            .colorScheme
                                                            .onSurface,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  transaction.status ==
                                                      TransactionStatus
                                                          .completed
                                                  ? AppColors.success
                                                        .withOpacity(0.1)
                                                  : transaction.status ==
                                                        TransactionStatus
                                                            .pending
                                                  ? AppColors.warning
                                                        .withOpacity(0.1)
                                                  : AppColors.error.withOpacity(
                                                      0.1,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _getLocalizedTransactionStatus(
                                                context,
                                                transaction.status,
                                              ),
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color:
                                                        transaction.status ==
                                                            TransactionStatus
                                                                .completed
                                                        ? AppColors.success
                                                        : transaction.status ==
                                                              TransactionStatus
                                                                  .pending
                                                        ? AppColors.warning
                                                        : AppColors.error,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
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

  // ✅ HELPER WIDGET FOR FILTER CHIPS
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final chipColor = color ?? AppColors.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withOpacity(0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? chipColor : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? chipColor
                    : theme.colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ HELPER WIDGETS FOR ANIMATED BACKGROUND
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
                theme.colorScheme.secondary.withOpacity(0.7),
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
                  theme.colorScheme.primary.withOpacity(0.3),
                  theme.colorScheme.secondary.withOpacity(0.2),
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

// ✅ CUSTOM CLIPPER CLASS FOR CORNER BURST EFFECT
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
