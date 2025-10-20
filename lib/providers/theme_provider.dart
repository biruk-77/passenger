// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

// Animation trigger data class
class ThemeAnimationTrigger {
  final bool isDarkToLight;
  final Offset iconPosition;
  final DateTime timestamp;
  
  ThemeAnimationTrigger({
    required this.isDarkToLight,
    required this.iconPosition,
  }) : timestamp = DateTime.now();
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark theme
  ThemeAnimationTrigger? _animationTrigger;
  bool _isAnimating = false;

  ThemeMode get themeMode => _themeMode;
  ThemeAnimationTrigger? get animationTrigger => _animationTrigger;
  bool get isAnimating => _isAnimating;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Enhanced theme toggle with animation support
  void toggleThemeWithAnimation(bool isDark, Offset iconPosition) {
    if (_isAnimating) return; // Prevent multiple animations
    
    _isAnimating = true;
    
    // Create animation trigger
    _animationTrigger = ThemeAnimationTrigger(
      isDarkToLight: !isDark, // Invert because we're transitioning TO the new state
      iconPosition: iconPosition,
    );
    
    // Delay theme change to sync with animation
    Future.delayed(const Duration(milliseconds: 400), () {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    });
    
    // Reset animation state after animation completes
    Future.delayed(const Duration(milliseconds: 1200), () {
      _isAnimating = false;
      notifyListeners();
    });
    
    notifyListeners();
  }
  
  // Legacy toggle method (without animation)
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  
  // Clear animation trigger after it's been processed
  void clearAnimationTrigger() {
    _animationTrigger = null;
  }
}
