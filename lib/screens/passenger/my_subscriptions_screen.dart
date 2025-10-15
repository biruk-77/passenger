// lib/screens/passenger/my_subscriptions_screen.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../l10n/app_localizations.dart';
import '../../models/contract/contract_ride.dart';
import '../../models/search_result.dart';
import '../../services/api_service.dart';
import '../../theme/color.dart';
import '../../theme/styles.dart';
import '../home_screen.dart';
import 'subscription_details_screen.dart';

// --- STATE MANAGEMENT ---
enum NotifierState { initial, loading, loaded, error }

class MySubscriptionsProvider with ChangeNotifier {
  final ApiService _apiService;
  MySubscriptionsProvider(this._apiService) {
    fetchSubscriptions();
  }

  NotifierState _state = NotifierState.initial;
  NotifierState get state => _state;
  List<Subscription> _subscriptions = [];
  List<Subscription> get subscriptions => _subscriptions;
  String _error = '';
  String get error => _error;

  Future<void> fetchSubscriptions() async {
    _state = NotifierState.loading;
    notifyListeners();
    try {
      _subscriptions = await _apiService.getMySubscriptions();
      _state = NotifierState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = NotifierState.error;
    }
    notifyListeners();
  }
}

class AvailableContractsProvider with ChangeNotifier {
  final ApiService _apiService;
  AvailableContractsProvider(this._apiService) {
    fetchContracts();
  }

  NotifierState _state = NotifierState.initial;
  NotifierState get state => _state;
  List<Contract> _contracts = [];
  List<Contract> get contracts => _contracts;
  String _error = '';
  String get error => _error;

  Future<void> fetchContracts() async {
    _state = NotifierState.loading;
    notifyListeners();
    try {
      _contracts = await _apiService.getAvailableContracts();
      _state = NotifierState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = NotifierState.error;
    }
    notifyListeners();
  }
}

// --- MAIN SCREEN WIDGET (Redesigned) ---
class MySubscriptionsScreen extends StatelessWidget {
  final int initialTabIndex;

  const MySubscriptionsScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              MySubscriptionsProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AvailableContractsProvider(context.read<ApiService>()),
        ),
      ],
      child: DefaultTabController(
        initialIndex: initialTabIndex,
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.secondaryColor,
          appBar: AppBar(
            title: Text(
              l10n.mySubscriptionsTitle,
              style: AppTextStyles.screenTitle,
            ),
            backgroundColor: AppColors.secondaryColor,
            elevation: 0,
            bottom: TabBar(
              indicatorColor: AppColors.accentGold,
              labelColor: AppColors.accentGold,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: [
                Tab(text: l10n.mySubscriptionsTitle),
                Tab(text: l10n.drawerAvailableContracts),
              ],
            ),
          ),
          body: const TabBarView(
            children: [_MySubscriptionsView(), _AvailableContractsView()],
          ),
        ),
      ),
    );
  }
}

// --- TAB VIEW WIDGETS ---
class _MySubscriptionsView extends StatelessWidget {
  const _MySubscriptionsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<MySubscriptionsProvider>(
      builder: (context, provider, _) {
        switch (provider.state) {
          case NotifierState.loading:
          case NotifierState.initial:
            return _buildLoadingState();
          case NotifierState.error:
            return _ErrorState(
              onRetry: provider.fetchSubscriptions,
              error: provider.error,
            );
          case NotifierState.loaded:
            if (provider.subscriptions.isEmpty) {
              return _EmptyState(
                title: l10n.noSubscriptionsFound,
                message: l10n.contractPanelEmptySubscriptionsSubtitle,
                buttonText: l10n.exploreContracts,
                onButtonPressed: () =>
                    DefaultTabController.of(context).animateTo(1),
              );
            }
            return RefreshIndicator(
              onRefresh: provider.fetchSubscriptions,
              color: AppColors.accentGold,
              backgroundColor: AppColors.cardBackground,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: provider.subscriptions.length,
                itemBuilder: (context, index) {
                  return _MySubscriptionCard(
                        subscription: provider.subscriptions[index],
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (100 * index).ms)
                      .slideY(begin: 0.2);
                },
              ),
            );
        }
      },
    );
  }
}

class _AvailableContractsView extends StatelessWidget {
  const _AvailableContractsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AvailableContractsProvider>(
      builder: (context, provider, _) {
        switch (provider.state) {
          case NotifierState.loading:
          case NotifierState.initial:
            return _buildLoadingState();
          case NotifierState.error:
            return _ErrorState(
              onRetry: provider.fetchContracts,
              error: provider.error,
            );
          case NotifierState.loaded:
            if (provider.contracts.isEmpty) {
              return _EmptyState(
                title: l10n.contractPanelEmptyContracts,
                message: l10n.contractPanelEmptyContractsSubtitle,
                buttonText: l10n.refresh,
                onButtonPressed: provider.fetchContracts,
              );
            }
            return RefreshIndicator(
              onRefresh: provider.fetchContracts,
              color: AppColors.accentGold,
              backgroundColor: AppColors.cardBackground,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: provider.contracts.length,
                itemBuilder: (context, index) {
                  return _ContractCard(contract: provider.contracts[index])
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (100 * index).ms)
                      .slideY(begin: 0.2);
                },
              ),
            );
        }
      },
    );
  }
}

