import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_archive/core/theme/app_colors.dart';

// Construye un borde redondeado para los campos de texto, con un color opcional.
OutlineInputBorder _border([Color? color]) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:
        color == null ? BorderSide.none : BorderSide(color: color, width: 2),
  );
}

// Decoración común de campos: fondo gris, esquinas redondeadas y errores en rojo oscuro.
InputDecoration appInputDecoration({String? hint, Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.muted),
    filled: true,
    fillColor: AppColors.field,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    suffixIcon: suffixIcon,
    border: _border(),
    enabledBorder: _border(),
    disabledBorder: _border(),
    focusedBorder: _border(AppColors.navy),
    errorBorder: _border(AppColors.dangerText),
    focusedErrorBorder: _border(AppColors.dangerText),
    errorMaxLines: 2,
    errorStyle: const TextStyle(
      color: AppColors.dangerText,
      fontSize: 13,
      height: 1.3,
    ),
  );
}

// Etiqueta en mayúsculas con espaciado que va sobre cada campo.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

// Campo de texto con estilo de la app, etiqueta, validación y otras opciones.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.suffixIcon,
    this.minLines,
    this.maxLines = 1,
    this.textInputAction,
    this.inputFormatters,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int? minLines;
  final int maxLines;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          onTap: onTap,
          minLines: minLines,
          maxLines: obscureText ? 1 : maxLines,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onFieldSubmitted: onSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 15, color: AppColors.navy),
          decoration: appInputDecoration(hint: hint, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}
