import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color primaryBlue = Color(0xFF0F5694);

  // La configuración visual compartida se mantiene fuera de las pantallas.
  static ThemeData get light {
    final colors = ColorScheme.fromSeed(seedColor: primaryBlue);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      appBarTheme: const AppBarThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }
}
