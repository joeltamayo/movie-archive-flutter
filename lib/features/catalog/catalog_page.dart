import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_archive/core/theme/app_colors.dart';
import 'package:movie_archive/core/utils/error_messages.dart';
import 'package:movie_archive/core/utils/text_search.dart';
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

  final _searchController = TextEditingController();

  List<Movie>? _movies;
  String? _errorMessage;
  String _query = '';
  bool _searching = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Carga el catálogo. Con `showLoading: false` (deslizar para actualizar)
  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _movies = null;
        _errorMessage = null;
      });
    }
    try {
      final data = await movieRepository.getAll();
      if (!mounted) return;
      setState(() {
        _movies = data;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      final message = describeError(
        e,
        fallback: 'No se pudo cargar el catálogo.',
      );
      if (_movies == null) {
        setState(() => _errorMessage = message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      _page = 0;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _openSearch() => setState(() => _searching = true);

  // Cierra el modo búsqueda y quita el filtro.
  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _searching = false;
      _query = '';
      _page = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        titleWidget: _searching ? _buildSearchField() : null,
        actions: [
          if (_movies?.isNotEmpty ?? false)
            IconButton(
              tooltip: _searching ? 'Cerrar búsqueda' : 'Buscar',
              icon: Icon(_searching ? Icons.close : Icons.search),
              onPressed: _searching ? _closeSearch : _openSearch,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      onChanged: _onSearchChanged,
      textInputAction: TextInputAction.search,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: const InputDecoration(
        hintText: 'Buscar por título',
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        isDense: true,
      ),
    );
  }

  Widget _buildBody() {
    final errorMessage = _errorMessage;
    if (errorMessage != null) {
      return ErrorView(message: errorMessage, onRetry: () => _load());
    }
    final movies = _movies;
    if (movies == null) return const LoadingView();
    if (movies.isEmpty) {
      return const EmptyView(message: 'Aún no hay películas en el catálogo');
    }

    final query = normalizeForSearch(_query);
    final filtered = query.isEmpty
        ? movies
        : movies
            .where((m) => normalizeForSearch(m.title).contains(query))
            .toList();

    final pageCount = (filtered.length / _pageSize).ceil();
    final page = pageCount == 0
        ? 0
        : (_page >= pageCount ? pageCount - 1 : _page);
    final items = filtered.skip(page * _pageSize).take(_pageSize).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 16.0;
        const gap = 12.0;
        final cardWidth =
            (constraints.maxWidth - horizontalPadding * 2 - gap) / 2;
        final cardHeight = cardWidth * 1.5 + MovieCard.titleBarHeight;

        return RefreshIndicator(
          color: AppColors.navy,
          onRefresh: () => _load(showLoading: false),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: AppColors.muted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay resultados para "${_query.trim()}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _clearSearch,
                            child: const Text('Borrar búsqueda'),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
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
              ],
            ),
          ),
        );
      },
    );
  }
}
