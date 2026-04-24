import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1E3A8A);
  static const Color secondary = Color(0xFFF3F4F6);
  static const Color tertiary = Color(0xFF14B8A6);
  static const Color neutral = Color(0xFF76767D);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: secondary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: tertiary,
      surface: secondary,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: neutral),
    ),
  );
}