// lib/widgets/tapped_place_panel.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/search_result.dart';

// ✅ CONVERTED TO STATEFULWIDGET FOR ANIMATIONS
class TappedPlacePanel extends StatefulWidget {
  final PlaceDetails place;
  final VoidCallback onGoToDestination;
  final VoidCallback onClear;

  const TappedPlacePanel({
    super.key,
    required this.place,
    required this.onGoToDestination,
    required this.onClear,
  });

  @override
  State<TappedPlacePanel> createState() => _TappedPlacePanelState();
}

class _TappedPlacePanelState extends State<TappedPlacePanel>
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.all(16.0),
          clipBehavior: Clip.antiAlias, // ✅ ADDED FOR BACKGROUND CLIPPING
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // ✅ ADDED NEW BACKGROUND
              _buildAnimatedGradientBackground(),
              _buildCornerBurstEffect(),

              // Original Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.place.primaryText,
                            style: theme.textTheme.titleLarge, // ✅ THEME-AWARE
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ), // ✅ THEME-AWARE
                          onPressed: widget.onClear,
                        ),
                      ],
                    ),
                    if (widget.place.secondaryText != null &&
                        widget.place.secondaryText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          widget.place.secondaryText!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ), // ✅ THEME-AWARE
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onGoToDestination,
                        icon: const Icon(Icons.directions_car_filled_rounded),
                        label: const Text("Go to this destination"),
                        // ✅ THEME-AWARE: Style is now inherited from ElevatedButtonTheme
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ HELPER WIDGETS COPIED FROM TEMPLATE
  Widget _buildAnimatedGradientBackground() {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: AnimatedBuilder(
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
      ),
    );
  }

  Widget _buildCornerBurstEffect() {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: AnimatedBuilder(
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
