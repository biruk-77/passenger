// FILE: /lib/widgets/home_screen_panels/contract_mode_panel.dart
// ⚠️ AUTO-GENERATED FILE — DO NOT REMOVE HEADER
// Created by AI Artistic Flutter System — Premium Contract Edition

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/app_localizations.dart'; // Import localization
import '../../models/contract/contract_ride.dart';
import '../../services/api_service.dart';
import '../../theme/color.dart'; // IMPORTED FOR THEME COLORS
import '../../utils/logger.dart';

// --- PREMIUM DESIGN SYSTEM (EXACT MATCH) ---
// LOCAL COLOR CONSTANTS REMOVED TO USE THEME SYSTEM
const String _primaryFont =
    'Inter'; // Ensure you have this font in pubspec.yaml
const String _headingFont =
    'PlayfairDisplay'; // Ensure you have this font in pubspec.yaml

class ContractModePanel extends StatefulWidget {
  final Function(Subscription) onSubscriptionSelected;
  final VoidCallback onCancel;
  final Function(Contract) onSelectNewContractType;
  final VoidCallback onCreateNewSubscription;

  const ContractModePanel({
    super.key,
    required this.onSubscriptionSelected,
    required this.onCancel,
    required this.onSelectNewContractType,
    required this.onCreateNewSubscription,
  });

  @override
  State<ContractModePanel> createState() => _ContractModePanelState();
}

