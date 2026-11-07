import 'package:flutter/material.dart';
import 'package:movie_archive/core/theme/app_colors.dart';

// Mensaje de error destacado (por ejemplo, "Correo o contraseña incorrectos").
class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.dangerText),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.dangerText,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.dangerText,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
