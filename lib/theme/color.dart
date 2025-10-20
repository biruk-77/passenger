// lib/theme/color.dart
import 'package:flutter/material.dart';

class AppColors {
  // === WINDSURFING THEME COLORS ===
  // Ocean blue - primary color from Grace #004080
  static const Color primaryColor = Color(0xFF004080);
  
  // Deep ocean - for night mode water
  static const Color deepOcean = Color(0xFF001A33);
  
  // Night navy - darker shade for night sky
  static const Color nightNavy = Color(0xFF002D5C);
  
  // Bright ocean - vibrant shade for day mode accents
  static const Color brightOcean = Color(0xFF0059B2);
  
  // === DAY MODE ("Day Session") COLORS ===
  static const Color dayBackground = Color(0xFFF0F7FF); // Light sky blue-white
  static const Color daySky = Color(0xFF87CEEB); // Sky blue
  static const Color daySand = Color(0xFFF5E6D3); // Sandy beige
  static const Color dayCardBackground = Colors.white;
  static const Color dayWater = Color(0xFF4A90E2); // Bright water blue
  
  // === NIGHT MODE ("Night Session") COLORS ===
  static const Color nightBackground = deepOcean; // Deep ocean background
  static const Color nightSky = Color(0xFF0F172A); // Dark night sky
  static const Color nightCardBackground = Color(0xFF1E293B); // Dark card
  static const Color nightWater = primaryColor; // Ocean blue for water
  
  // === UI BACKGROUNDS ===
  static const Color background = nightSky;
  static const Color cardBackground = nightCardBackground;
  
  // === ACCENT COLORS ===
  static const Color sunsetOrange = Color(0xFFFF6B35); // Sunset/sunrise orange
  static const Color neonCyan = Color(0xFF18FFFF); // Night mode accent
  static const Color coralRed = Color(0xFFFF7F50); // Day mode accent
  static const Color sunYellow = Color(0xFFFFD700); // Bright sun yellow

  // === PRIMARY ACCENT COLOR ===
  static const Color goldenrod = Color(0xFFFFC107); // Rich gold/yellow
  static const Color accentGold = goldenrod;
  
  // Windsurfing theme accent
  static const Color secondaryColor = nightNavy;
  static const Color accentColor = brightOcean;

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
