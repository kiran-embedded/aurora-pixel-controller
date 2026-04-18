import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../engine/display_engine.dart';

class AppTheme {
  // Absolute AMOLED Deep Dark (Fixed as per user request)
  static const Color background = Color(0xFF020202);
  
  // Dynamic Neon Mapping
  static Color getHighlight(NeonTheme theme) {
    switch (theme) {
      case NeonTheme.cyberCyan: return const Color(0xFF00E5FF);
      case NeonTheme.neonGreen: return const Color(0xFF00FF66);
      case NeonTheme.toxicOrange: return const Color(0xFFFF9900);
      case NeonTheme.neonRed: return const Color(0xFFFF0033);
      case NeonTheme.deepBlue: return const Color(0xFF2200FF);
    }
  }

  static Color getAccent(NeonTheme theme) {
    switch (theme) {
      case NeonTheme.cyberCyan: return const Color(0xFFFF00CC);
      case NeonTheme.neonGreen: return const Color(0xFF00FFCC);
      case NeonTheme.toxicOrange: return const Color(0xFFFF0033);
      case NeonTheme.neonRed: return const Color(0xFFFFEE00);
      case NeonTheme.deepBlue: return const Color(0xFF00E5FF);
    }
  }

  // Dynamic Theme Lookups
  static Color getNeoBorder(BuildContext context) => Theme.of(context).primaryColor.withAlpha(40);
  static Color get dimBorder => Colors.white.withAlpha(12);

  static ThemeData themeData(NeonTheme theme) {
    final Color mainGlow = getHighlight(theme);
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: mainGlow,
      colorScheme: ColorScheme.dark(
        primary: mainGlow,
        secondary: getAccent(theme),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    );
  }
}
