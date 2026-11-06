import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_archive/core/theme/app_colors.dart';
import 'package:movie_archive/core/widgets/app_top_bar.dart';
import 'package:movie_archive/core/widgets/paginator.dart';
import 'package:movie_archive/core/widgets/state_views.dart';
import 'package:movie_archive/data/models/movie.dart';
import 'package:movie_archive/data/repositories/movie_repository.dart';
import 'package:movie_archive/features/catalog/movie_card.dart';


// Pantalla principal del catálogo de películas, con la lista de películas y paginación.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  static const _pageSize = 6;

  List<Movie>? _movies;
  bool _error = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _movies = null;
      _error = false;
    });
    try {
      final data = await movieRepository.getAll();
      if (!mounted) return;
      setState(() => _movies = data);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const AppTopBar(), body: _buildBody());
  }

  Widget _buildBody() {
    if (_error) return ErrorView(onRetry: _load);
    final movies = _movies;
    if (movies == null) return const LoadingView();
    if (movies.isEmpty) {
      return const EmptyView(message: 'Aún no hay películas en el catálogo');
    }

    final pageCount = (movies.length / _pageSize).ceil();
    final page = _page >= pageCount ? pageCount - 1 : _page;
    final items = movies.skip(page * _pageSize).take(_pageSize).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 16.0;
        const gap = 12.0;
        final cardWidth =
            (constraints.maxWidth - horizontalPadding * 2 - gap) / 2;
        final cardHeight = cardWidth * 1.5 + MovieCard.titleBarHeight;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            horizontalPadding,
            16,
            horizontalPadding,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TODAS LAS PELÍCULAS QUE PUEDAS IMAGINAR',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Catálogo',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: gap,
                  mainAxisSpacing: gap,
                  mainAxisExtent: cardHeight,
                ),
                itemBuilder: (context, index) {
                  final movie = items[index];
                  return MovieCard(
                    movie: movie,
                    onTap: () => context.push('/movie/${movie.id}'),
                  );
                },
              ),
              const SizedBox(height: 20),
              Paginator(
                page: page,
                pageCount: pageCount,
                onChanged: (p) => setState(() => _page = p),
              ),
            ],
          ),
        );
      },
    );
  }
}
