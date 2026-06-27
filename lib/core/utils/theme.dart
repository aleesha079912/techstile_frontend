import 'package:flutter/material.dart';

class AppTheme {
  // ===== Colors =====

  static const Color primary = Color(0xFF122B7A);    // Dark Navy
  static const Color secondary= Color(0xFFFFFFFF); // White
  static const Color background = Color(0xFFFFFFFF); // White

  static const Color textPrimary = Color(0xFF122B7A);   // Dark Navy
  static const Color textSecondary = Color(0xFF122B7A); // Dark Navy (light opacity used where needed)

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
      color: Color(0xFF122B7A).withOpacity(0.08),
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
      secondary: primary,
      surface: background,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: primary,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: background,
      foregroundColor: primary,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: BorderSide(color: primary, width: 1),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: buttonRadius
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
        borderSide: const BorderSide(color: primary, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primary, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: primary,
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