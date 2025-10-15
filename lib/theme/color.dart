// lib/theme/color.dart
import 'package:flutter/material.dart';

class AppColors {
  // === PRIMARY BRAND PALETTE (FROM LOGO) ===
  static const Color primaryColor = Color(0xFF1A3762); // Deep Blue from Logo
  static const Color secondaryColor = Color(
    0xFF132A4A,
  ); // A darker shade for gradients
  static const Color accentColor = Color(
    0xFF2E5D9A,
  ); // A lighter shade for accents

  // === UI BACKGROUNDS (DARK THEME) ===
  static const Color background = Color(
    0xFF0F172A,
  ); // A very dark, slightly blue-tinted background
  static const Color cardBackground = Color(
    0xFF1E293B,
  ); // A lighter blue-grey for cards

  // === PRIMARY ACCENT COLOR ===
  static const Color goldenrod = Color(0xFFFFC107); // Rich gold/yellow
  static const Color accentGold = goldenrod;

  // === NEUTRALS ===
  static const Color textPrimary = Color(
    0xFFF1F5F9,
  ); // Slightly off-white for better readability
  static const Color textSecondary = Color(
    0xFF94A3B8,
  ); // Muted grey for subtitles
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
  static const Color brandBlue = primaryColor;
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
