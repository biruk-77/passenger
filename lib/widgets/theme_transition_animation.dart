// lib/widgets/theme_transition_animation.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeTransitionAnimation extends StatefulWidget {
  final Widget child;
  
  const ThemeTransitionAnimation({
    super.key,
    required this.child,
  });

  @override
  State<ThemeTransitionAnimation> createState() => _ThemeTransitionAnimationState();
}

class _ThemeTransitionAnimationState extends State<ThemeTransitionAnimation>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _sunriseController;
  late AnimationController _sunsetController;
  late AnimationController _starsController;
  late AnimationController _waterCausticController;
  
  // Animations
  late Animation<double> _sunriseRadialProgress;
  late Animation<double> _sunsetWaveProgress;
  
  // State
  bool _isAnimating = false;
  Offset _iconPosition = Offset.zero;
  bool _isDarkMode = false;
  
  // Particles for extra visual effects
  final List<_StarParticle> _stars = [];
  final List<_WaveParticle> _waves = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _sunriseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _sunsetController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _waterCausticController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    
    // Setup animations with custom curves
    _sunriseRadialProgress = CurvedAnimation(
      parent: _sunriseController,
      curve: Curves.easeOutCubic,
    );
    
    _sunsetWaveProgress = CurvedAnimation(
      parent: _sunsetController,
      curve: Curves.easeInOutCubic,
    );
    
    // Generate stars for night sky
    _generateStars();
    _generateWaves();
    
    // Listen to theme changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = context.read<ThemeProvider>();
      _isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    });
  }
  
  void _generateStars() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _stars.add(_StarParticle(
        position: Offset(
          random.nextDouble(),
          random.nextDouble() * 0.5, // Top half of screen
        ),
        size: random.nextDouble() * 3 + 1,
        twinkleSpeed: random.nextDouble() * 2 + 1,
      ));
    }
  }
  
  void _generateWaves() {
    for (int i = 0; i < 3; i++) {
      _waves.add(_WaveParticle(
        phase: i * (math.pi / 3),
        amplitude: 20.0 + (i * 10),
        speed: 0.5 + (i * 0.2),
      ));
    }
  }
  
  @override
  void dispose() {
    _sunriseController.dispose();
    _sunsetController.dispose();
    _starsController.dispose();
    _waterCausticController.dispose();
    super.dispose();
  }
  
  void _triggerSunrise(Offset iconPos) {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
      _iconPosition = iconPos;
      _isDarkMode = false;
    });
    
    _sunriseController.forward(from: 0).then((_) {
      setState(() {
        _isAnimating = false;
      });
    });
  }
  
  void _triggerSunset(Offset iconPos) {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
      _iconPosition = iconPos;
      _isDarkMode = true;
    });
    
    _sunsetController.forward(from: 0).then((_) {
      setState(() {
        _isAnimating = false;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        // Listen for theme changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (themeProvider.animationTrigger != null && !_isAnimating) {
            final trigger = themeProvider.animationTrigger!;
            if (trigger.isDarkToLight) {
              _triggerSunrise(trigger.iconPosition);
            } else {
              _triggerSunset(trigger.iconPosition);
            }
            themeProvider.clearAnimationTrigger();
          }
        });
        
        return Stack(
          alignment: Alignment.topLeft, // Fix directionality issue
          children: [
            // Main content
            widget.child,
            
            // Night sky overlay with stars (only visible during transition or in dark mode)
            if (_isDarkMode || _isAnimating)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _starsController,
                    _sunriseController,
                    _sunsetController,
                  ]),
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _StarsPainter(
                        stars: _stars,
                        animationValue: _starsController.value,
                        opacity: _isDarkMode 
                            ? (_isAnimating 
                                ? 1.0 - _sunriseController.value
                                : 1.0)
                            : _sunsetController.value,
                      ),
                    );
                  },
                ),
              ),
            
            // Water caustics effect at bottom (dark mode only)
            if (_isDarkMode || _isAnimating)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 200,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _waterCausticController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: _WaterCausticsPainter(
                          animationValue: _waterCausticController.value,
                          opacity: _isDarkMode 
                              ? (_isAnimating 
                                  ? 1.0 - _sunriseController.value
                                  : 0.7)
                              : _sunsetController.value * 0.7,
                        ),
                      );
                    },
                  ),
                ),
              ),
            
            // Sunrise radial explosion effect
            if (_isAnimating && !_isDarkMode)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _sunriseController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _SunrisePainter(
                        center: _iconPosition.translate(0, -50),
                        progress: _sunriseRadialProgress.value,
                      ),
                    );
                  },
                ),
              ),
            
            // Sunset wave effect
            if (_isAnimating && _isDarkMode)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _sunsetController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _SunsetPainter(
                        progress: _sunsetWaveProgress.value,
                        waves: _waves,
                      ),
                    );
                  },
                ),
              ),
            
            // Floating sun/moon particles during transition
            if (_isAnimating)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _isDarkMode ? _sunsetController : _sunriseController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _FloatingParticlesPainter(
                        center: _iconPosition,
                        progress: _isDarkMode 
                            ? _sunsetController.value 
                            : _sunriseController.value,
                        isDarkMode: _isDarkMode,
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

// Star particle class
class _StarParticle {
  final Offset position;
  final double size;
  final double twinkleSpeed;
  
  _StarParticle({
    required this.position,
    required this.size,
    required this.twinkleSpeed,
  });
}

// Wave particle class
class _WaveParticle {
  final double phase;
  final double amplitude;
  final double speed;
  
  _WaveParticle({
    required this.phase,
    required this.amplitude,
    required this.speed,
  });
}

// Stars painter
class _StarsPainter extends CustomPainter {
  final List<_StarParticle> stars;
  final double animationValue;
  final double opacity;
  
  _StarsPainter({
    required this.stars,
    required this.animationValue,
    required this.opacity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity);
    
    for (final star in stars) {
      final twinkle = math.sin(animationValue * star.twinkleSpeed * 2 * math.pi);
      final currentOpacity = (0.3 + twinkle * 0.7) * opacity;
      
      paint.color = Colors.white.withValues(alpha: currentOpacity);
      
      canvas.drawCircle(
        Offset(star.position.dx * size.width, star.position.dy * size.height),
        star.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.opacity != opacity;
  }
}

// Water caustics painter
class _WaterCausticsPainter extends CustomPainter {
  final double animationValue;
  final double opacity;
  
  _WaterCausticsPainter({
    required this.animationValue,
    required this.opacity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF004080).withValues(alpha: 0),
          const Color(0xFF004080).withValues(alpha: opacity * 0.1),
          const Color(0xFF0059B2).withValues(alpha: opacity * 0.2),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Draw animated caustic waves
    final path = Path();
    for (int i = 0; i < 3; i++) {
      path.moveTo(0, size.height * (0.3 + i * 0.2));
      
      for (double x = 0; x <= size.width; x += 10) {
        final y = size.height * (0.3 + i * 0.2) + 
                  math.sin((x / 100) + (animationValue * math.pi * 2) + (i * math.pi / 3)) * 15;
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant _WaterCausticsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.opacity != opacity;
  }
}

// Sunrise radial explosion painter
class _SunrisePainter extends CustomPainter {
  final Offset center;
  final double progress;
  
  _SunrisePainter({
    required this.center,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    // Calculate the maximum radius needed to cover the entire screen
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);
    final currentRadius = maxRadius * progress;
    
    // Create multi-ring gradient for sunrise effect
    final gradient = RadialGradient(
      center: Alignment.center,
      colors: [
        const Color(0xFFFF6B35), // Intense orange core
        const Color(0xFFFFA500), // Golden yellow
        const Color(0xFFFFD700), // Bright gold
        const Color(0xFFFFF8DC), // Soft white at edge
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.5, 0.8, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: currentRadius),
      )
      ..style = PaintingStyle.fill;
    
    // Draw the expanding sunrise circle
    canvas.drawCircle(center, currentRadius, paint);
    
    // Add sun rays
    if (progress > 0.3) {
      final rayPaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.3 * (1 - progress))
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      for (int i = 0; i < 12; i++) {
        final angle = (i * math.pi / 6) + (progress * math.pi / 4);
        final startRadius = currentRadius * 0.5;
        final endRadius = currentRadius * 1.5;
        
        canvas.drawLine(
          center + Offset(math.cos(angle) * startRadius, math.sin(angle) * startRadius),
          center + Offset(math.cos(angle) * endRadius, math.sin(angle) * endRadius),
          rayPaint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant _SunrisePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Sunset wave painter
class _SunsetPainter extends CustomPainter {
  final double progress;
  final List<_WaveParticle> waves;
  
  _SunsetPainter({
    required this.progress,
    required this.waves,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    // Draw rising dark wave from bottom
    final waveHeight = size.height * progress;
    
    // Create gradient for the night tide
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFF001A33), // Deep navy at bottom
        const Color(0xFF002D5C), // Slightly lighter navy
        const Color(0xFF004080).withOpacity(0.8), // Grace's blue
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 0.8, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, size.height - waveHeight, size.width, waveHeight),
      );
    
    // Draw wave path with smooth curves
    final path = Path()
      ..moveTo(0, size.height);
    
    // Create wave effect at the top of the rising tide
    for (double x = 0; x <= size.width; x += 1) {
      final waveY = size.height - waveHeight + 
                    math.sin(x / 50 + progress * math.pi) * 20 * (1 - progress * 0.5);
      path.lineTo(x, waveY);
    }
    
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    
    canvas.drawPath(path, paint);
    
    // Add foam effect at wave top
    if (progress > 0.2) {
      final foamPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3 * (1 - progress))
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      final foamPath = Path()
        ..moveTo(0, size.height - waveHeight);
      
      for (double x = 0; x <= size.width; x += 1) {
        final foamY = size.height - waveHeight + 
                      math.sin(x / 30 + progress * math.pi * 2) * 10;
        foamPath.lineTo(x, foamY);
      }
      
      canvas.drawPath(foamPath, foamPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant _SunsetPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Floating particles painter
class _FloatingParticlesPainter extends CustomPainter {
  final Offset center;
  final double progress;
  final bool isDarkMode;
  
  _FloatingParticlesPainter({
    required this.center,
    required this.progress,
    required this.isDarkMode,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final random = math.Random(42); // Fixed seed for consistent particles
    
    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = random.nextDouble() * 150 * progress;
      final particleSize = random.nextDouble() * 4 + 2;
      
      final position = center + Offset(
        math.cos(angle) * distance,
        math.sin(angle) * distance - progress * 50, // Float upward
      );
      
      final paint = Paint()
        ..color = isDarkMode
            ? Colors.blue.withValues(alpha: 0.6 * (1 - progress))
            : Colors.orange.withValues(alpha: 0.6 * (1 - progress));
      
      canvas.drawCircle(position, particleSize, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
