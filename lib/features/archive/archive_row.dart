import 'package:flutter/material.dart';
import 'package:movie_archive/core/theme/app_colors.dart';
import 'package:movie_archive/core/widgets/menu_row.dart';
import 'package:movie_archive/core/widgets/poster_image.dart';
import 'package:movie_archive/data/models/movie.dart';

enum _RowAction { view, edit, delete }

// Fila de la tabla del Archivo. Al abrirla, el póster crece y los detalles aparecen dentro de la misma fila (un solo bloque).
class ArchiveRow extends StatelessWidget {
  const ArchiveRow({
    super.key,
    required this.movie,
    required this.expanded,
    required this.onToggle,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final Movie movie;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _duration,
      decoration: BoxDecoration(
        color: expanded ? AppColors.rowOpen : Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: AnimatedSize(
        duration: _duration,
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
              child: Row(
                crossAxisAlignment: expanded
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: _duration,
                    width: expanded ? 100 : 60,
                    child: PosterImage(
                      url: movie.imageUrl,
                      radius: expanded ? 8 : 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                movie.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: expanded
                                  ? 'Ocultar detalles'
                                  : 'Mostrar detalles',
                              onPressed: onToggle,
                              icon: Icon(
                                expanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 28,
                              ),
                            ),
                            _ActionsMenu(
                              onView: onView,
                              onEdit: onEdit,
                              onDelete: onDelete,
                            ),
                          ],
                        ),
                        if (expanded)
                          Padding(
                            padding: const EdgeInsets.only(right: 12, bottom: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Field(label: 'Año', value: '${movie.year}'),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _Field(
                                        label: 'Género',
                                        value: movie.genre,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _Field(label: 'Director', value: movie.director),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: _Field(label: 'Sinopsis', value: movie.synopsis),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_RowAction>(
      tooltip: 'Más acciones',
      icon: const Icon(Icons.more_vert, size: 26),
      onSelected: (action) {
        switch (action) {
          case _RowAction.view:
            onView();
          case _RowAction.edit:
            onEdit();
          case _RowAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => const <PopupMenuEntry<_RowAction>>[
        PopupMenuItem<_RowAction>(
          value: _RowAction.view,
          child: MenuRow(icon: Icons.visibility_outlined, label: 'Ver detalle'),
        ),
        PopupMenuItem<_RowAction>(
          value: _RowAction.edit,
          child: MenuRow(icon: Icons.edit_outlined, label: 'Editar'),
        ),
        PopupMenuItem<_RowAction>(
          value: _RowAction.delete,
          child: MenuRow(
            icon: Icons.delete_outline,
            label: 'Eliminar',
            color: AppColors.dangerText,
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 14, height: 1.4)),
      ],
    );
  }
}