class _ContractModePanelState extends State<ContractModePanel>
    with TickerProviderStateMixin {
  Future<List<Subscription>>? _mySubscriptionsFuture;
  Future<List<Contract>>? _availableContractsFuture;
  static const String _logSource = "ContractModePanel";

  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchData();
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  void _fetchData() {
    Logger.info(_logSource, "Fetching premium contract data...");
    final apiService = Provider.of<ApiService>(context, listen: false);

    setState(() {
      _mySubscriptionsFuture = apiService
          .getMySubscriptions()
          .then((subs) {
            final activeSubs = subs
                .where((s) => s.status.toUpperCase() == 'ACTIVE')
                .toList();
            Logger.success(
              _logSource,
              "Found ${activeSubs.length} active subscriptions",
            );
            return activeSubs;
          })
          .catchError((error, stackTrace) {
            Logger.error(
              _logSource,
              "Subscription fetch failed",
              error,
              stackTrace,
            );
            throw error;
          });

      _availableContractsFuture = apiService
          .getAvailableContracts()
          .then((contracts) {
            Logger.success(
              _logSource,
              "Loaded ${contracts.length} contract types",
            );
            return contracts;
          })
          .catchError((error, stackTrace) {
            Logger.error(
              _logSource,
              "Contract fetch failed",
              error,
              stackTrace,
            );
            throw error;
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      child: Stack(
        children: [
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),
          Column(
            children: [
              _buildPremiumHeader(),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(24.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildActiveSubscriptionsSection(),
                          const SizedBox(height: 32),
                          _buildDivider(),
                          const SizedBox(height: 32),
                          _buildAvailableContractsSection(),
                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 16.0, 16.0),
          decoration: BoxDecoration(
            // CORRECTED: Using theme colors
            color: AppColors.cardBackground.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(color: AppColors.goldenrod.withOpacity(0.2)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.contractPanelTitle,
                    style: const TextStyle(
                      fontFamily: _headingFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 28,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                  const SizedBox(height: 4),
                  Text(
                    l10n.contractPanelSubtitle,
                    style: const TextStyle(
                      fontFamily: _primaryFont,
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                ],
              ),
              Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      // CORRECTED: Using theme colors
                      border: Border.all(
                        color: AppColors.goldenrod.withOpacity(0.3),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Logger.info(
                          _logSource,
                          "User closed premium contract panel",
                        );
                        widget.onCancel();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        // CORRECTED: Using theme colors
                        color: AppColors.goldenrod,
                        size: 24,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.5, 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionsSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          title: l10n.contractPanelActiveSubscriptionsTitle,
          subtitle: l10n.contractPanelActiveSubscriptionsSubtitle,
          icon: Icons.verified_rounded,
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<Subscription>>(
          future: _mySubscriptionsFuture,
          builder: (context, subsSnapshot) {
            if (subsSnapshot.connectionState == ConnectionState.waiting) {
              return _buildPremiumShimmer(count: 2, height: 100);
            }
            if (subsSnapshot.hasError) {
              return _buildPremiumErrorState(
                message: l10n.contractPanelErrorLoadSubscriptions,
                onRetry: _fetchData,
              );
            }
            if (!subsSnapshot.hasData || subsSnapshot.data!.isEmpty) {
              return _buildPremiumEmptyState(
                message: l10n.contractPanelEmptySubscriptions,
                subtitle: l10n.contractPanelEmptySubscriptionsSubtitle,
                icon: Icons.subscriptions_rounded,
              );
            }

            return FutureBuilder<List<Contract>>(
              future: _availableContractsFuture,
              builder: (context, contractsSnapshot) {
                final availableContracts = contractsSnapshot.data ?? [];
                return Column(
                  children: subsSnapshot.data!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final subscription = entry.value;
                    final contract = availableContracts.firstWhere(
                      (c) => c.id == subscription.contractTypeId,
                      orElse: () => Contract(
                        id: '',
                        contractTypeId: subscription.contractTypeId ?? '',
                        name: subscription.contractType,
                        contractType: subscription.contractType,
                        status: subscription.status,
                        discountPercentage: 0,
                        basePricePerKm: 0,
                        minimumFare: 0,
                        maximumPassengers: 0,
                        description: '',
                        features: null,
                      ),
                    );

                    return _PremiumSubscriptionCard(
                      subscription: subscription,
                      contractName: contract.contractType,
                      delay: (200 + index * 120).ms,
                      onTap: () {
                        Logger.info(
                          _logSource,
                          "Selected premium subscription: ${contract.contractType}",
                        );
                        widget.onSubscriptionSelected(subscription);
                      },
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvailableContractsSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          title: l10n.contractPanelNewContractsTitle,
          subtitle: l10n.contractPanelNewContractsSubtitle,
          icon: Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<Contract>>(
          future: _availableContractsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildPremiumShimmer(count: 2, height: 200);
            }
            if (snapshot.hasError) {
              return _buildPremiumErrorState(
                message: l10n.contractPanelErrorLoadContracts,
                onRetry: _fetchData,
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildPremiumEmptyState(
                message: l10n.contractPanelEmptyContracts,
                subtitle: l10n.contractPanelEmptyContractsSubtitle,
                icon: Icons.business_center_rounded,
              );
            }

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: snapshot.data!.asMap().entries.map((entry) {
                final index = entry.key;
                final contract = entry.value;
                final cardWidth =
                    (MediaQuery.of(context).size.width - 24 * 2 - 16) / 2;

                return _PremiumContractCard(
                  width: cardWidth,
                  contract: contract,
                  delay: (400 + index * 150).ms,
                  onTap: () {
                    Logger.info(
                      _logSource,
                      "Selected new contract: ${contract.contractType}",
                    );
                    widget.onSelectNewContractType(contract);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // CORRECTED: Using theme colors
            color: AppColors.goldenrod.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.goldenrod.withOpacity(0.3)),
          ),
          // CORRECTED: Using theme colors
          child: Icon(icon, color: AppColors.goldenrod, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: _headingFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: _primaryFont,
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2);
  }

  Widget _buildPremiumShimmer({required int count, required double height}) {
    return Column(
      children: List.generate(count, (index) {
        return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            // CORRECTED: Using theme colors
            .shimmer(
              duration: 1500.ms,
              color: AppColors.goldenrod.withOpacity(0.1),
            );
      }),
    );
  }

  Widget _buildPremiumErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        // CORRECTED: Using theme colors
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            // CORRECTED: Using theme colors
            color: AppColors.error,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: _primaryFont,
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              // CORRECTED: Using theme colors
              backgroundColor: AppColors.error.withOpacity(0.2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.error.withOpacity(0.5)),
              ),
            ),
            child: Text(l10n.contractPanelRetryButton),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale();
  }

  Widget _buildPremiumEmptyState({
    required String message,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        // CORRECTED: Using theme colors
        border: Border.all(color: AppColors.goldenrod.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // CORRECTED: Using theme colors
              color: AppColors.goldenrod.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            // CORRECTED: Using theme colors
            child: Icon(icon, color: AppColors.goldenrod, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: _headingFont,
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: _primaryFont,
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        // CORRECTED: Using theme colors
        Expanded(
          child: Divider(
            color: AppColors.goldenrod.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          // CORRECTED: Using theme colors
          child: Icon(Icons.star_rounded, color: AppColors.goldenrod, size: 16),
        ),
        Expanded(
          child: Divider(
            color: AppColors.goldenrod.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.5, 1));
  }

  Widget _buildAnimatedGradientBackground() {
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
                AppColors.primaryColor.withOpacity(0.7),
                AppColors.background,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCornerBurstEffect() {
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
                  AppColors.goldenrod.withOpacity(0.3),
                  AppColors.primaryColor.withOpacity(0.2),
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

class _PremiumSubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final String contractName;
  final Duration delay;
  final VoidCallback onTap;

  const _PremiumSubscriptionCard({
    required this.subscription,
    required this.contractName,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              // CORRECTED: Using theme colors
              splashColor: AppColors.goldenrod.withOpacity(0.2),
              highlightColor: AppColors.goldenrod.withOpacity(0.1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          // CORRECTED: Using theme colors
                          AppColors.goldenrod.withOpacity(0.15),
                          AppColors.goldenrod.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      // CORRECTED: Using theme colors
                      border: Border.all(
                        color: AppColors.goldenrod.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contractName,
                                style: const TextStyle(
                                  fontFamily: _headingFont,
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${subscription.pickupLocation} → ${subscription.dropoffLocation}',
                                style: const TextStyle(
                                  fontFamily: _primaryFont,
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          // CORRECTED: Using theme colors
                          color: AppColors.goldenrod,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .animate(delay: delay)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

class _PremiumContractCard extends StatelessWidget {
  final double width;
  final Contract contract;
  final Duration delay;
  final VoidCallback onTap;

  const _PremiumContractCard({
    required this.width,
    required this.contract,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
          width: width,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              // CORRECTED: Using theme colors
              splashColor: AppColors.goldenrod.withOpacity(0.2),
              highlightColor: AppColors.goldenrod.withOpacity(0.1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              // CORRECTED: Using theme colors
                              color: AppColors.goldenrod.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                           child: Icon(
                              Icons.rocket_launch_rounded,
                              color: AppColors.goldenrod,
                              size: 28,
                            ),),
                          const Spacer(),
                          Text(
                            contract.contractType,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: _headingFont,
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              // CORRECTED: Using theme colors
                              color: AppColors.goldenrod.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.contractPanelDiscountOff(
                                contract.discountPercentage.toStringAsFixed(0),
                              ),
                              style: const TextStyle(
                                fontFamily: _primaryFont,
                                // CORRECTED: Using theme colors
                                color: AppColors.goldenrod,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .animate(delay: delay)
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }
}

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
