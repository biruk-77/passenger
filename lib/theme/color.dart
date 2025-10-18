// lib/theme/color.dart
import 'package:flutter/material.dart';

class AppColors {
  // === PRIMARY BRAND PALETTE (FROM LOGO) ===
  // ✅ UPDATED: New primary color based on #004080
  static const Color primaryColor = Color(0xFF004080);

  // ✅ UPDATED: A darker shade of the new primary for gradients and depth
  static const Color secondaryColor = Color(0xFF002D5C);

  // ✅ UPDATED: A lighter, more vibrant shade for accents
  static const Color accentColor = Color(0xFF0059B2);

  // === UI BACKGROUNDS (DARK THEME) ===
  // These still work well with the new primary color
  static const Color background = Color(0xFF0F172A);
  static const Color cardBackground = Color(0xFF1E293B);

  // === PRIMARY ACCENT COLOR ===
  static const Color goldenrod = Color(0xFFFFC107); // Rich gold/yellow
  static const Color accentGold = goldenrod;

  // === NEUTRALS ===
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textSubtle = Color(0xFF64748B);
  static const Color iconColor = Color(0xFFE2E8F0);
  static const Color borderColor = Color(0xFF334155);

  // === SEMANTIC / STATUS COLORS ===
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFACC15);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // Aliases for compatibility with UI code
  static const Color statusActive = success;
  static const Color statusPending = warning;
  static const Color statusError = error;

  // === LEGACY & COMPATIBILITY ===
  static const Color brandBlue =
      primaryColor; // This now points to the new color
  static const Color brandWhite = textPrimary;
  static const Color vibrantYellow = Color(0xFFFFD600);
  static const Color electricLime = Color(0xFFCCFF00);
  static const Color brightOrange = Color(0xFFFF9800);
  static const Color coralPink = Color(0xFFFF7F50);
  static const Color hotPink = Color(0xFFFF4081);
  static const Color skyBlue = Color(0xFF81D4FA);
  static const Color electricCyan = Color(0xFF18FFFF);
  static const Color brightRed = Color(0xFFFF5252);
  static const Color lightCobalt = Color(0xFFF0F5FF);
}
