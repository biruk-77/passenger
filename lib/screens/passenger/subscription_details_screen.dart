// lib/screens/passenger/subscription_details_screen.dart

import 'package:animate_do/animate_do.dart'; // STEP 1: ADDED IMPORT
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
// Make sure this path is correct for your project structure
import '../../l10n/app_localizations.dart';

import '../../models/contract/contract_ride.dart';
import '../../theme/color.dart';

// STEP 2: CONVERTED TO STATEFUL WIDGET
class SubscriptionDetailsScreen extends StatefulWidget {
  final Subscription subscription;
  const SubscriptionDetailsScreen({super.key, required this.subscription});

  @override
  State<SubscriptionDetailsScreen> createState() =>
      _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen>
    with TickerProviderStateMixin {
  // STEP 2: ADDED ANIMATION CONTROLLERS
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    // STEP 3: INITIALIZED CONTROLLERS
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
    // STEP 3: DISPOSED CONTROLLERS
    _gradientController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.notAssigned;
    return DateFormat.yMMMd().format(date); // e.g., Oct 6, 2025
  }

  String _formatValue(dynamic value, AppLocalizations l10n) {
    if (value == null) return l10n.notAssigned;
    if (value is String && value.isEmpty) return l10n.notAssigned;
    return value.toString();
  }

  // Helper to launch the phone dialer
  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ');

    // <<<--- THIS IS THE FIX ---
    // Define the driverPhone variable here, within the build method's scope.
    final String? driverPhone = widget.subscription.assignedDriver?.driverPhone;

