// lib/widgets/contract_ride_confirmation_panel.dart
import 'dart:async';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/contract/contract_ride.dart';
import '../../theme/color.dart'; // Keep for semantic colors like AppColors.success
import '../../theme/styles.dart';

// NOTICE: NO 'const Color' definitions here. All styling comes from the theme.

class ContractRideConfirmationPanel extends StatefulWidget {
  final Subscription subscription;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isBooking;

  const ContractRideConfirmationPanel({
    super.key,
    required this.subscription,
    required this.onConfirm,
    required this.onCancel,
    this.isBooking = false,
  });

  @override
  State<ContractRideConfirmationPanel> createState() =>
      _ContractRideConfirmationPanelState();
}

class _ContractRideConfirmationPanelState
    extends State<ContractRideConfirmationPanel>
    with TickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.25),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildRouteCard(context),
                  const SizedBox(height: 24),
                  _SubscriptionSummary(subscription: widget.subscription),
                  const SizedBox(height: 32),
                  _ConfirmButton(
                    onConfirm: widget.onConfirm,
                    isBooking: widget.isBooking,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.confirmRideTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                l10n.bookingUnderContract(widget.subscription.contractType),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
          child: IconButton(
            onPressed: widget.onCancel,
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            tooltip: l10n.cancel,
          ),
        ).animate().fadeIn(delay: 100.ms).scale(),
      ],
    );
  }

  Widget _buildRouteCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 20,
            top: 50,
            bottom: 50,
            child: Animate(
              onPlay: (controller) => controller.repeat(),
              effects: [
                ShimmerEffect(
                  duration: 1500.ms,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                  angle: 0.0,
                ),
              ],
              child: Container(
                width: 1.5,
                color: theme.colorScheme.primary.withOpacity(0.4),
              ),
            ),
          ),
          Column(
            children: [
              _buildRouteInfo(
                icon: Icons.my_location,
                title: l10n.pickupLocation,
                address: widget.subscription.pickupLocation,
                delay: 200.ms,
              ),
              const SizedBox(height: 24),
              _buildRouteInfo(
                icon: Icons.flag,
                title: l10n.destination,
                address: widget.subscription.dropoffLocation,
                delay: 300.ms,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo({
    required IconData icon,
    required String title,
    required String address,
    required Duration delay,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Animate(
          onPlay: (controller) => controller.repeat(reverse: true),
          delay: 50.ms,
          effects: [
            TintEffect(
              duration: 1500.ms,
              color: theme.colorScheme.primary.withOpacity(0.15),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ).animate(delay: delay).fadeIn().slideX(begin: -0.2);
  }

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
                theme.colorScheme.secondary.withOpacity(0.5),
                theme.colorScheme.background,
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

class _SubscriptionSummary extends StatelessWidget {
  final Subscription subscription;

  const _SubscriptionSummary({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final driver = subscription.assignedDriver;
    final vehicle = driver?.vehicleInfo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              l10n.tripSummaryTitle.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildDetailRow(
            context,
            icon: Icons.person_pin_circle_rounded,
            title: l10n.assignedDriver,
            value: driver?.driverName ?? l10n.driverPending,
            isGold: driver != null,
            delay: 500.ms,
          ),
          if (driver?.driverPhone != null &&
              driver!.driverPhone != 'Not available')
            _buildDetailRow(
              context,
              icon: Icons.phone_rounded,
              title: l10n.driverContact,
              value: driver.driverPhone!,
              delay: 550.ms,
            ),
          if (vehicle != null) ...[
            _buildDivider(context),
            _buildDetailRow(
              context,
              icon: Icons.directions_car_rounded,
              title: l10n.vehicle,
              value: '${vehicle.color} ${vehicle.model}',
              delay: 600.ms,
            ),
            _buildDetailRow(
              context,
              icon: Icons.pin_outlined,
              title: l10n.plateNumber,
              value: vehicle.plate,
              isGold: true,
              delay: 650.ms,
            ),
          ],
          _buildDivider(context),
          _buildDetailRow(
            context,
            icon: Icons.receipt_long,
            title: l10n.contractPrice,
            value: subscription.finalFare > 0
                ? 'ETB ${subscription.finalFare.toStringAsFixed(2)}'
                : l10n.negotiated,
            isGold: true,
            delay: 700.ms,
          ),
          _buildDetailRow(
            context,
            icon: Icons.speed_rounded,
            title: l10n.tripDistance,
            value: '${subscription.distanceKm.toStringAsFixed(1)} km',
            delay: 750.ms,
          ),
          _buildDetailRow(
            context,
            icon: Icons.credit_card,
            title: l10n.paymentStatus,
            value: subscription.paymentStatus,
            valueColor: subscription.paymentStatus == 'PAID'
                ? AppColors.success
                : AppColors.error,
            delay: 800.ms,
          ),
          _buildDetailRow(
            context,
            icon: Icons.shield_moon_rounded,
            title: l10n.subscriptionStatus,
            value: subscription.status,
            valueColor: subscription.status == 'ACTIVE'
                ? AppColors.success
                : AppColors.warning,
            delay: 850.ms,
          ),
          if (subscription.startDate != null && subscription.endDate != null)
            _buildDetailRow(
              context,
              icon: Icons.date_range_rounded,
              title: l10n.validity,
              value:
                  '${DateFormat.yMd().format(subscription.startDate!)} - ${DateFormat.yMd().format(subscription.endDate!)}',
              delay: 900.ms,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isGold = false,
    Color? valueColor,
    required Duration delay,
  }) {
    final theme = Theme.of(context);
    return Animate(
      delay: delay,
      effects: [
        FadeEffect(duration: 400.ms),
        const SlideEffect(begin: Offset(0.05, 0)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isGold
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color:
                    valueColor ??
                    (isGold
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface),
                fontWeight: isGold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
      height: 1,
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final FutureOr<void> Function() onConfirm;
  final bool isBooking;

  const _ConfirmButton({required this.onConfirm, this.isBooking = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isBooking ? null : onConfirm,
      child: Animate(
        delay: 400.ms,
        effects: [FadeEffect(duration: 500.ms)],
        child: Container(
          height: 60,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Animate(
                  onPlay: (controller) => controller.repeat(),
                  effects: [
                    ShimmerEffect(
                      duration: 1800.ms,
                      delay: 1000.ms,
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                      angle: 45,
                    ),
                  ],
                  child: Container(color: Colors.transparent),
                ),
              ),
              Center(
                child: AnimatedSwitcher(
                  duration: 300.ms,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: isBooking
                      ? SizedBox(
                          key: const ValueKey('loader'),
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Row(
                          key: const ValueKey('text'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car_filled_rounded,
                              color: theme.colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.confirmTodaysPickup,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
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
    );
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
