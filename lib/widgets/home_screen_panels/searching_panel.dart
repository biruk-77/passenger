/* CRITICAL: DO NOT REMOVE OR ABBREVIATE. 
      This file must be delivered complete. 
      Any changes must preserve the exported public API. */
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/vehicle_type.dart';
import '../../theme/color.dart'; // Keep for specific semantic colors
import 'widgets.dart';

// --- THEME CONSTANTS REMOVED ---

class SearchingPanelContent extends StatefulWidget {
  final VoidCallback onCancel;
  final String startAddress, destinationAddress;
  final VehicleType? selectedVehicle;
  final double estimatedPrice;
  final double searchRadiusKm;

  const SearchingPanelContent({
    super.key,
    required this.onCancel,
    required this.startAddress,
    required this.destinationAddress,
    this.selectedVehicle,
    required this.estimatedPrice,
    this.searchRadiusKm = 3.0,
  });

  @override
  State<SearchingPanelContent> createState() => _SearchingPanelContentState();
}

class _SearchingPanelContentState extends State<SearchingPanelContent>
    with TickerProviderStateMixin {
  // ✅ ADDED: Animation controllers for the new background
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  // --- Existing logic (UNCHANGED) ---
  late final AnimationController _radarController;
  Timer? _ellipsisTimer;
  String _ellipsis = "...";

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
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _ellipsisTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_ellipsis.length < 3) {
          _ellipsis += ".";
        } else {
          _ellipsis = ".";
        }
      });
    });
  }

  @override
  void dispose() {
    // ✅ DISPOSED: New background controllers
    _gradientController.dispose();
    _burstController.dispose();

    // --- Existing logic (UNCHANGED) ---
    _radarController.dispose();
    _ellipsisTimer?.cancel();
    super.dispose();
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

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      child: Stack(
        children: [
          // ✅ ADDED: New animated background
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),

          // Original Content
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PanelHandle(),
                const SizedBox(height: 24),
                Text(
                  '${l10n.searchingContactingDrivers}$_ellipsis',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'PlayfairDisplay',
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5),
                const SizedBox(height: 8),
                Text(
                  l10n.notificationSearchingBody(
                    widget.searchRadiusKm.toStringAsFixed(1),
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.7),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
                const SizedBox(height: 32),
                SizedBox(
                      height: 150,
                      width: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _RadarAnimation(controller: _radarController),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(
                                context,
                              ).colorScheme.background.withOpacity(0.8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.local_taxi,
                              color: Theme.of(
                                context,
                              ).colorScheme.onBackground.withOpacity(0.9),
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _TripDetailsCard(
                    startAddress: widget.startAddress,
                    destinationAddress: widget.destinationAddress,
                    selectedVehicle: widget.selectedVehicle,
                    estimatedPrice: widget.estimatedPrice,
                    currencyFormat: currencyFormat,
                    l10n: l10n,
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: _CancelButton(l10n: l10n, onCancel: widget.onCancel),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ COPIED: Helper widgets for the background
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

class _RadarAnimation extends StatelessWidget {
  final AnimationController controller;
  const _RadarAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RadarPainter(
            controller.value,
            Theme.of(context).colorScheme.primary,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RadarPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 4; i++) {
      final t = (progress + (i * 0.25)) % 1.0;
      final radius = maxRadius * t;
      final opacity = (1.0 - t * t).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _TripDetailsCard extends StatelessWidget {
  const _TripDetailsCard({
    required this.startAddress,
    required this.destinationAddress,
    required this.selectedVehicle,
    required this.estimatedPrice,
    required this.currencyFormat,
    required this.l10n,
  });

  final String startAddress;
  final String destinationAddress;
  final VehicleType? selectedVehicle;
  final double estimatedPrice;
  final NumberFormat currencyFormat;
  final AppLocalizations l10n;

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
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.my_location,
                title: l10n.searchingDetailFrom,
                value: startAddress,
                iconColor: AppColors.info,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 10.0,
                ),
                child: Divider(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  height: 1,
                ),
              ),
              _DetailRow(
                icon: Icons.flag_rounded,
                title: l10n.searchingDetailTo,
                value: destinationAddress,
                iconColor: AppColors.error,
              ),
              if (selectedVehicle != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(
                    color: theme.colorScheme.onSurface.withOpacity(0.1),
                    height: 1,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      selectedVehicle!.imagePath,
                      width: 80,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        selectedVehicle!.name.capitalize(),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      currencyFormat.format(estimatedPrice),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CancelButton extends StatefulWidget {
  final VoidCallback onCancel;
  final AppLocalizations l10n;

  const _CancelButton({required this.onCancel, required this.l10n});

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onCancel();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: 150.ms,
        curve: Curves.easeOut,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.error.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              widget.l10n.searchingCancelButton,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onBackground,
                letterSpacing: 0.5,
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
