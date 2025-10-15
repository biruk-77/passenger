// lib/screens/home/widgets/planning_panel_content.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/vehicle_type.dart';
import '../../../models/pricing_rule.dart';
import 'widgets.dart';
import '../../../models/contract/contract_ride.dart';
import '../../../theme/color.dart'; // IMPORTED FOR THEME COLORS

// --- THEME CONSTANTS FOR THIS "MARKET-DRIVEN" PANEL ---
// LOCAL COLOR CONSTANTS REMOVED TO ADHERE TO THEME SYSTEM
const String _primaryFont = 'Inter';
const String _headingFont = 'PlayfairDisplay';

class PlanningPanelContent extends StatefulWidget {
  final String estimatedTime;
  final String estimatedDistance;
  final bool isLoadingRideOptions;
  final String? rideOptionsError;
  final List<VehicleType> vehicleTypes;
  final int selectedRideIndex;
  final void Function(int) onVehicleSelected;
  final Future<void> Function() onConfirmRide;
  final Map<String, FareEstimate> fareEstimates;
  final List<Contract> availableContracts;
  final bool isLoadingContracts;
  final String? contractsError;
  final void Function(Contract) onContractSelected;
  const PlanningPanelContent({
    super.key,
    required this.estimatedTime,
    required this.estimatedDistance,
    required this.isLoadingRideOptions,
    required this.rideOptionsError,
    required this.vehicleTypes,
    required this.selectedRideIndex,
    required this.onVehicleSelected,
    required this.onConfirmRide,
    required this.fareEstimates,
    required this.availableContracts,
    required this.isLoadingContracts,
    required this.contractsError,
    required this.onContractSelected,
  });

  @override
  State<PlanningPanelContent> createState() => _PlanningPanelContentState();
}

