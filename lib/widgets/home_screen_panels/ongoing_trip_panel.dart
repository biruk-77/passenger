// FILE: /lib/widgets/home_screen_panels/ongoing_trip_panel.dart
/* CRITICAL: DO NOT REMOVE OR ABBREVIATE. 
      This file must be delivered complete. 
      Any changes must preserve the exported public API. */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../theme/color.dart'; // THEME: ADDED IMPORT
import 'widgets.dart';

// --- THEME CONSTANTS REMOVED TO USE APP THEME ---

class OngoingTripPanelContent extends StatefulWidget {
  final Booking? booking;
  final VoidCallback onOpenChat;
  final VoidCallback onShareTrip;
  final String? etaToDestination;

  const OngoingTripPanelContent({
    super.key,
    required this.booking,
    required this.onOpenChat,
    required this.onShareTrip,
    this.etaToDestination,
  });

  @override
  State<OngoingTripPanelContent> createState() =>
      _OngoingTripPanelContentState();
}

class _OngoingTripPanelContentState extends State<OngoingTripPanelContent>
    with TickerProviderStateMixin {
  // STEP 2: ADDED ANIMATION CONTROLLERS
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  Timer? _timer;
  Duration _tripDuration = Duration.zero;
  String _animatedDots = ".";

  @override
  void initState() {
    super.initState();
    _initializeTimers();

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
  void didUpdateWidget(covariant OngoingTripPanelContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.booking?.id != oldWidget.booking?.id) {
      _initializeTimers();
    }
  }

  void _initializeTimers() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (widget.booking?.acceptedAt != null) {
          _tripDuration = DateTime.now().difference(
            widget.booking!.acceptedAt!,
          );
        }

        if (_animatedDots.length < 3) {
          _animatedDots += ".";
        } else {
          _animatedDots = ".";
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    // STEP 3: DISPOSED CONTROLLERS
    _gradientController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // --- ✅ DEBUGGING PRINT STATEMENT ---
    // This will run every time the panel updates.
    print(
      "😂😂😂😂😂--- [OngoingTripPanel] build() called. ETA received: ${widget.etaToDestination ?? '--- NULL ---'}",
    );

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias, // Ensures background respects corners
      // STEP 5: REPLACED OLD BACKGROUND WITH DECORATION FOR CLIPPING
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      // STEP 5: ADDED STACK FOR NEW BACKGROUND LAYERS
      child: Stack(
        children: [
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const PanelHandle(),
                const SizedBox(height: 24),
                _Header(
                  title: l10n.ongoingTripTitle,
                  destination:
                      widget.booking?.dropoff.name ?? 'Your Destination',
                ),
                const SizedBox(height: 24),
                _EtaDisplay(
                  animatedDots: _animatedDots,
                  tripDuration: _tripDuration,
                  l10n: l10n,
                  etaToDestination: widget.etaToDestination,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _DriverInfoCard(booking: widget.booking),
                      const SizedBox(height: 20),
                      _SafetyAndTools(
                        l10n: l10n,
                        onShareTrip: widget.onShareTrip,
                        onOpenChat: widget.onOpenChat,
                        driverPhone: widget.booking?.driverPhone,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // STEP 6: SYNCHRONIZED ANIMATION DELAY
    ).animate(delay: 1200.ms).fadeIn(duration: 400.ms);
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
                AppColors.primaryColor.withValues(alpha: 0.7),
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
                  AppColors.goldenrod.withValues(alpha: 0.3),
                  AppColors.primaryColor.withValues(alpha: 0.2),
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

// MARK: - Sub-Widgets (Updated to use AppTheme)

class _Header extends StatelessWidget {
  final String title;
  final String destination;

  const _Header({required this.title, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.flag, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  destination,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EtaDisplay extends StatelessWidget {
  final String animatedDots;
  final Duration tripDuration;
  final AppLocalizations l10n;
  final String? etaToDestination;

  const _EtaDisplay({
    required this.animatedDots,
    required this.tripDuration,
    required this.l10n,
    this.etaToDestination,
  });

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final bool hasEta = etaToDestination != null && etaToDestination != "...";

    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardBackground.withValues(alpha: 0.5),
            border: Border.all(color: Colors.white12, width: 2),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: 400.ms,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: hasEta
                  // --- WIDGET TO SHOW WHEN WE HAVE THE ETA ---
                  ? Column(
                      key: const ValueKey('eta_value'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Make ETA responsive to avoid oversized/overflow text
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            etaToDestination!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "ETA",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    )
                  // --- WIDGET TO SHOW WHEN WAITING FOR ETA ---
                  : Column(
                      key: const ValueKey('eta_loading'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            animatedDots,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        const Text(
                          "ETA",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_outlined,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.tripDuration}: ${_formatDuration(tripDuration)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DriverInfoCard extends StatelessWidget {
  final Booking? booking;
  const _DriverInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.background,
            backgroundImage:
                booking?.driverPhotoUrl != null &&
                    booking!.driverPhotoUrl!.isNotEmpty
                ? NetworkImage(booking!.driverPhotoUrl!)
                : null,
            child:
                booking?.driverPhotoUrl == null ||
                    booking!.driverPhotoUrl!.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking?.assignedDriverName ?? 'N/A',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppColors.goldenrod,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking?.driverRating?.toStringAsFixed(1) ?? 'N/A',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              booking?.assignedVehicleDetails?['plate'] ?? 'N/A',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyAndTools extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onShareTrip;
  final VoidCallback onOpenChat;
  final String? driverPhone;

  const _SafetyAndTools({
    required this.l10n,
    required this.onShareTrip,
    required this.onOpenChat,
    this.driverPhone,
  });

  Future<void> _makePhoneCall(BuildContext context) async {
    if (driverPhone == null || driverPhone!.isEmpty || driverPhone == "N/A") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.phoneNumberNotAvailable)));
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: driverPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotLaunch(launchUri.toString()))),
      );
    }
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          l10n.emergencyDialogTitle,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          l10n.emergencyDialogContent,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            child: Text(
              l10n.emergencyDialogCancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              l10n.emergencyDialogConfirm,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _makePhoneCall(
                context,
              ); // Replace with actual emergency number if needed
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            l10n.safetyAndTools,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ToolButton(
                icon: Icons.share_outlined,
                label: l10n.shareTrip,
                onTap: onShareTrip,
              ),
              _ToolButton(
                icon: Icons.message_outlined,
                label: l10n.driverOnWayChat,
                onTap: onOpenChat,
              ),
              _ToolButton(
                icon: Icons.call_outlined,
                label: l10n.driverOnWayCall,
                onTap: () => _makePhoneCall(context),
              ),
              _ToolButton(
                icon: Icons.sos,
                label: l10n.emergencySOS,
                onTap: () => _showEmergencyDialog(context),
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textSecondary;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
              border: Border.all(
                color: isDestructive ? AppColors.error : AppColors.borderColor,
              ),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
