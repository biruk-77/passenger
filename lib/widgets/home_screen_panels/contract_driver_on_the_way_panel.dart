// lib/widgets/home_screen_panels/contract_driver_on_the_way_panel.dart
import 'dart:async';
import 'dart:ui'; // ✅ ADDED IMPORT
import 'package:animate_do/animate_do.dart'; // ✅ ADDED IMPORT
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../models/contract/contract_ride.dart';
import '../../theme/color.dart';
import '../../theme/styles.dart';
import '../../utils/logger.dart';

// ✅ CONVERTED TO STATEFULWIDGET TO MANAGE ANIMATIONS
class ContractDriverOnTheWayPanelContent extends StatefulWidget {
  final Subscription? subscription;
  final String eta;
  final String distance;
  final VoidCallback onCancel;
  final VoidCallback onContact;
  final VoidCallback onOpenChat;
  final VoidCallback onConfirmDropoff;
  final bool isTripOngoing;

  const ContractDriverOnTheWayPanelContent({
    super.key,
    required this.subscription,
    required this.eta,
    required this.distance,
    required this.onCancel,
    required this.onContact,
    required this.onOpenChat,
    required this.onConfirmDropoff,
    this.isTripOngoing = false,
  });

  @override
  State<ContractDriverOnTheWayPanelContent> createState() =>
      _ContractDriverOnTheWayPanelContentState();
}

