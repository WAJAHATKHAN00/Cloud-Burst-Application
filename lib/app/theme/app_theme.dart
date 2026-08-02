import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Design tokens ──────────────────────────────────────────────
  static const Color ink = Color(0xFF12181F);
  static const Color slate = Color(0xFF5B6570);
  static const Color paper = Color(0xFFF5F6F4);
  static const Color divider = Color(0xFFC9CCC7);
  static const Color hazardRed = Color(0xFFC1541A);
  static const Color moderateOchre = Color(0xFFB8722A);
  static const Color safeTeal = Color(0xFF0E7A82);

  /// Returns the severity color for a risk label string.
  static Color severityColor(String risk) {
    final r = risk.toUpperCase();
    if (r.contains('HIGH')) return hazardRed;
    if (r.contains('MODERATE')) return moderateOchre;
    return safeTeal;
  }

  // ── Typography helpers ─────────────────────────────────────────
  static TextTheme _buildTextTheme() {
    final base = GoogleFonts.ibmPlexSansTextTheme();
    return base.copyWith(
      // Hero number (risk dial percentage)
      displayLarge: GoogleFonts.ibmPlexMono(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: ink,
        height: 1.1,
      ),
      // Screen titles
      titleLarge: GoogleFonts.ibmPlexSans(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: ink,
        letterSpacing: 0.3,
      ),
      titleMedium: GoogleFonts.ibmPlexSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      titleSmall: GoogleFonts.ibmPlexSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      // Body text
      bodyLarge: GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodyMedium: GoogleFonts.ibmPlexSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodySmall: GoogleFonts.ibmPlexSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: slate,
      ),
      // Micro-labels (uppercase tracked)
      labelLarge: GoogleFonts.ibmPlexSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: ink,
        letterSpacing: 1.0,
      ),
      labelMedium: GoogleFonts.ibmPlexSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: slate,
        letterSpacing: 1.0,
      ),
      labelSmall: GoogleFonts.ibmPlexSans(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: slate,
        letterSpacing: 0.8,
      ),
    );
  }

  /// Mono style for numeric data (percentages, mm, meters, coordinates, etc.)
  static TextStyle mono({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color color = ink,
    double? height,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Tracked uppercase micro-label style.
  static TextStyle microLabel({
    double fontSize = 10,
    Color color = slate,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: fontSize * 0.08,
    );
  }

  // ── Theme data ─────────────────────────────────────────────────
  static ThemeData light() {
    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: ink,
        onPrimary: paper,
        secondary: slate,
        surface: paper,
        onSurface: ink,
        error: hazardRed,
      ),
      scaffoldBackgroundColor: paper,
      dividerColor: divider,
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 0.5,
        space: 0,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: paper,
        foregroundColor: ink,
        centerTitle: false,
        iconTheme: const IconThemeData(color: ink, size: 22),
        titleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: slate,
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: paper,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: divider, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 12,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: divider, width: 0.5),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: divider, width: 0.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: ink, width: 1.0),
        ),
        hintStyle: GoogleFonts.ibmPlexSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: slate,
        ),
        labelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: slate,
          letterSpacing: 1.0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: paper,
          elevation: 0,
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          elevation: 0,
          side: const BorderSide(color: ink, width: 0.5),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: ink, size: 22);
          }
          return const IconThemeData(color: slate, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.ibmPlexSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: ink,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.ibmPlexSans(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: slate,
            letterSpacing: 0.5,
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ink,
        linearTrackColor: divider,
        linearMinHeight: 3,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: paper,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