    final bool isDriverAssigned =
        widget.subscription.driverId != null &&
        _formatValue(widget.subscription.driverId, l10n).toLowerCase() !=
            l10n.notAssigned.toLowerCase();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.subscriptionDetails),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      // STEP 5: REPLACED CONTAINER WITH A STACK FOR THE NEW BACKGROUND
      body: Stack(
        children: [
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),
          SafeArea(
            // STEP 6: ADDED FADEIN ANIMATION FOR GRACEFUL ENTRY
            child: FadeIn(
              delay: const Duration(milliseconds: 1200),
              duration: const Duration(milliseconds: 500),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _DetailCard(
                    icon: Icons.info_outline,
                    title: l10n.subscriptionStatus,
                    children: [
                      _DetailRow(
                        label: l10n.status,
                        valueWidget: _StatusBadge(
                          text: widget.subscription.status,
                        ),
                      ),
                      _DetailRow(
                        label: l10n.payment,
                        valueWidget: _StatusBadge(
                          text: widget.subscription.paymentStatus,
                        ),
                      ),
                      _DetailRow(
                        label: l10n.validity,
                        value:
                            '${_formatDate(widget.subscription.startDate, l10n)} to ${_formatDate(widget.subscription.endDate, l10n)}',
                      ),
                      _DetailRow(
                        label: l10n.daysLeft,
                        valueWidget: _buildDaysLeftWidget(
                          context,
                          widget.subscription,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DetailCard(
                    icon: Icons.route_outlined,
                    title: l10n.routeInformation,
                    children: [
                      _DetailRow(
                        label: l10n.pickup,
                        value: widget.subscription.pickupLocation,
                      ),
                      _DetailRow(
                        label: l10n.dropoff,
                        value: widget.subscription.dropoffLocation,
                      ),
                      _DetailRow(
                        label: l10n.distance,
                        value:
                            '${widget.subscription.distanceKm.toStringAsFixed(2)} km',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DetailCard(
                    icon: Icons.monetization_on_outlined,
                    title: l10n.financials,
                    children: [
                      _DetailRow(
                        label: l10n.baseFare,
                        value: currencyFormat.format(widget.subscription.fare),
                      ),
                      _DetailRow(
                        label: l10n.finalFare,
                        value: currencyFormat.format(
                          widget.subscription.finalFare,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isDriverAssigned) ...[
                    _DetailCard(
                      icon: Icons.drive_eta_outlined,
                      title: l10n.assignedDriver,
                      children: [
                        _DetailRow(
                          label: l10n.name,
                          value: _formatValue(
                            widget.subscription.assignedDriver?.driverName,
                            l10n,
                          ),
                        ),
                        _DetailRow(
                          label: l10n.phone,
                          value: _formatValue(
                            driverPhone,
                            l10n,
                          ), // Now correctly references the variable
                          actionWidget:
                              (driverPhone != null && driverPhone.isNotEmpty)
                              ? TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.electricCyan,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(Icons.phone, size: 16),
                                  label: Text(l10n.callDriver),
                                  onPressed: () => _makePhoneCall(
                                    driverPhone,
                                    context,
                                  ), // Now correctly references the variable
                                )
                              : null,
                        ),
                        _DetailRow(
                          label: l10n.vehicle,
                          value: _formatValue(
                            widget.subscription.assignedDriver?.vehicleInfo !=
                                    null
                                ? '${widget.subscription.assignedDriver!.vehicleInfo!.color} ${widget.subscription.assignedDriver!.vehicleInfo!.model} (${widget.subscription.assignedDriver!.vehicleInfo!.plate})'
                                : null,
                            l10n,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  _DetailCard(
                    icon: Icons.person_outline,
                    title: l10n.passengerDetails,
                    children: [
                      _DetailRow(
                        label: l10n.name,
                        value: _formatValue(
                          widget.subscription.passengerName,
                          l10n,
                        ),
                      ),
                      _DetailRow(
                        label: l10n.phone,
                        value: _formatValue(
                          widget.subscription.passengerPhone,
                          l10n,
                        ),
                      ),
                      _DetailRow(
                        label: l10n.email,
                        value: _formatValue(
                          widget.subscription.passengerEmail,
                          l10n,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DetailCard(
                    icon: Icons.fingerprint,
                    title: l10n.identifiers,
                    children: [
                      _DetailRow(
                        label: l10n.subscriptionId,
                        value: _formatValue(widget.subscription.id, l10n),
                      ),
                      _DetailRow(
                        label: l10n.contractId,
                        value: _formatValue(
                          widget.subscription.contractId,
                          l10n,
                        ),
                      ),
                      _DetailRow(
                        label: l10n.passengerId,
                        value: _formatValue(
                          widget.subscription.passengerId,
                          l10n,
                        ),
                      ),
                      if (isDriverAssigned)
                        _DetailRow(
                          label: l10n.driverId,
                          value: _formatValue(
                            widget.subscription.driverId,
                            l10n,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysLeftWidget(BuildContext context, Subscription subscription) {
    final l10n = AppLocalizations.of(context)!;

    // First, check the subscription's own status
    final status = subscription.status.toLowerCase();
    if (status == 'expired' || status == 'cancelled') {
      return Text(
        l10n.statusExpired,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.error,
        ),
      );
    }

    if (subscription.endDate == null) {
      return Text(
        l10n.notAssigned,
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      );
    }

    // Use dateOnly to ignore time and get an accurate day count
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(
      subscription.endDate!.year,
      subscription.endDate!.month,
      subscription.endDate!.day,
    );

    final differenceInDays = endDate.difference(today).inDays;

    String text;
    Color color;

    if (differenceInDays < 0) {
      text = l10n.statusExpired;
      color = AppColors.error;
    } else if (differenceInDays == 0) {
      text = l10n.expiresToday;
      color = AppColors.warning;
    } else if (differenceInDays == 1) {
      text = l10n.daysLeftSingular(differenceInDays);
      color = AppColors.warning;
    } else if (differenceInDays <= 7) {
      text = l10n.daysLeftPlural(differenceInDays);
      color = AppColors.warning;
    } else {
      text = l10n.daysLeftPlural(differenceInDays);
      color = AppColors.success;
    }

    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
    );
  }

  // STEP 4: COPIED HELPER WIDGETS
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

// --- WIDGETS ---
// (No changes needed in the widgets below)

class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(height: 24, color: Colors.white.withOpacity(0.3)),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Widget? actionWidget;

  const _DetailRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (valueWidget != null)
                  valueWidget!
                else
                  Text(
                    value ?? '',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                if (actionWidget != null) ...[
                  const SizedBox(height: 4),
                  actionWidget!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  const _StatusBadge({required this.text});

  Color _getBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'completed':
        return AppColors.success.withOpacity(0.2);
      case 'pending':
        return AppColors.warning.withOpacity(0.2);
      case 'expired':
      case 'unpaid':
      case 'cancelled':
        return AppColors.error.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'expired':
      case 'unpaid':
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(text),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: _getTextColor(text),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// STEP 4: COPIED CUSTOM CLIPPER CLASS
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
