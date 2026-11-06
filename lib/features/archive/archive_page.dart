import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_archive/core/theme/app_colors.dart';
import 'package:movie_archive/core/widgets/app_top_bar.dart';
import 'package:movie_archive/core/widgets/confirm_dialog.dart';
import 'package:movie_archive/core/widgets/paginator.dart';
import 'package:movie_archive/core/widgets/state_views.dart';
import 'package:movie_archive/data/models/movie.dart';
import 'package:movie_archive/data/repositories/movie_repository.dart';
import 'package:movie_archive/features/archive/archive_row.dart';

// Pantalla principal del archivo de películas, con la lista de películas y paginación.

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  static const _pageSize = 4;

  List<Movie>? _movies;
  bool _error = false;
  int _page = 0;
  String? _openId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _movies = null;
        _error = false;
      });
    }
    try {
      final data = await movieRepository.getAll();
      if (!mounted) return;
      setState(() {
        _movies = data;
        _error = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = true);
    }
  }

  Future<void> _openForm([String? movieId]) async {
    await context.push(movieId == null ? '/movie/new' : '/movie/$movieId/edit');
    if (!mounted) return;
    await _load(showLoading: false);
  }

  Future<void> _delete(Movie movie) async {
    final confirmed = await showConfirmDeleteDialog(context, movie);
    if (!confirmed || !mounted) return;
    try {
      await movieRepository.delete(movie.id);
      if (!mounted) return;
      if (_openId == movie.id) setState(() => _openId = null);
      await _load(showLoading: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Película eliminada')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar. Inténtalo de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const AppTopBar(), body: _buildBody());
  }

  Widget _buildBody() {
    if (_error) return ErrorView(onRetry: () => _load());
    final movies = _movies;
    if (movies == null) return const LoadingView();

    final pageCount = (movies.length / _pageSize).ceil();
    final page = pageCount == 0
        ? 0
        : (_page >= pageCount ? pageCount - 1 : _page);
    final items = movies.skip(page * _pageSize).take(_pageSize).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(onAdd: () => _openForm()),
          if (movies.isEmpty)
            SizedBox(
              height: 320,
              child: EmptyView(
                message: 'Aún no hay películas en el archivo',
                actionLabel: 'Añadir película',
                onAction: () => _openForm(),
              ),
            )
          else ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const _TableHeader(),
                  for (final movie in items)
                    ArchiveRow(
                      key: ValueKey(movie.id),
                      movie: movie,
                      expanded: _openId == movie.id,
                      onToggle: () => setState(() {
                        _openId = _openId == movie.id ? null : movie.id;
                      }),
                      onView: () => context.push('/movie/${movie.id}'),
                      onEdit: () => _openForm(movie.id),
                      onDelete: () => _delete(movie),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Paginator(
              page: page,
              pageCount: pageCount,
              onChanged: (p) => setState(() {
                _page = p;
                _openId = null;
              }),
            ),
          ],
        ],
      ),
    );
  }
}

// Encabezado de la pantalla con título y botón de añadir película.
class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GESTIONA EL ARCHIVO DE PELÍCULAS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: AppColors.muted,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Archivo',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Añadir'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
              shape: const StadiumBorder(),
              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// Encabezado de la tabla con los títulos de las columnas.
class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 11,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w700,
      color: AppColors.muted,
    );
    return Container(
      height: 32,
      color: AppColors.field,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        children: [
          SizedBox(width: 72, child: Text('IMG', style: style)),
          Expanded(child: Text('TÍTULO', style: style)),
          SizedBox(
            width: 88,
            child: Text('MÁS', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}
