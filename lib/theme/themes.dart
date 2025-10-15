// lib/theme/themes.dart
import 'package:flutter/material.dart';
import 'color.dart'; // Import your AppColors class

class AppThemes {
  /// --- DARK THEME (UPDATED TO MATCH LOGO) ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins', // Using Poppins as a modern default
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor:
        AppColors.background, // Use the new dark blue background

    colorScheme: const ColorScheme.dark(
      primary:
          AppColors.goldenrod, // Goldenrod remains the primary action color
      secondary: AppColors.accentColor,
      background: AppColors.background,
      surface: AppColors
          .cardBackground, // Cards will have the lighter blue-grey color
      onPrimary: Colors.black,
      onSecondary: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
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
      fillColor: AppColors.secondaryColor.withOpacity(
        0.5,
      ), // Use a darker shade for inputs
      hintStyle: const TextStyle(color: AppColors.textSubtle),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
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
    ), // ✅ THIS IS NOW A COMMA
  ); // ✅ AND THIS IS THE CORRECT CLOSING );

  /// --- LIGHT THEME ---
  /// A professional light theme that complements your brand colors.
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    primaryColor: Colors.white,
    scaffoldBackgroundColor: const Color(0xFFF4F6F8),
    colorScheme: const ColorScheme.light(
      primary: AppColors.goldenrod,
      secondary: AppColors.primaryColor,
      background: Color(0xFFF4F6F8),
      surface: Colors.white,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onBackground: Colors.black87,
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
      fillColor: Colors.black.withOpacity(0.05),
      hintStyle: const TextStyle(color: Colors.black45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
    ),
  );
}
