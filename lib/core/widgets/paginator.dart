import 'package:flutter/material.dart';
import 'package:movie_archive/core/theme/app_colors.dart';

/// Flechas y puntos de paginación.
class Paginator extends StatelessWidget {
  const Paginator({
    super.key,
    required this.page,
    required this.pageCount,
    required this.onChanged,
  });

  final int page;
  final int pageCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundButton(
          icon: Icons.chevron_left,
          tooltip: 'Página anterior',
          onPressed: page > 0 ? () => onChanged(page - 1) : null,
        ),
        const SizedBox(width: 12),
        Semantics(
          label: 'Página ${page + 1} de $pageCount',
          child: Row(
            children: List.generate(pageCount, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == page ? AppColors.navy : const Color(0xFFCFD3DA),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        _RoundButton(
          icon: Icons.chevron_right,
          tooltip: 'Página siguiente',
          onPressed: page < pageCount - 1 ? () => onChanged(page + 1) : null,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 26),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFCFD3DA),
        fixedSize: const Size(44, 44),
      ),
    );
  }
}
