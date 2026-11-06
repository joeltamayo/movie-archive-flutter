import 'package:flutter/material.dart';
import 'package:movie_archive/core/theme/app_colors.dart';
import 'package:movie_archive/core/widgets/app_button.dart';
import 'package:movie_archive/data/models/movie.dart';

// Diálogo de confirmación antes de eliminar. Devuelve `true` solo si la persona confirma.
Future<bool> showConfirmDeleteDialog(BuildContext context, Movie movie) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.danger,
          child: Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        title: const Text('¿Eliminar película?', textAlign: TextAlign.center),
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.muted,
                ),
                children: [
                  const TextSpan(text: 'Se eliminará '),
                  TextSpan(
                    text: '${movie.title} (${movie.year})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' del archivo y del catálogo. Esta acción no se puede deshacer.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navy, width: 2),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: Theme.of(dialogContext)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton.danger(
                    label: 'Eliminar',
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}
