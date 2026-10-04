/// App Spacing System
/// Base unit: 4px
/// Follows 4px grid system for consistent spacing
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Base unit
  static const double baseUnit = 4.0;

  // Spacing values
  static const double xs = 4.0;   // 1x base unit
  static const double sm = 8.0;    // 2x base unit
  static const double md = 16.0;   // 4x base unit
  static const double lg = 24.0;  // 6x base unit
  static const double xl = 32.0;  // 8x base unit
  static const double xxl = 48.0; // 12x base unit
  static const double xxxl = 64.0; // 16x base unit

  // Common spacing patterns
  static const double paddingSmall = sm;      // 8px
  static const double paddingMedium = md;     // 16px
  static const double paddingLarge = lg;      // 24px
  static const double paddingXLarge = xl;     // 32px

  static const double marginSmall = sm;       // 8px
  static const double marginMedium = md;      // 16px
  static const double marginLarge = lg;      // 24px
  static const double marginXLarge = xl;     // 32px

  // Gap spacing (for Column/Row spacing)
  static const double gapSmall = sm;          // 8px
  static const double gapMedium = md;         // 16px
  static const double gapLarge = lg;          // 24px
  static const double gapXLarge = xl;         // 32px

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull = 9999.0; // For circular shapes
}