class _ContractDriverOnTheWayPanelContentState
    extends State<ContractDriverOnTheWayPanelContent>
    with TickerProviderStateMixin {
  // ✅ ADDED ANIMATION CONTROLLERS
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    // ✅ INITIALIZED ANIMATION CONTROLLERS
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
    // ✅ DISPOSED ANIMATION CONTROLLERS
    _gradientController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  // --- NO FUNCTIONALITY BELOW THIS LINE HAS BEEN CHANGED ---

  Future<void> _makePhoneCall(BuildContext context, String? phoneNumber) async {
    final l10n = AppLocalizations.of(context)!;
    if (phoneNumber == null ||
        phoneNumber.isEmpty ||
        phoneNumber == 'Not available') {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.phoneNumberNotAvailable)));
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $launchUri';
      }
    } catch (e, st) {
      Logger.error("ContractDriverPanel", "Failed to make phone call", e, st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotLaunch(launchUri.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.subscription == null ||
        widget.subscription!.assignedDriver == null) {
      return _buildLoadingState(context);
    }

    // ✅ REFACTORED BUILD METHOD
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      child: Stack(
        children: [
          // ✅ ADDED NEW BACKGROUND
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),
          // ✅ WRAPPED ORIGINAL CONTENT IN FADEINUP FOR SYNCHRONIZED ANIMATION
          FadeInUp(
            delay: const Duration(milliseconds: 1200),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDragHandle(),
                  const SizedBox(height: 16),
                  _buildEtaHeader(l10n),
                  const SizedBox(height: 20),
                  _buildDriverCard(
                    context,
                    widget.subscription!.assignedDriver!,
                    l10n,
                  ),
                  const SizedBox(height: 16),
                  _buildRouteCard(context, widget.subscription!),
                  const SizedBox(height: 16),
                  _buildSubscriptionDetailsCard(
                    context,
                    widget.subscription!,
                    l10n,
                  ),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildEtaHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          widget.isTripOngoing
              ? l10n.ongoingTripTitle
              : l10n.driverOnWayDriverArriving,
          style: AppTextStyles.panelTitle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              widget.eta,
              style: const TextStyle(
                color: AppColors.goldenrod,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.distance.isNotEmpty && !widget.isTripOngoing) ...[
              const SizedBox(width: 12),
              Text(
                '(${widget.distance})',
                style: const TextStyle(
                  color: AppColors.textSubtle,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.isTripOngoing
              ? l10n.tripDetails
              : l10n.driverOnWayMeetAtPickup,
          style: AppTextStyles.panelSubtitle.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.goldenrod),
          const SizedBox(height: 20),
          Text(
            l10n.contractDriverLoading,
            style: AppTextStyles.panelSubtitle.copyWith(
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(
    BuildContext context,
    AssignedDriver driver,
    AppLocalizations l10n,
  ) {
    final vehicle = driver.vehicleInfo;
    return _buildInfoCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.lightCobalt,
                child: Text(
                  driver.driverName.isNotEmpty
                      ? driver.driverName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.driverName, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      l10n.contractDriverTypeLabel,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              if (vehicle != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${vehicle.color} ${vehicle.model}',
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: AppColors.textSubtle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldenrod,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vehicle.plate,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const Divider(height: 24, color: Colors.white12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionButton(
                context,
                icon: Icons.call,
                label: l10n.driverOnWayCall,
                onTap: () => _makePhoneCall(context, driver.driverPhone),
              ),
              _actionButton(
                context,
                icon: Icons.message,
                label: l10n.driverOnWayChat,
                onTap: widget.onOpenChat,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, Subscription sub) {
    return _buildInfoCard(
      child: Column(
        children: [
          _routeRow(
            icon: Icons.my_location,
            text: sub.pickupLocation,
            color: AppColors.info,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(height: 20, width: 2, color: Colors.white24),
            ),
          ),
          _routeRow(
            icon: Icons.location_on,
            text: sub.dropoffLocation,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetailsCard(
    BuildContext context,
    Subscription sub,
    AppLocalizations l10n,
  ) {
    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.contractDetailsTitle, style: AppTextStyles.cardTitle),
          const SizedBox(height: 12),
          _detailRow(l10n.contractDetailsContractType, sub.contractType),
          _detailRow(
            l10n.contractDetailsSubscriptionId,
            sub.id.length > 8 ? sub.id.substring(0, 8) : sub.id,
          ),
          _detailRow(
            l10n.duration,
            sub.startDate != null && sub.endDate != null
                ? '${DateFormat.yMMMd().format(sub.startDate!)} - ${DateFormat.yMMMd().format(sub.endDate!)}'
                : "N/A",
          ),
          if (sub.endDate != null) ...[
            const Divider(height: 20, color: Colors.white12),
            _buildDaysLeft(sub.endDate!, l10n),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _statusChip(
                "Status: ${sub.status}",
                sub.status == 'ACTIVE' ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 8),
              _statusChip(
                "Payment: ${sub.paymentStatus}",
                sub.paymentStatus == 'PAID'
                    ? AppColors.success
                    : AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaysLeft(DateTime endDate, AppLocalizations l10n) {
    final now = DateTime.now();
    final endDay = DateTime.utc(endDate.year, endDate.month, endDate.day);
    final currentDay = DateTime.utc(now.year, now.month, now.day);
    final difference = endDay.difference(currentDay);

    final daysLeft = difference.inDays;

    String daysLeftText;
    Color textColor;

    if (daysLeft < 0) {
      daysLeftText = l10n.contractExpired;
      textColor = AppColors.error;
    } else {
      daysLeftText = l10n.contractTimeLeftDays(daysLeft);
      textColor = daysLeft < 7 ? AppColors.warning : AppColors.textPrimary;
    }

    return _detailRow(
      l10n.contractDetailsTimeRemaining,
      daysLeftText,
      valueStyle: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    if (widget.isTripOngoing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: widget.onConfirmDropoff,
          icon: const Icon(
            Icons.check_circle_outline,
            color: AppColors.textPrimary,
          ),
          label: Text(
            l10n.confirmDropoff,
            style: AppTextStyles.buttonText.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: widget.onCancel,
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          label: Text(
            l10n.driverOnWayCancelRide,
            style: AppTextStyles.buttonText.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent, // Let the new background show through
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String title, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.textSubtle, fontSize: 13),
          ),
          Text(
            value,
            style:
                valueStyle ??
                const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  // ✅ HELPER WIDGETS COPIED FROM TEMPLATE
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
            position: const Offset(double.infinity, 0), // Top-right corner
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
                center: const Alignment(1.0, -1.0), // Top-right corner
              ),
            ),
          ),
        );
      },
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
    return true; // Always reclip as the radius is animating
  }
}
