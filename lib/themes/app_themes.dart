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

  // TEMA 2: GAMIFICATO COLORATO
  static ThemeData gamifiedTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF6B6B),
        primary: const Color(0xFFFF6B6B),
        secondary: const Color(0xFF4ECDC4),
        tertiary: const Color(0xFFFFBE0B),
        surface: Colors.white,
      ),
      
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3436),
        ),
        displayMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3436),
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3436),
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3436),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF636E72),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF636E72),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFFFFF9F0),
        foregroundColor: Color(0xFF2D3436),
      ),
    );
  }

  // TEMA 3: MINIMALISTA PREMIUM
  static ThemeData minimalTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8E9AAF),
        primary: const Color(0xFF8E9AAF),
        secondary: const Color(0xFFB8A9C9),
        tertiary: const Color(0xFFDEE2FF),
        surface: Colors.white,
      ),
      
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w300,
          color: Color(0xFF1A1A1A),
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w300,
          color: Color(0xFF1A1A1A),
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Color(0xFF333333),
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Color(0xFF666666),
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Color(0xFF777777),
          height: 1.5,
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFFFAFAFA),
        foregroundColor: Color(0xFF1A1A1A),
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
