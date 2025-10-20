// lib/widgets/animated_theme_toggle.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/theme_provider.dart';
import '../theme/color.dart';

class AnimatedThemeToggle extends StatefulWidget {
  final VoidCallback? onPressed;
  
  const AnimatedThemeToggle({
    super.key,
    this.onPressed,
  });

  @override
  State<AnimatedThemeToggle> createState() => _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends State<AnimatedThemeToggle>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _morphController;
  
  late Animation<double> _rotation;
  late Animation<double> _scale;
  late Animation<double> _morph;
  
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    
    // Rotation animation for the icon spin
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Pulse animation for the glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Morph animation for icon transformation
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _rotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _morph = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _morphController.dispose();
    super.dispose();
  }
  
  void _handlePress(ThemeProvider themeProvider) {
    if (_isTransitioning) return;
    
    setState(() {
      _isTransitioning = true;
    });
    
    // Get the global position of this widget
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final iconCenter = position + Offset(renderBox.size.width / 2, renderBox.size.height / 2);
    
    // Start the icon animations
    _rotationController.forward(from: 0);
    _morphController.forward(from: 0).then((_) {
      _morphController.reverse();
    });
    
    // Trigger theme change with animation
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    themeProvider.toggleThemeWithAnimation(!isDarkMode, iconCenter);
    
    // Call optional callback
    widget.onPressed?.call();
    
    // Reset transition state
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;
        
        return GestureDetector(
          onTap: () => _handlePress(themeProvider),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect behind the icon
                if (!isDark)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 40 * _scale.value,
                        height: 40 * _scale.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.sunYellow.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                
                // Main icon with rotation and morph
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _rotationController,
                    _morphController,
                    _pulseController,
                  ]),
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotation.value,
                      child: Transform.scale(
                        scale: 1.0 + (_morph.value * 0.2),
                        child: _buildIcon(isDark, _morph.value),
                      ),
                    );
                  },
                ),
                
                // Ray animation for sun
                if (!isDark && !_isTransitioning)
                  ...List.generate(8, (index) {
                    return AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final angle = (index * math.pi / 4);
                        final distance = 18 + (_scale.value * 3);
                        
                        return Transform.translate(
                          offset: Offset(
                            math.cos(angle) * distance,
                            math.sin(angle) * distance,
                          ),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.sunYellow.withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildIcon(bool isDark, double morphValue) {
    // Smooth transition between sun and moon icons
    return Stack(
      alignment: Alignment.center,
      children: [
        // Moon icon (visible in dark mode)
        Opacity(
          opacity: isDark ? 1.0 - morphValue : morphValue,
          child: Icon(
            isDark ? PhosphorIcons.moonFill : PhosphorIcons.moon,
            size: 28,
            color: isDark 
                ? AppColors.sunYellow
                : AppColors.textPrimary,
          ),
        ),
        // Sun icon (visible in light mode)
        Opacity(
          opacity: isDark ? morphValue : 1.0 - morphValue,
          child: Icon(
            isDark ? PhosphorIcons.sun : PhosphorIcons.sunFill,
            size: 28,
            color: isDark 
                ? AppColors.textPrimary
                : AppColors.sunsetOrange,
          ),
        ),
      ],
    );
  }
}

// Simplified theme toggle for other screens
class SimpleThemeToggle extends StatelessWidget {
  final double size;
  
  const SimpleThemeToggle({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;
        
        return IconButton(
          icon: Icon(
            isDark ? PhosphorIcons.sunFill : PhosphorIcons.moonFill,
            size: size,
            color: isDark ? AppColors.sunYellow : AppColors.nightNavy,
          ),
          onPressed: () {
            // Get icon position for animation
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final position = renderBox.localToGlobal(Offset.zero);
            final iconCenter = position + Offset(renderBox.size.width / 2, renderBox.size.height / 2);
            
            // Toggle with animation
            themeProvider.toggleThemeWithAnimation(!isDark, iconCenter);
          },
        );
      },
    );
  }
}
