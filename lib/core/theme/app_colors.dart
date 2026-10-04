import 'package:flutter/material.dart';

/// App Color Palette
/// Based on Material Design 3 with Indigo as primary color
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors - Indigo Palette
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryContainer = Color(0xFFE0E7FF); // Indigo 100
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFF312E81); // Indigo 800

  // Secondary Colors
  static const Color secondary = Color(0xFFEC4899); // Pink 500
  static const Color secondaryDark = Color(0xFFDB2777); // Pink 600
  static const Color secondaryLight = Color(0xFFF472B6); // Pink 400
  static const Color secondaryContainer = Color(0xFFFCE7F3); // Pink 100
  static const Color onSecondary = Colors.white;
  static const Color onSecondaryContainer = Color(0xFF831843); // Pink 900

  // Accent Colors
  static const Color accent = Color(0xFF10B981); // Emerald 500
  static const Color accentDark = Color(0xFF059669); // Emerald 600
  static const Color accentLight = Color(0xFF34D399); // Emerald 400

  // Neutral Colors - Background & Surface
  static const Color background = Color(0xFFF9FAFB); // Gray 50
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Gray 100
  static const Color onBackground = Color(0xFF111827); // Gray 900
  static const Color onSurface = Color(0xFF111827); // Gray 900
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Gray 500

  // Neutral Colors - Text
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray 400
  static const Color textDisabled = Color(0xFFD1D5DB); // Gray 300

  // Neutral Colors - Border & Divider
  static const Color border = Color(0xFFE5E7EB); // Gray 200
  static const Color divider = Color(0xFFE5E7EB); // Gray 200
  static const Color outline = Color(0xFFD1D5DB); // Gray 300
  static const Color outlineVariant = Color(0xFFF3F4F6); // Gray 100

  // Status Colors - Success
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFF34D399); // Emerald 400
  static const Color successDark = Color(0xFF059669); // Emerald 600
  static const Color successContainer = Color(0xFFD1FAE5); // Emerald 100
  static const Color onSuccess = Colors.white;

  // Status Colors - Warning
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFBBF24); // Amber 400
  static const Color warningDark = Color(0xFFD97706); // Amber 600
  static const Color warningContainer = Color(0xFFFEF3C7); // Amber 100
  static const Color onWarning = Color(0xFF78350F); // Amber 900

  // Status Colors - Error
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFF87171); // Red 400
  static const Color errorDark = Color(0xFFDC2626); // Red 600
  static const Color errorContainer = Color(0xFFFEE2E2); // Red 100
  static const Color onError = Colors.white;

  // Status Colors - Info
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFF60A5FA); // Blue 400
  static const Color infoDark = Color(0xFF2563EB); // Blue 600
  static const Color infoContainer = Color(0xFFDBEAFE); // Blue 100
  static const Color onInfo = Colors.white;

  // Dark Mode Colors (for future use)
  static const Color surfaceDark = Color(0xFF1F2937); // Gray 800
  static const Color surfaceDarkVariant = Color(0xFF111827); // Gray 900
  static const Color onSurfaceDark = Color(0xFFF9FAFB); // Gray 50
}

