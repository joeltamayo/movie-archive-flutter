import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_archive/core/theme/app_colors.dart';

// Construye el tema de la app.
ThemeData buildAppTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.navy,
    onPrimary: Colors.white,
    secondary: AppColors.yellow,
    onSecondary: AppColors.navy,
    error: AppColors.dangerText,
    onError: Colors.white,
    surface: AppColors.background,
    onSurface: AppColors.navy,
  );

// Construye el tema base con Material 3 y la paleta de colores, y luego lo personaliza.
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: _buildTextTheme(base.textTheme),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.navy,
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 15),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// Aplica Plus Jakarta Sans estilo por estilo a un TextTheme base, y cambia el color de todos los textos a azul marino.
TextTheme _buildTextTheme(TextTheme base) {
  TextStyle? font(TextStyle? style) {
    if (style == null) return null;
    return GoogleFonts.plusJakartaSans(
      textStyle: style.copyWith(color: AppColors.navy),
    );
  }

// Aplica la función `font` a cada estilo de texto del TextTheme base y devuelve un nuevo TextTheme con los estilos actualizados.
  return base.copyWith(
    displayLarge: font(base.displayLarge),
    displayMedium: font(base.displayMedium),
    displaySmall: font(base.displaySmall),
    headlineLarge: font(base.headlineLarge),
    headlineMedium: font(base.headlineMedium),
    headlineSmall: font(base.headlineSmall),
    titleLarge: font(base.titleLarge),
    titleMedium: font(base.titleMedium),
    titleSmall: font(base.titleSmall),
    bodyLarge: font(base.bodyLarge),
    bodyMedium: font(base.bodyMedium),
    bodySmall: font(base.bodySmall),
    labelLarge: font(base.labelLarge),
    labelMedium: font(base.labelMedium),
    labelSmall: font(base.labelSmall),
  );
}