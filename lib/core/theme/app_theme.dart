import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark theme
  static const darkBackground = Color(0xFF0F1117);
  static const darkCard = Color(0xFF1A1D27);
  static const darkAccent = Color(0xFF4A7FD4);
  static const darkTextPrimary = Color(0xFFF0F0F0);
  static const darkTextSecondary = Color(0xFF888888);

  // Light theme
  static const lightBackground = Color(0xFFF5F5F7);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightAccent = Color(0xFF2563EB);
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF666666);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          background: AppColors.darkBackground,
          surface: AppColors.darkCard,
          primary: AppColors.darkAccent,
          onBackground: AppColors.darkTextPrimary,
          onSurface: AppColors.darkTextPrimary,
          secondary: AppColors.darkTextSecondary,
        ),
        cardTheme: const CardTheme(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkCard,
          selectedItemColor: AppColors.darkAccent,
          unselectedItemColor: AppColors.darkTextSecondary,
          type: BottomNavigationBarType.fixed,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkAccent),
          ),
          labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
          bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
          bodySmall: TextStyle(color: AppColors.darkTextSecondary),
          titleLarge: TextStyle(color: AppColors.darkTextPrimary),
          titleMedium: TextStyle(color: AppColors.darkTextPrimary),
          titleSmall: TextStyle(color: AppColors.darkTextSecondary),
        ),
        useMaterial3: true,
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          background: AppColors.lightBackground,
          surface: AppColors.lightCard,
          primary: AppColors.lightAccent,
          onBackground: AppColors.lightTextPrimary,
          onSurface: AppColors.lightTextPrimary,
          secondary: AppColors.lightTextSecondary,
        ),
        cardTheme: CardTheme(
          color: AppColors.lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightCard,
          selectedItemColor: AppColors.lightAccent,
          unselectedItemColor: AppColors.lightTextSecondary,
          type: BottomNavigationBarType.fixed,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightAccent),
          ),
          labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
          bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
          bodySmall: TextStyle(color: AppColors.lightTextSecondary),
          titleLarge: TextStyle(color: AppColors.lightTextPrimary),
          titleMedium: TextStyle(color: AppColors.lightTextPrimary),
          titleSmall: TextStyle(color: AppColors.lightTextSecondary),
        ),
        useMaterial3: true,
      );
}
