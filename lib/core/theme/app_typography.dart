import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Typography System
/// Based on Material Design 3 Typography Scale
class AppTypography {
  AppTypography._(); // Private constructor to prevent instantiation

  /// Get TextTheme for the app
  static TextTheme getTextTheme() {
    return const TextTheme(
      // Display styles - for large hero text
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 64 / 57,
        color: AppColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 52 / 45,
        color: AppColors.textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 44 / 36,
        color: AppColors.textPrimary,
      ),

      // Headline styles - for section titles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 40 / 32,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 36 / 28,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 32 / 24,
        color: AppColors.textPrimary,
      ),

      // Title styles - for card titles, list items
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 28 / 22,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 24 / 16,
        color: AppColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
        color: AppColors.textPrimary,
      ),

      // Body styles - for paragraphs, descriptions
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 24 / 16,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 20 / 14,
        color: AppColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 16 / 12,
        color: AppColors.textSecondary,
      ),

      // Label styles - for buttons, labels, captions
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
        color: AppColors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 12,
        color: AppColors.textPrimary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 11,
        color: AppColors.textSecondary,
      ),
    );
  }

  // Helper methods for common text styles
  static TextStyle get displayLarge => getTextTheme().displayLarge!;
  static TextStyle get displayMedium => getTextTheme().displayMedium!;
  static TextStyle get displaySmall => getTextTheme().displaySmall!;

  static TextStyle get headlineLarge => getTextTheme().headlineLarge!;
  static TextStyle get headlineMedium => getTextTheme().headlineMedium!;
  static TextStyle get headlineSmall => getTextTheme().headlineSmall!;

  static TextStyle get titleLarge => getTextTheme().titleLarge!;
  static TextStyle get titleMedium => getTextTheme().titleMedium!;
  static TextStyle get titleSmall => getTextTheme().titleSmall!;

  static TextStyle get bodyLarge => getTextTheme().bodyLarge!;
  static TextStyle get bodyMedium => getTextTheme().bodyMedium!;
  static TextStyle get bodySmall => getTextTheme().bodySmall!;

  static TextStyle get labelLarge => getTextTheme().labelLarge!;
  static TextStyle get labelMedium => getTextTheme().labelMedium!;
  static TextStyle get labelSmall => getTextTheme().labelSmall!;
}

