import 'package:flutter/material.dart';

class AppTheme {
  // ===== Colors =====

  static const Color primary    = Color(0xFF122B7A); // Dark Navy
  static const Color secondary  = Color(0xFFFFFFFF); // White
  static const Color background = Color(0xFFF2F8FC); // White
  static const Color neutral = Color(0xFFB0A695);
  static const Color surface  = Color(0xFFFFA02F); 
  static const Color onsurface  = Color(0xFF202020); 


  static const Color active  = Color(0xFF0D9B8A); // Teal — active / selected / success
  static const Color success = Color(0xFF0D9B8A); // Teal (alias)
   static const Color info= Color(0xFF64B5F6);
  static const Color error   = Color(0xFFE74C3C); // Red — error / reject

  static const Color textPrimary   = Color(0xFF122B7A); // Dark Navy
  static const Color textSecondary = Color(0xFFFFFFFF); // Dark Navy (use with opacity)

  // ===== Radius =====

  static const BorderRadius cardRadius   = BorderRadius.all(Radius.circular(28));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(18));

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
      primary:         primary,
      secondary:       secondary,
      surface:         background,
      onPrimary:       Colors.white,
      onSecondary:     primary,
      onSurface:       primary,
      tertiary:        active,   // teal — use for active/selected indicators
      onTertiary:      Colors.white,
      error:           error,
      onError:         Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      elevation:       0,
      backgroundColor: background,
      foregroundColor: primary,
      centerTitle:     false,
    ),

    cardTheme: CardThemeData(
      color:     background,
      elevation: 0,
      shape:     RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: BorderSide(color: primary, width: 1),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize:     const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: buttonRadius),
      ),
    ),

    // For teal "confirm / accept" buttons — apply manually where needed:
    // ElevatedButton.styleFrom(backgroundColor: AppTheme.active, ...)

    // For red "reject / delete" buttons — apply manually where needed:
    // ElevatedButton.styleFrom(backgroundColor: AppTheme.error, ...)

    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical:   18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:   const BorderSide(color: primary, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:   const BorderSide(color: primary, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:   const BorderSide(color: active, width: 2), // teal on focus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:   const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:   const BorderSide(color: error, width: 2),
      ),
      errorStyle: const TextStyle(color: error),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: primary),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: 16, color: primary),
      bodyMedium: TextStyle(fontSize: 14, color: primary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
    ),

    iconTheme: const IconThemeData(color: primary, size: 24),

    // Teal checkboxes / switches / radio buttons when active
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return active;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: primary, width: 1.5),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return active;
        return primary;
      }),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return primary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return active;
        return primary.withOpacity(0.2);
      }),
    ),

    // Tab indicator in teal
    tabBarTheme: const TabBarThemeData(
      labelColor:        active,
      unselectedLabelColor: primary,
      indicatorColor:    active,
    ),
  );
}