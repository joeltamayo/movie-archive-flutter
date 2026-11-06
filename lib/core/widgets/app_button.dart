import 'package:flutter/material.dart';
import 'package:movie_archive/core/theme/app_colors.dart';

// Botón grande del diseño. Texto en 18 px negrita.
class AppButton extends StatelessWidget {
// Botón grande con fondo azul marino y texto blanco.
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  })  : background = AppColors.navy,
        foreground = Colors.white;

// Botón grande con fondo amarillo y texto azul marino.
  const AppButton.accent({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  })  : background = AppColors.yellow,
        foreground = AppColors.navy;

// Botón grande con fondo verde y texto azul marino.
  const AppButton.success({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  })  : background = AppColors.success,
        foreground = AppColors.navy;

// Botón grande con fondo rojo y texto blanco.
  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  })  : background = AppColors.danger,
        foreground = Colors.white;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final Color background;
  final Color foreground;

// Construye un botón grande con el estilo especificado, y si se proporciona un icono, lo muestra a la izquierda del texto.
  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: AppColors.field,
      disabledForegroundColor: AppColors.muted,
      minimumSize: Size(expand ? double.infinity : 0, 52),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
    );

    if (icon == null) {
      return FilledButton(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}