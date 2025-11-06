import 'package:flutter/material.dart';

class AppTheme {
  // Primary Brand Colors
  static const Color primaryLight = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF64B5F6);
  
  static const Color secondaryLight = Color(0xFF03A9F4);
  static const Color secondaryDark = Color(0xFF4FC3F7);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // Border & Divider
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF404040);
  
  static const Color dividerLight = Color(0xFFBDBDBD);
  static const Color dividerDark = Color(0xFF424242);
  
  // Status Colors (same in both modes for clarity)
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Glassmorphism Colors
  static Color glassLight = Colors.white.withOpacity(0.7);
  static Color glassDark = Colors.white.withOpacity(0.05);
  
  static Color glassBackgroundLight = Colors.white.withOpacity(0.3);
  static Color glassBackgroundDark = Colors.black.withOpacity(0.3);
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: backgroundLight,
    
    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      secondary: secondaryLight,
      surface: surfaceLight,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
      onError: Colors.white,
    ),
    
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimaryLight, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textPrimaryLight, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textPrimaryLight, fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textPrimaryLight, fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textPrimaryLight, fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: textPrimaryLight, fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textPrimaryLight, fontSize: 16),
      bodyMedium: TextStyle(color: textPrimaryLight, fontSize: 14),
      bodySmall: TextStyle(color: textSecondaryLight, fontSize: 12),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
    ),
    
    dividerTheme: const DividerThemeData(
      color: dividerLight,
      thickness: 1,
    ),
  );
  
  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: backgroundDark,
    
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      surface: surfaceDark,
      error: error,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: textPrimaryDark,
      onError: Colors.white,
    ),
    
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimaryDark, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textPrimaryDark, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textPrimaryDark, fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textPrimaryDark, fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textPrimaryDark, fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: textPrimaryDark, fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textPrimaryDark, fontSize: 16),
      bodyMedium: TextStyle(color: textPrimaryDark, fontSize: 14),
      bodySmall: TextStyle(color: textSecondaryDark, fontSize: 12),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark),
      ),
    ),
    
    dividerTheme: const DividerThemeData(
      color: dividerDark,
      thickness: 1,
    ),
  );
  
  // Helper methods
  static Color getGlassColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? glassDark : glassLight;
  }
  
  static Color getGlassBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? glassBackgroundDark : glassBackgroundLight;
  }
  
  static LinearGradient getGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              primaryDark.withOpacity(0.1),
              backgroundDark,
              secondaryDark.withOpacity(0.05),
            ]
          : [
              primaryLight.withOpacity(0.05),
              Colors.white,
              secondaryLight.withOpacity(0.03),
            ],
    );
  }
}

