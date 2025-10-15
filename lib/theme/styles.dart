// lib/theme/styles.dart
import 'package:flutter/material.dart';
import 'color.dart';

class AppTextStyles {
  // --- Titles for Screens and Panels ---
  static const TextStyle screenTitle = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w600, // Slightly less bold for a cleaner look
    fontSize: 22,
  );

  static const TextStyle panelTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // --- Styles for Cards ---
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static const TextStyle cardSubtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );

  // --- Text for Buttons ---
  static const TextStyle buttonText = TextStyle(
    color: Colors.black, // Text on goldenrod buttons
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  // --- Subtitles and Body Text ---
  static const TextStyle panelSubtitle = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}