// --- UI HELPER WIDGETS ---
Widget _buildLoadingState() {
  return Shimmer.fromColors(
    baseColor: AppColors.primaryColor,
    highlightColor: AppColors.accentColor,
    child: ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final String error;
  const _ErrorState({required this.onRetry, required this.error});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: AppColors.error, size: 80),
            const SizedBox(height: 20),
            Text(l10n.historyErrorTitle, style: AppTextStyles.cardTitle),
            const SizedBox(height: 10),
            Text(
              error,
              style: AppTextStyles.cardSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.retry, style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const _EmptyState({
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              color: AppColors.textSecondary,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.cardTitle),
            const SizedBox(height: 10),
            Text(
              message,
              style: AppTextStyles.cardSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onButtonPressed,
              child: Text(buttonText, style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}

class _StatusTag extends StatelessWidget {
  final String status;
  const _StatusTag({required this.status});

  (Color, IconData) _getStatusStyle(AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return (AppColors.statusActive, Icons.check_circle);
      case 'PENDING':
        return (AppColors.statusPending, Icons.hourglass_top_rounded);
      default:
        return (AppColors.statusError, Icons.cancel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (color, icon) = _getStatusStyle(l10n);
    String statusText;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        statusText = l10n.statusActive;
        break;
      case 'PENDING':
        statusText = l10n.statusPending;
        break;
      default:
        statusText = l10n.statusInactive;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
// REPLACE THE OLD _ContractCard AND _FeatureChip WIDGETS WITH THESE

class _ContractCard extends StatelessWidget {
  final Contract contract;
  const _ContractCard({required this.contract});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Map<String, bool> features = {};
    if (contract.features != null) {
      try {
        final decoded = json.decode(contract.features!);
        if (decoded is Map) {
          features = decoded.map(
            (key, value) => MapEntry(key, value as bool? ?? false),
          );
        }
      } catch (e) {
        // Silently ignore errors
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              initialRoute: SearchResult.forContractCreation(
                contractId: contract.id,
                contractType: contract.contractType,
              ),
            ),
          ),
          (route) => false,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contract.contractType,
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 20),
                      ),
                      if (contract.description != null &&
                          contract.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          contract.description!,
                          style: AppTextStyles.cardSubtitle.copyWith(
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (contract.discountPercentage > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.goldenrod,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.contractPanelDiscountOff(
                        contract.discountPercentage.toInt().toString(),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.sell_outlined,
              l10n.basePrice, // ✅ LOCALIZED
              "${contract.basePricePerKm.toStringAsFixed(2)} / km",
            ),
            _buildDetailRow(
              Icons.payments_outlined,
              l10n.minimumFare, // ✅ LOCALIZED
              contract.minimumFare.toStringAsFixed(2),
            ),
            _buildDetailRow(
              Icons.people_alt_outlined,
              l10n.maxPassengers, // ✅ LOCALIZED
              contract.maximumPassengers.toString(),
            ),
            if (features.isNotEmpty) ...[
              const Divider(color: Colors.white24, height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (features['wifi'] == true)
                    _FeatureChip(
                      icon: Icons.wifi,
                      label: l10n.featureWifi,
                    ), // ✅ LOCALIZED
                  if (features['ac'] == true)
                    _FeatureChip(
                      icon: Icons.ac_unit,
                      label: l10n.featureAC,
                    ), // ✅ LOCALIZED
                  if (features['premium_seats'] == true)
                    _FeatureChip(
                      icon: Icons.chair_alt_outlined,
                      label: l10n.featurePremiumSeats, // ✅ LOCALIZED
                    ),
                  if (features['priority_support'] == true)
                    _FeatureChip(
                      icon: Icons.support_agent,
                      label: l10n.featurePrioritySupport, // ✅ LOCALIZED
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSubtle, size: 18),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(color: AppColors.textSubtle, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
class _MySubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  const _MySubscriptionCard({required this.subscription});

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat('MMM d, yyyy').format(date) : 'N/A';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Material(
            color: AppColors.primaryColor.withOpacity(0.5),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        SubscriptionDetailsScreen(subscription: subscription),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            subscription.contractType.isNotEmpty &&
                                    subscription.contractType != 'N/A'
                                ? subscription.contractType
                                : l10n.rideSubscriptionFallbackTitle,
                            style: AppTextStyles.cardTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusTag(status: subscription.status),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _RouteDisplay(
                      from: subscription.pickupLocation,
                      to: subscription.dropoffLocation,
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DetailItem(
                          title: l10n.duration.toUpperCase(),
                          value:
                              '${_formatDate(subscription.startDate)} - ${_formatDate(subscription.endDate)}',
                        ),
                        _DetailItem(
                          title: l10n.cost.toUpperCase(),
                          value:
                              'ETB ${subscription.finalFare.toStringAsFixed(2)}',
                          valueColor: AppColors.accentGold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteDisplay extends StatelessWidget {
  final String from;
  final String to;
  const _RouteDisplay({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            const Icon(Icons.my_location, color: AppColors.info, size: 20),
            Container(height: 30, width: 1, color: Colors.white30),
            const Icon(Icons.flag, color: AppColors.success, size: 20),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                from,
                style: AppTextStyles.cardSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Text(
                to,
                style: AppTextStyles.cardSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  const _DetailItem({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSubtle,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
