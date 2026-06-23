import 'package:flutter/material.dart';

class AppTheme {
  // ===== Colors =====

  static const Color primary = Color(0xFF122B7A); // Dark Navy
  static const Color secondary = Color(0xFF3498F7); // Bright Blue
  static const Color neutral = Color(0xFFACD0EC);
  static const Color background = Color(0xFFF5FAFF);
  static const Color cardBackground = Color(0xFFB3D6EF);

  static const Color textPrimary = Color(0xFF122B7A);
  static const Color textSecondary = Color(0xFF6D7A96);

  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);

  // ===== Radius =====

  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(28));

  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(18));

  // ===== Shadows =====

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.blueGrey.withOpacity(0.08),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  // ===== Theme =====

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: cardBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: background,
      foregroundColor: textPrimary,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: buttonRadius,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: secondary,
          width: 1.5,
        ),
      ),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    iconTheme: const IconThemeData(
      color: primary,
      size: 24,
    ),
  );
}