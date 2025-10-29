// lib/theme/themes.dart
import 'package:flutter/material.dart';
import 'color.dart'; // Import your AppColors class

class AppThemes {
  /// --- DARK THEME ("NIGHT SESSION") - Windsurfing at Night ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    primaryColor: AppColors.primaryColor, // Ocean blue
    scaffoldBackgroundColor: AppColors.nightBackground, // Deep ocean background

    colorScheme: ColorScheme.dark(
      primary: AppColors.sunsetOrange, // Sunset orange for night actions
      secondary: AppColors.neonCyan, // Neon cyan accents
      surface: AppColors.nightCardBackground,
      onPrimary: Colors.black,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.black,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor:
          AppColors.cardBackground, // App bars will match the card color
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.goldenrod,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondaryColor.withValues(
        alpha: 0.5,
      ), // Use a darker shade for inputs
      hintStyle: const TextStyle(color: AppColors.textSubtle),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.goldenrod, width: 2),
      ),
    ),

    tabBarTheme: const TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: AppColors.goldenrod,
      labelColor: AppColors.goldenrod,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    ),
  );

  /// --- LIGHT THEME ("DAY SESSION") - Windsurfing in Daylight ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    primaryColor: AppColors.dayWater,
    scaffoldBackgroundColor: AppColors.dayBackground,
    colorScheme: ColorScheme.light(
      primary: AppColors.coralRed, // Coral red for day actions
      secondary: AppColors.sunYellow, // Sun yellow accents
      surface: AppColors.dayCardBackground,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.black87,
      error: AppColors.error,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0.5,
      iconTheme: IconThemeData(color: Colors.black87),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.goldenrod,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.05),
      hintStyle: const TextStyle(color: Colors.black45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryColor,
          width: 2,
        ), // Will use new color on focus
      ),
    ),
  );
}
