// lib/screens/passenger/available_contracts_screen.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/contract/contract_ride.dart';
import '../../services/api_service.dart';
import '../../theme/color.dart';
import '../../theme/styles.dart';

class AvailableContractsScreen extends StatefulWidget {
  const AvailableContractsScreen({super.key});

  @override
  State<AvailableContractsScreen> createState() =>
      _AvailableContractsScreenState();
}

class _AvailableContractsScreenState extends State<AvailableContractsScreen>
    with TickerProviderStateMixin {
  // ✅ ADDED TickerProviderStateMixin
  late Future<List<Contract>> _contractsFuture;
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

    // --- Existing logic (UNCHANGED) ---
    _fetchAvailableContracts();
  }

  @override
  void dispose() {
    // ✅ DISPOSED: New background controllers
    _gradientController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  void _fetchAvailableContracts() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      _contractsFuture = apiService.getAvailableContracts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.availableContractsTitle),
        backgroundColor: Colors.transparent, // ✅ Made transparent
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        // ✅ WRAPPED in a Stack for the new background
        children: [
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),
          SafeArea(
            child: FutureBuilder<List<Contract>>(
              future: _contractsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _buildErrorState();
                }
                final contracts = snapshot.data;
                if (contracts == null || contracts.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: contracts.length,
                  itemBuilder: (context, index) {
                    return _ContractCard(contract: contracts[index])
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (100 * index).ms)
                        .slideY(begin: 0.2, curve: Curves.easeOut);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            color: theme.colorScheme.secondary,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noContractsAvailableTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              l10n.noContractsAvailableMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: theme.colorScheme.secondary,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.failedToLoadContractsTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              l10n.failedToLoadContractsMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _fetchAvailableContracts,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  // ✅ HELPER WIDGETS COPIED FROM TEMPLATE
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

class _ContractCard extends StatelessWidget {
  final Contract contract;
  const _ContractCard({required this.contract});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      symbol: 'ETB ',
      decimalDigits: 2,
      locale: 'en',
    );

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
        /* Ignore parsing errors */
      }
    }

    return Card(
      color: theme.colorScheme.surface.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    contract.contractType,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (contract.discountPercentage > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${contract.discountPercentage.toInt()}% ${l10n.discount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
            if (contract.description != null &&
                contract.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                contract.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            Divider(color: theme.dividerColor, height: 32),
            _buildInfoChip(
              context: context,
              icon: Icons.speed_outlined,
              label: l10n.baseRate,
              value: '${currencyFormat.format(contract.basePricePerKm)}/km',
            ),
            const SizedBox(height: 12),
            _buildInfoChip(
              context: context,
              icon: Icons.savings_outlined,
              label: l10n.minimumFare,
              value: currencyFormat.format(contract.minimumFare),
            ),
            const SizedBox(height: 12),
            _buildInfoChip(
              context: context,
              icon: Icons.people_alt_outlined,
              label: l10n.maxPassengers,
              value: contract.maximumPassengers.toString(),
            ),
            if (features.isNotEmpty) ...[
              Divider(color: theme.dividerColor, height: 32),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (features['wifi'] == true)
                    _FeatureChip(icon: Icons.wifi, label: l10n.featureWifi),
                  if (features['ac'] == true)
                    _FeatureChip(icon: Icons.ac_unit, label: l10n.featureAC),
                  if (features['premium_seats'] == true)
                    _FeatureChip(
                      icon: Icons.chair_alt_outlined,
                      label: l10n.featurePremiumSeats,
                    ),
                  if (features['priority_support'] == true)
                    _FeatureChip(
                      icon: Icons.support_agent,
                      label: l10n.featurePrioritySupport,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(contract);
                },
                icon: const Icon(Icons.add_road_rounded),
                label: Text(l10n.selectAndPickRoute),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: theme.colorScheme.secondary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ CUSTOM CLIPPER CLASS COPIED FROM TEMPLATE
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
