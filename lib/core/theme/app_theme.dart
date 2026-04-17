import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Deep space minimal dark background
  static const Color background = Color(0xFF06060A);
  
  // Cyberpunk primary glow (Cyber Cyan)
  static const Color highlight = Color(0xFF00E5FF);
  
  // Cyberpunk secondary neon (Magenta/Pinkish)
  static const Color accentNeon = Color(0xFFFF0055);
  
  // Clean card backgrounds (slightly transparent, very minimal dark)
  static const Color cardBase = Color(0xFF101015);
  
  // Clean thin border lines 
  static Color get neoBorder => highlight.withAlpha(50); // 0.2 opacity approx
  static Color get dimBorder => Colors.white.withAlpha(12);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: highlight,
      colorScheme: const ColorScheme.dark(
        primary: highlight,
        secondary: accentNeon,
        surface: cardBase,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    );
  }
}
