import 'package:flutter/material.dart';

class AppTheme extends ThemeExtension<AppTheme> {
  AppTheme();

  AppTheme.dark();

  static ThemeData createTheme({
    bool isDark = false,
    bool isHighContrast = false,
  }) {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      textTheme: const TextTheme(),
    ).copyWith(
      extensions: [
        isDark ? AppTheme.dark() : AppTheme(),
      ],
    );
  }

  @override
  ThemeExtension<AppTheme> copyWith() {
    return AppTheme();
  }

  @override
  ThemeExtension<AppTheme> lerp(ThemeExtension<AppTheme>? other, double t) {
    return AppTheme();
  }
}
