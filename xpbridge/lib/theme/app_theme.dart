import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===========================================
  // COLOR SYSTEM - Warm Neutral + Electric Teal
  // ===========================================

  // Base colors
  static const Color background = Color(0xFFF7F7F5);      // Off-white base
  static const Color surface = Color(0xFFFFFFFF);          // Pure white for cards
  static const Color cardBackground = Color(0xFFE8E6E3);   // Warm gray for sections

  // Primary accent
  static const Color primary = Color(0xFF2EC4B6);          // Electric teal
  static const Color primaryDark = Color(0xFF159A8C);      // Teal dark/hover
  static const Color primaryLight = Color(0xFF2EC4B6);     // Alias for compatibility

  // Text colors
  static const Color text = Color(0xFF1F2933);             // Primary text
  static const Color textSecondary = Color(0xFF52606D);    // Secondary text
  static const Color textMuted = Color(0xFF9AA5B1);        // Muted text

  // Semantic colors
  static const Color success = Color(0xFF6EE7B7);          // Success/Progress
  static const Color successDark = Color(0xFF10B981);      // Darker success
  static const Color error = Color(0xFFEF4444);            // Error
  static const Color warning = Color(0xFFF59E0B);          // Warning

  // Design tokens
  static const double cornerRadius = 16;
  static const double cornerRadiusSmall = 12;
  static const double cornerRadiusLarge = 24;

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1F2933).withValues(alpha: 0.06),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF1F2933).withValues(alpha: 0.08),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF1F2933).withValues(alpha: 0.04),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: surface,
        primary: primary,
        onPrimary: Colors.white,
        secondary: primaryDark,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: text,
        displayColor: text,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: text,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        shadowColor: const Color(0xFF1F2933).withValues(alpha: 0.08),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          elevation: 0,
          shadowColor: primary.withValues(alpha: 0.25),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          side: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusSmall),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        selectedColor: primary.withValues(alpha: 0.15),
        backgroundColor: cardBackground,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: textMuted),
        labelStyle: TextStyle(color: textSecondary),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
        trackHeight: 6,
        activeTrackColor: primary,
        inactiveTrackColor: cardBackground,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.2),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: cardBackground,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: text,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Extension for easy color access with opacity
extension ColorWithOpacity on Color {
  Color get light => withValues(alpha: 0.1);
  Color get medium => withValues(alpha: 0.2);
  Color get soft => withValues(alpha: 0.05);
}
