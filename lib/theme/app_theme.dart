import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Temas do app. A fonte arredondada de referência é a Fredoka; caímos para
/// Nunito (área dos pais) por legibilidade. Caso não haja rede para baixar as
/// fontes do Google, o app continua funcionando com a fonte padrão do sistema.
class AppTheme {
  AppTheme._();

  static TextTheme _kidsText(TextTheme base) {
    try {
      return GoogleFonts.fredokaTextTheme(base);
    } catch (_) {
      return base;
    }
  }

  static TextTheme _parentText(TextTheme base) {
    try {
      return GoogleFonts.nunitoTextTheme(base);
    } catch (_) {
      return base;
    }
  }

  /// Tema usado na maior parte do app (área infantil).
  static ThemeData kids() {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.kidsBlue,
      scaffoldBackgroundColor: AppColors.kidsCream,
      brightness: Brightness.light,
    );
    return base.copyWith(
      textTheme: _kidsText(base.textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        ),
      ),
    );
  }

  /// Tema da área dos pais (mais sóbrio e profissional).
  static ThemeData parent() {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.parentBlue,
      scaffoldBackgroundColor: AppColors.parentBg,
      brightness: Brightness.light,
    );
    return base.copyWith(
      textTheme: _parentText(base.textTheme).apply(
        bodyColor: AppColors.parentText,
        displayColor: AppColors.parentText,
      ),
      cardTheme: CardThemeData(
        color: AppColors.parentSurface,
        elevation: 1,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.parentBg,
        foregroundColor: AppColors.parentText,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