class _PlanningPanelContentState extends State<PlanningPanelContent>
    with TickerProviderStateMixin {
  late PageController _pageController;

  // --- ADDED ANIMATION CONTROLLERS ---
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();

    // --- INITIALIZE ANIMATION CONTROLLERS ---
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

    // --- EXISTING INIT LOGIC ---
    _pageController = PageController(
      viewportFraction: 0.75,
      initialPage: widget.selectedRideIndex.clamp(
        0,
        widget.vehicleTypes.isNotEmpty ? widget.vehicleTypes.length - 1 : 0,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant PlanningPanelContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRideIndex != oldWidget.selectedRideIndex &&
        _pageController.hasClients) {
      _pageController.animateToPage(
        widget.selectedRideIndex,
        duration: 400.ms,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    // --- DISPOSE ANIMATION CONTROLLERS ---
    _gradientController.dispose();
    _burstController.dispose();

    // --- EXISTING DISPOSE LOGIC ---
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        // OLD GRADIENT REMOVED
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      child: Stack(
        children: [
          // --- NEW ANIMATED BACKGROUND ---
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),
          // --- EXISTING UI ---
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PanelHandle(),
                _buildHeader(context),
                _buildVehicleCarousel(context),
                _buildContractsSection(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: ConfirmButton(
                    l10n: l10n,
                    onConfirm: widget.onConfirmRide,
                    selectedVehicle: widget.vehicleTypes.isEmpty
                        ? null
                        : widget.vehicleTypes[widget.selectedRideIndex],
                    isDisabled:
                        widget.isLoadingRideOptions ||
                        widget.vehicleTypes.isEmpty,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.planningPanelTitle,
            style: const TextStyle(
              fontFamily: _headingFont,
              color: AppColors.textPrimary, // THEMED
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTripInfo(
                l10n.planningPanelDistance,
                widget.estimatedDistance,
                Icons.map_outlined,
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
              _buildTripInfo(
                l10n.planningPanelDuration,
                widget.estimatedTime,
                Icons.timer_outlined,
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2),
            ],
          ),
        ],
      ),
    ).animate().slideY(
      begin: 0.2,
      delay: 200.ms,
      duration: 500.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildTripInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.goldenrod, size: 20), // THEMED
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: _primaryFont,
                color: AppColors.textSecondary, // THEMED
                fontSize: 12,
              ),
            ),
            Text(
              value.isEmpty ? "--" : value,
              style: const TextStyle(
                fontFamily: _primaryFont,
                color: AppColors.textPrimary, // THEMED
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleCarousel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.isLoadingRideOptions) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.goldenrod),
        ), // THEMED
      );
    }
    if (widget.rideOptionsError != null) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              widget.rideOptionsError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.warning, // THEMED
                fontFamily: _primaryFont,
              ),
            ),
          ),
        ),
      );
    }
    if (widget.vehicleTypes.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Text(
            l10n.noRidesAvailable,
            style: const TextStyle(
              color: AppColors.textSecondary, // THEMED
              fontFamily: _primaryFont,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.vehicleTypes.length,
        onPageChanged: widget.onVehicleSelected,
        itemBuilder: (context, index) {
          final vehicle = widget.vehicleTypes[index];
          final estimate = widget.fareEstimates[vehicle.name.toLowerCase()];

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double pageOffset = 0;
              if (_pageController.position.haveDimensions) {
                pageOffset = (_pageController.page ?? 0) - index;
              }
              final scale = (1 - (pageOffset.abs() * 0.15)).clamp(0.85, 1.0);

              return Transform.scale(scale: scale, child: child);
            },
            child: _VehicleCard(
              vehicle: vehicle,
              estimate: estimate,
              isSelected: index == widget.selectedRideIndex,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContractsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.isLoadingContracts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.goldenrod),
        ), // THEMED
      );
    }

    if (widget.contractsError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
        child: Text(
          widget.contractsError!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.warning,
            fontFamily: _primaryFont,
          ), // THEMED
        ),
      );
    }

    if (widget.availableContracts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.borderColor.withOpacity(0.5)), // THEMED
          const SizedBox(height: 16),
          Text(
            l10n.contractsSectionTitle,
            style: const TextStyle(
              fontFamily: _primaryFont,
              color: AppColors.textPrimary, // THEMED
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.contractsSectionDescription, // Using new localized string
            style: TextStyle(
              fontFamily: _primaryFont,
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.availableContracts.length,
            itemBuilder: (context, index) {
              final contract = widget.availableContracts[index];
              return _ContractListTile(
                contract: contract,
                onTap: () => widget.onContractSelected(contract),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5);
  }

  // --- HELPER WIDGETS FOR ANIMATED BACKGROUND ---
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

class _VehicleCard extends StatelessWidget {
  final VehicleType vehicle;
  final FareEstimate? estimate;
  final bool isSelected;

  const _VehicleCard({
    required this.vehicle,
    required this.estimate,
    required this.isSelected,
  });

  String _getLocalizedTagline(BuildContext context, String vehicleName) {
    final l10n = AppLocalizations.of(context)!;
    switch (vehicleName.toLowerCase()) {
      case 'standard':
        return l10n.vehicleTaglineStandard;
      case 'comfort':
        return l10n.vehicleTaglineComfort;
      case 'van':
        return l10n.vehicleTaglineVan;
      default:
        return l10n.vehicleTaglineDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String localeForFormatting =
        NumberFormat.localeExists(l10n.localeName) ? l10n.localeName : 'en_US';
    final currencyFormat = NumberFormat.currency(
      locale: localeForFormatting,
      symbol: '${l10n.currencySymbol} ',
    );
    final price = estimate?.fare ?? 0.0;
    final originalPrice = estimate?.originalFare;
    final hasDiscount = originalPrice != null && originalPrice > price;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: AnimatedContainer(
                duration: 400.ms,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(
                    isSelected ? 0.6 : 0.3,
                  ), // THEMED
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.goldenrod.withOpacity(0.8) // THEMED
                        : AppColors.borderColor.withOpacity(0.5), // THEMED
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.goldenrod.withOpacity(
                              0.3,
                            ), // THEMED
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        vehicle.name.capitalize(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: _headingFont,
                          color: AppColors.textPrimary, // THEMED
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _getLocalizedTagline(context, vehicle.name),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: _primaryFont,
                          color: AppColors.textSecondary, // THEMED
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        color: AppColors.borderColor.withOpacity(0.3),
                      ), // THEMED
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AnimatedSwitcher(
                        duration: 300.ms,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: Column(
                          key: ValueKey<double>(price),
                          children: [
                            if (hasDiscount)
                              Text(
                                currencyFormat.format(originalPrice),
                                style: TextStyle(
                                  fontFamily: _primaryFont,
                                  color: AppColors.textSubtle, // THEMED
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              price > 0
                                  ? currencyFormat.format(price)
                                  : l10n.fareCalculating,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: _primaryFont,
                                color: isSelected
                                    ? AppColors.goldenrod
                                    : AppColors.textPrimary, // THEMED
                                fontSize: hasDiscount ? 26 : 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -40,
            child:
                Image.asset(
                      vehicle.imagePath,
                      width: 220,
                      height: 120,
                      fit: BoxFit.contain,
                    )
                    .animate(target: isSelected ? 1 : 0)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    )
                    .move(begin: const Offset(0, 10), end: Offset.zero),
          ),
          if (hasDiscount)
            Positioned(
              top: 25,
              right: 25,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error, // THEMED
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.discount.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textPrimary, // THEMED
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).scaleXY(begin: 0.8),
            ),
        ],
      ),
    );
  }
}

class ConfirmButton extends StatefulWidget {
  final Future<void> Function() onConfirm;
  final VehicleType? selectedVehicle;
  final bool isDisabled;
  final AppLocalizations l10n;

  const ConfirmButton({
    super.key,
    required this.onConfirm,
    required this.l10n,
    this.selectedVehicle,
    this.isDisabled = false,
  });

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
  bool _isPressed = false;
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (widget.isDisabled || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      await widget.onConfirm();
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = _isLoading
        ? widget.l10n.confirmButtonRequesting
        : widget.l10n.confirmButtonRequest;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _handleConfirm,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: 150.ms,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: 300.ms,
          height: 60,
          decoration: BoxDecoration(
            color: widget.isDisabled
                ? AppColors.textSubtle
                : AppColors.goldenrod, // THEMED
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isDisabled
                ? []
                : [
                    BoxShadow(
                      color: AppColors.goldenrod.withOpacity(0.5), // THEMED
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: 200.ms,
              child: _isLoading
                  ? SizedBox(
                      key: const ValueKey('loader'),
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary, // THEMED
                      ),
                    )
                  : Text(
                      key: ValueKey(buttonText),
                      buttonText,
                      style: TextStyle(
                        fontFamily: _primaryFont,
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary, // THEMED
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class _ContractListTile extends StatelessWidget {
  final Contract contract;
  final VoidCallback onTap;

  const _ContractListTile({required this.contract, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: NumberFormat.localeExists(l10n.localeName)
          ? l10n.localeName
          : 'en_US',
      symbol: l10n.currencySymbol,
      decimalDigits: 0,
    );
    final subtitleText =
        '${l10n.baseRate}: ${currencyFormat.format(contract.basePricePerKm)}/km ・ ${contract.discountPercentage.toInt()}% ${l10n.discount}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10.0),
      color: AppColors.cardBackground.withOpacity(0.4), // THEMED
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.borderColor.withOpacity(0.4),
        ), // THEMED
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(
          Icons.workspace_premium_outlined,
          color: AppColors.goldenrod, // THEMED
        ),
        title:  Text(
          contract.contractType, // Assuming this is placeholder, keeping as is.
          style: TextStyle(
            color: AppColors.textPrimary, // THEMED
            fontWeight: FontWeight.bold,
            fontFamily: _primaryFont,
          ),
        ),
        subtitle: Text(
          subtitleText,
          style: const TextStyle(
            color: AppColors.textSecondary, // THEMED
            fontFamily: _primaryFont,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary, // THEMED
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}

// --- COPIED CUSTOM CLIPPER ---
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
