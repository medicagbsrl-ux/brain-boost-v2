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

  // TEMA 2: LUDICO COLORATO E ACCATTIVANTE (ULTRA DISTINTIVO)
  static ThemeData gamifiedTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF1744), // Rosso ELETTRICO
        primary: const Color(0xFFFF1744), // Rosso ELETTRICO
        secondary: const Color(0xFF00E5FF), // Ciano NEON
        tertiary: const Color(0xFFFFEA00), // Giallo NEON
        surface: const Color(0xFFFFF8DC), // Crema caldo
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        error: const Color(0xFFD500F9), // Viola neon per errori
      ),
      
      cardTheme: CardThemeData(
        elevation: 12, // OMBRE PESANTI
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // SUPER ARROTONDATO
          side: BorderSide(color: const Color(0xFFFF1744), width: 3), // Bordo rosso spesso
        ),
        color: Colors.white,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 10,
          shadowColor: Colors.black54,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // MOLTO arrotondato
          ),
          backgroundColor: const Color(0xFFFF1744), // Rosso elettrico
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800, // SUPER grassetto
            letterSpacing: 1.2,
          ),
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w900, // BLACK (massimo grassetto)
          color: Color(0xFFFF1744), // Rosso elettrico
          letterSpacing: 1.5,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: Color(0xFF00E5FF), // Ciano neon
          letterSpacing: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
        ),
        titleMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3436),
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Color(0xFF424242),
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Color(0xFF616161),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        elevation: 8,
        shadowColor: Colors.black38,
        centerTitle: true,
        backgroundColor: Color(0xFFFF1744), // AppBar ROSSO ELETTRICO
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFFEA00), // FAB GIALLO NEON
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 12,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFFF8DC),
        selectedColor: const Color(0xFFFF1744),
        labelStyle: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFFF1744),
        indicatorColor: const Color(0xFFFFEA00),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // TEMA 3: MINIMALISTA ZEN (ULTRA PULITO)
  static ThemeData minimalTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        primary: Colors.black, // NERO PURO
        secondary: const Color(0xFFEEEEEE), // Grigio chiarissimo
        tertiary: const Color(0xFF9E9E9E), // Grigio medio
        surface: const Color(0xFFFAFAFA), // Bianco sporco
        onPrimary: Colors.white,
      ),
      
      cardTheme: CardThemeData(
        elevation: 0, // COMPLETAMENTE FLAT
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Bordi SQUADRATI
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5), // Bordo sottilissimo
        ),
        color: Colors.white,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0, // COMPLETAMENTE FLAT
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // COMPLETAMENTE SQUADRATO
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400, // LEGGERO
            letterSpacing: 2.0, // SPAZIATURA ESTREMA
          ),
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w100, // ULTRA-LEGGERO (Thin)
          color: Colors.black,
          letterSpacing: -2.0, // Tight
          height: 1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w200, // EXTRA-LIGHT
          color: Colors.black,
          letterSpacing: -1.0,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w300, // LIGHT
          color: Color(0xFF212121),
          letterSpacing: 0.5,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w300,
          color: Color(0xFF424242),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF616161),
          height: 2.0, // SPAZIATURA VERTICALE ESTREMA
          letterSpacing: 0.8,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF757575),
          height: 1.8,
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        elevation: 0, // FLAT
        centerTitle: true,
        backgroundColor: Colors.white, // AppBar BIANCO PURO
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          color: Colors.black,
          letterSpacing: 4.0, // SPAZIATURA MASSIMA
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0, // FLAT
        shape: CircleBorder(), // Perfettamente circolare
      ),
      
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFFFAFAFA),
        selectedColor: Colors.black,
        labelStyle: TextStyle(
          color: Color(0xFF212121),
          fontWeight: FontWeight.w300,
          letterSpacing: 1.5,
        ),
        shape: StadiumBorder(
          side: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 0.5,
        space: 48, // SPAZIO GENEROSO
      ),
      
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.black,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: Color(0xFF757575),
            letterSpacing: 1.5,
          ),
        ),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: Color(0xFF757575), size: 24),
        ),
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
