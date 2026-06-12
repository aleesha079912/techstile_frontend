import 'package:flutter/material.dart';

class AppTheme {
    
  static const Color primary = Color(0xFF6C4AB6);   // Royal Purple
  static const Color secondary = Color(0xFFD4ADFC); // Soft Lavender
  static const Color accent = Color(0xFFFFD56F);    // Gold
  static const Color background = Color(0xFFF8F6FF); 
  static const Color tertiary = Color(0xFFAEE2FF);
  static const Color neutral = Color(0xFFD9F9DF);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: secondary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: secondary,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: neutral),
    ),
  );
}