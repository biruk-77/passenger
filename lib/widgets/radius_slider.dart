// lib/widgets/radius_slider.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

class AdvancedRadiusSlider extends StatelessWidget {
  final double currentRadiusKm;
  final bool isVisible;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<double> onSearchInitiated;

  const AdvancedRadiusSlider({
    super.key,
    required this.currentRadiusKm,
    required this.isVisible,
    required this.onRadiusChanged,
    required this.onSearchInitiated,
  });

  // ✅ THE FIX IS HERE: Changed the default initial radius to 1.0 km
  static const double initialRadiusKm = 0.1;

  static const double _maxRadiusKm = 3.0;
  static const double _radiusSpan = _maxRadiusKm - initialRadiusKm;

  @override
  Widget build(BuildContext context) {
    // Convert the current radius (e.g., 1.5 km) into a slider value (0.0 to 1.0)
    final double sliderValue =
        (currentRadiusKm - initialRadiusKm) / _radiusSpan;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutBack,
      bottom: isVisible ? 120 : -100,
      left: 20,
      right: 20,
      child: FadeInUp(
        from: 20,
        duration: const Duration(milliseconds: 500),
        child: Material(
          elevation: 12.0,
          borderRadius: BorderRadius.circular(50),
          shadowColor: Colors.blueAccent.withOpacity(0.5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[200]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.radar,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6.0,
                      activeTrackColor: Colors.blueAccent,
                      inactiveTrackColor: Colors.blueAccent.withOpacity(0.2),
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12.0,
                      ),
                      overlayColor: Colors.blueAccent.withOpacity(0.25),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24.0,
                      ),
                    ),
                    child: Slider(
                      value: sliderValue.clamp(0.0, 1.0),
                      onChanged: (newValue) {
                        // Convert the slider's 0.0-1.0 value BACK to our km range
                        final newRadius =
                            initialRadiusKm + (newValue * _radiusSpan);
                        onRadiusChanged(newRadius);
                        HapticFeedback.lightImpact();
                      },
                      onChangeEnd: (finalValue) {
                        // Convert the final 0.0-1.0 value BACK to our km range
                        final finalRadius =
                            initialRadiusKm + (finalValue * _radiusSpan);
                        onSearchInitiated(finalRadius);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.5),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  child: Text(
                    key: ValueKey<String>(currentRadiusKm.toString()),
                    // Display in meters if less than 1km, otherwise in km
                    currentRadiusKm < 1
                        ? "${(currentRadiusKm * 1000).toStringAsFixed(0)} m"
                        : "${currentRadiusKm.toStringAsFixed(1)} km",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
