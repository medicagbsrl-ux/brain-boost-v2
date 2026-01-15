import 'package:flutter/material.dart';

class AppThemes {
  // TEMA 1: PROFESSIONALE MEDICO-CLINICO (Default)
  static ThemeData professionalTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A6FA5),
        primary: const Color(0xFF4A6FA5),
        secondary: const Color(0xFF7B68EE),
        tertiary: const Color(0xFF5B9BD5),
        surface: Colors.white,
      ),
      
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF34495E),
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFF34495E),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF555555),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF2C3E50),
      ),
    );
  }

  // TEMA 2: LUDICO COLORATO E ACCATTIVANTE
  static ThemeData gamifiedTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF6B6B),
        primary: const Color(0xFFFF6B6B), // Rosso vivace
        secondary: const Color(0xFF4ECDC4), // Turchese
        tertiary: const Color(0xFFFFBE0B), // Giallo oro
        surface: const Color(0xFFFFF9F0), // Crema chiaro
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      
      cardTheme: CardThemeData(
        elevation: 8, // Ombre più pronunciate
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Bordi molto arrotondati
          side: BorderSide(color: const Color(0xFFFF6B6B).withOpacity(0.2), width: 2),
        ),
        color: Colors.white,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          shadowColor: Colors.black38,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Bottoni molto arrotondati
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          foregroundColor: Colors.white,
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w800, // Grassetto marcato
          color: Color(0xFFFF6B6B), // Rosso per titoli
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4ECDC4), // Turchese
        ),
        titleLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3436),
        ),
        titleMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3436),
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          color: Color(0xFF636E72),
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: Color(0xFF636E72),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        elevation: 4,
        shadowColor: Colors.black26,
        centerTitle: true,
        backgroundColor: Color(0xFFFF6B6B), // AppBar rossa
        foregroundColor: Colors.white,
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFFBE0B), // FAB giallo
        foregroundColor: Color(0xFF2D3436),
        elevation: 8,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFFF9F0),
        selectedColor: const Color(0xFFFF6B6B),
        labelStyle: const TextStyle(color: Color(0xFF2D3436)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
    );
  }

  // TEMA 3: MINIMALISTA PREMIUM ZEN
  static ThemeData minimalTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A1A1A),
        primary: const Color(0xFF1A1A1A), // Nero antracite
        secondary: const Color(0xFF8E9AAF), // Grigio azzurrato
        tertiary: const Color(0xFFE8E8E8), // Grigio chiaro
        surface: const Color(0xFFFAFAFA), // Bianco sporco
        onPrimary: Colors.white,
      ),
      
      cardTheme: CardThemeData(
        elevation: 0, // Flat design
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Bordi minimi
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        color: Colors.white,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0, // Flat
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Bordi squadrati
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w200, // Ultra-leggero
          color: Color(0xFF1A1A1A),
          letterSpacing: -1.0,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w300,
          color: Color(0xFF1A1A1A),
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: Color(0xFF333333),
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Color(0xFF444444),
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Color(0xFF666666),
          height: 1.8, // Spaziatura generosa
          letterSpacing: 0.2,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Color(0xFF777777),
          height: 1.7,
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFFFAFAFA),
        foregroundColor: Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
      ),
      
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 32,
      ),
    );
  }

  // Helper per ottenere il tema basato sul profilo utente
  static ThemeData getThemeForProfile(BuildContext context, String themeName) {
    switch (themeName) {
      case 'gamified':
        return gamifiedTheme(context);
      case 'minimal':
        return minimalTheme(context);
      case 'professional':
      default:
        return professionalTheme(context);
    }
  }

  // Modifica dimensione testo basata sulle preferenze
  static TextTheme adjustTextSize(TextTheme baseTheme, String textSize) {
    double multiplier;
    switch (textSize) {
      case 'large':
        multiplier = 1.2;
        break;
      case 'extra_large':
        multiplier = 1.4;
        break;
      case 'normal':
      default:
        multiplier = 1.0;
        break;
    }

    return TextTheme(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontSize: (baseTheme.displayLarge?.fontSize ?? 32) * multiplier,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontSize: (baseTheme.displayMedium?.fontSize ?? 28) * multiplier,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontSize: (baseTheme.titleLarge?.fontSize ?? 22) * multiplier,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontSize: (baseTheme.titleMedium?.fontSize ?? 18) * multiplier,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontSize: (baseTheme.bodyLarge?.fontSize ?? 16) * multiplier,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontSize: (baseTheme.bodyMedium?.fontSize ?? 14) * multiplier,
      ),
    );
  }

  // Palette colori per domini cognitivi
  static const Map<String, Color> cognitiveColors = {
    'memory': Color(0xFF4A90E2),
    'attention': Color(0xFFF5A623),
    'executive': Color(0xFF7B68EE),
    'speed': Color(0xFF50E3C2),
    'language': Color(0xFFE84855),
    'spatial': Color(0xFF9B59B6),
  };
}
