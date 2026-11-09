import 'package:flutter/material.dart';

/// Design tokens. The LCAT is a printed paper marked on an answer bubble
/// sheet, so the look is paper-white with deep indigo chrome and one amber accent.
abstract final class AppColors {
  static const indigo = Color(0xFF1F3A68);
  static const amber = Color(0xFFE39A1C);
  static const correct = Color(0xFF1E7B45);
  static const incorrect = Color(0xFFB3261E);
  static const flagged = Color(0xFFD97F00);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.indigo, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light ? AppColors.indigo : scheme.surface,
        foregroundColor: brightness == Brightness.light ? Colors.white : scheme.onSurface,
      ),
      cardTheme: const CardThemeData(margin: EdgeInsetsDirectional.only(bottom: AppSpacing.sm)),
    );
  }
}
