// FILE: /lib/widgets/home_screen_panels/driver_on_the_way_panel.dart
/* CRITICAL: DO NOT REMOVE OR ABBREVIATE. 
      This file must be delivered complete. 
      Any changes must preserve the exported public API. */
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../models/vehicle_type.dart';
import '../../theme/color.dart'; // Keep for specific semantic colors if needed
import 'widgets.dart';

// --- THEME CONSTANTS REMOVED ---
// All styling is now derived from Theme.of(context)

class DriverOnTheWayPanelContent extends StatefulWidget {
  final Booking? booking;
  final String eta;
  final VoidCallback onCancel;
  final VoidCallback onContact;
  final VoidCallback onOpenChat;
  final bool isTripOngoing;

  const DriverOnTheWayPanelContent({
    super.key,
    required this.booking,
    required this.eta,
    required this.onCancel,
    required this.onContact,
    required this.onOpenChat,
    required this.isTripOngoing,
  });

  @override
  State<DriverOnTheWayPanelContent> createState() =>
      _DriverOnTheWayPanelContentState();
}

class _DriverOnTheWayPanelContentState extends State<DriverOnTheWayPanelContent>
    with TickerProviderStateMixin {
  // --- Animation Controllers for the new background ---
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  // --- Existing Logic (UNCHANGED) ---
  Timer? _countdownTimer;
  int? remainingSeconds;
  int? initialSeconds;

  @override
  void initState() {
    super.initState();

    // Initialize new background controllers
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

    // Existing logic
    _startEtaCountdown();
  }

  // --- EXISTING LOGIC (UNCHANGED) ---
  @override
  void didUpdateWidget(covariant DriverOnTheWayPanelContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.eta != oldWidget.eta) {
      _startEtaCountdown();
    }
  }

  void _startEtaCountdown() {
    _countdownTimer?.cancel();
    final etaClean = widget.eta.trim().toLowerCase();

    if (etaClean.contains("arrived")) {
      setState(() {
        remainingSeconds = 0;
        initialSeconds = 1;
      });
      return;
    }

    final match = RegExp(r'(\d+)').firstMatch(etaClean);
    if (match != null) {
      final minutes = int.tryParse(match.group(1)!);
      if (minutes != null && minutes > 0) {
        initialSeconds = minutes * 60;
        remainingSeconds = initialSeconds;
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted && remainingSeconds! > 0) {
            setState(() => remainingSeconds = remainingSeconds! - 1);
          } else {
            timer.cancel();
          }
        });
      } else {
        setState(() => initialSeconds = remainingSeconds = null);
      }
    } else {
      setState(() => initialSeconds = remainingSeconds = null);
    }
  }

  @override
  void dispose() {
    // Dispose new controllers
    _gradientController.dispose();
    _burstController.dispose();
    // Existing logic
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      child: Stack(
        children: [
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const PanelHandle(),
                  const SizedBox(height: 24),
                  _Header(l10n: l10n, isTripOngoing: widget.isTripOngoing),
                  const SizedBox(height: 24),
                  _EtaDisplay(
                    l10n: l10n,
                    eta: widget.eta,
                    remainingSeconds: remainingSeconds,
                    initialSeconds: initialSeconds,
                  ),
                  const SizedBox(height: 24),
                  _DriverVehicleCard(booking: widget.booking),
                  const SizedBox(height: 16),
                  _TripDetailsCard(booking: widget.booking),
                  const SizedBox(height: 32),
                  _ActionButtons(
                    onContact: widget.onContact,
                    onOpenChat: widget.onOpenChat,
                    driverPhone: widget.booking?.driverPhone,
                  ),
                  const SizedBox(height: 16),
                  _CancelButton(
                    l10n: l10n,
                    isTripOngoing: widget.isTripOngoing,
                    onCancel: widget.onCancel,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                theme.colorScheme.secondary.withValues(alpha: 0.7),
                theme.colorScheme.surface,
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

// MARK: - Sub-Widgets for Panel Content

class _Header extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isTripOngoing;

  const _Header({required this.l10n, required this.isTripOngoing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          isTripOngoing
              ? l10n.driverOnWayEnRouteToDestination
              : l10n.driverOnWayDriverArriving,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFamily: 'PlayfairDisplay',
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isTripOngoing
              ? l10n.driverOnWayEnjoyYourRide
              : l10n.driverOnWayMeetAtPickup,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5);
  }
}

class _EtaDisplay extends StatelessWidget {
  final AppLocalizations l10n;
  final String eta;
  final int? remainingSeconds;
  final int? initialSeconds;

  const _EtaDisplay({
    required this.l10n,
    required this.eta,
    this.remainingSeconds,
    this.initialSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String timeText;
    double progressValue = 0.0;
    final hasCountdown =
        remainingSeconds != null &&
        initialSeconds != null &&
        initialSeconds! > 0;

    if (hasCountdown) {
      if (remainingSeconds! <= 0) {
        timeText = l10n.arrived.toUpperCase();
        progressValue = 1.0;
      } else {
        final minutes = remainingSeconds! ~/ 60;
        final seconds = remainingSeconds! % 60;
        timeText = '$minutes:${seconds.toString().padLeft(2, '0')}';
        progressValue = 1.0 - (remainingSeconds! / initialSeconds!);
      }
    } else {
      timeText = eta.capitalize();
    }

    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 2; i++)
            Animate(
              effects: [
                ScaleEffect(
                  delay: (i * 1500).ms,
                  duration: 3000.ms,
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.5, 1.5),
                  curve: Curves.easeInOut,
                ),
                FadeEffect(
                  delay: (i * 1500).ms,
                  duration: 3000.ms,
                  begin: 0.5,
                  end: 0,
                ),
              ],
              onPlay: (controller) => controller.repeat(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progressValue),
              duration: 1.seconds,
              curve: Curves.easeInOut,
              builder: (context, value, child) => CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.1,
                ),
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            ),
          ),
          AnimatedSwitcher(
            duration: 300.ms,
            child: Text(
              timeText,
              key: ValueKey(timeText),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface,
                fontSize: timeText.length > 5 ? 20 : 32,
                shadows: [
                  Shadow(blurRadius: 20.0, color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8));
  }
}

class _DriverVehicleCard extends StatelessWidget {
  final Booking? booking;
  const _DriverVehicleCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final driverName = booking?.assignedDriverName ?? 'N/A';
    final driverRating = booking?.driverRating?.toStringAsFixed(1) ?? 'N/A';
    final driverPhotoUrl = booking?.driverPhotoUrl;
    final driverEmail = booking?.assignedDriverEmail ?? 'N/A';
    final driverPhone = booking?.driverPhone ?? 'N/A';

    final vehicleDetails = booking?.assignedVehicleDetails;
    final vehiclePlate =
        vehicleDetails?['plate']?.toString().toUpperCase() ?? 'N/A';
    final vechilecolor =
        vehicleDetails?['color']?.toString().capitalize() ?? 'N/A';
    final vehicleModel = vehicleDetails?['model']?.toString() ?? 'Vehicle';

    final vehicleType = VehicleType.fromName(booking?.vehicleType ?? 'unknown');

    return _GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.1,
                ),
                backgroundImage:
                    driverPhotoUrl != null && driverPhotoUrl.isNotEmpty
                    ? NetworkImage(driverPhotoUrl)
                    : null,
                child: driverPhotoUrl == null || driverPhotoUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driverName, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(driverRating, style: theme.textTheme.titleMedium),
                        const Spacer(),
                        Text(
                          'ID: ${booking?.driverId ?? "N/A"}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          _CardDivider(),
          _DetailRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: driverEmail,
          ),
          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: driverPhone,
          ),
          _CardDivider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.shadowColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        vehiclePlate,
                        style: theme.textTheme.titleMedium?.copyWith(
                          letterSpacing: 2.0,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(vehicleModel, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(vechilecolor, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Image.asset(
                vehicleType.imagePath,
                width: 120,
                height: 60,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.4);
  }
}

class _TripDetailsCard extends StatelessWidget {
  final Booking? booking;
  const _TripDetailsCard({required this.booking});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      final difference = DateTime.now().difference(date);
      if (difference.inSeconds < 60) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'PlayfairDisplay',
              color: theme.colorScheme.primary,
            ),
          ),
          _CardDivider(),
          _DetailRow(
            icon: Icons.my_location,
            label: 'From',
            value: booking?.pickup.name ?? 'N/A',
          ),
          _DetailRow(
            icon: Icons.flag,
            label: 'To',
            value: booking?.dropoff.name ?? 'N/A',
          ),
          _CardDivider(),
          _DetailRow(
            icon: Icons.confirmation_number_outlined,
            label: 'Booking ID',
            value: booking?.id ?? 'N/A',
          ),
          _DetailRow(
            icon: Icons.route_outlined,
            label: 'Status',
            value: booking?.status.capitalize() ?? 'N/A',
          ),
          _DetailRow(
            icon: Icons.payments_outlined,
            label: 'Payment',
            value: booking?.paymentMethod.capitalize() ?? 'N/A',
          ),
          _DetailRow(
            icon: Icons.schedule,
            label: 'Booked At',
            value: _formatDate(booking?.createdAt),
          ),
          _DetailRow(
            icon: Icons.check_circle_outline,
            label: 'createdAt',
            value: _formatDate(booking?.createdAt),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.4);
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onContact;
  final VoidCallback onOpenChat;
  final String? driverPhone;

  const _ActionButtons({
    required this.onContact,
    required this.onOpenChat,
    this.driverPhone,
  });

  Future<void> _makeCall() async {
    if (driverPhone != null && driverPhone != "N/A") {
      final Uri phoneUri = Uri(scheme: 'tel', path: driverPhone);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    }
    onContact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ActionButton(
          icon: Icons.call,
          label: l10n.driverOnWayCall,
          onTap: _makeCall,
        ),
        _ActionButton(
          icon: Icons.forum_rounded,
          label: l10n.driverOnWayChat,
          onTap: onOpenChat,
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5);
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: 150.ms,
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(widget.label, style: theme.textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isTripOngoing;
  final VoidCallback onCancel;

  const _CancelButton({
    required this.l10n,
    required this.isTripOngoing,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSwitcher(
      duration: 300.ms,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: !isTripOngoing
          ? SizedBox(
              key: const ValueKey('cancelButton'),
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onCancel();
                },
                icon: const Icon(Icons.cancel_schedule_send),
                label: Text(l10n.driverOnWayCancelRide),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 700.ms)
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }
}

// MARK: - Reusable Helper Widgets

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            size: 18,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Divider(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        height: 1,
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
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
