import 'package:flutter/material.dart';
import 'package:movie_archive/core/theme/app_colors.dart';
import 'package:movie_archive/core/widgets/app_top_bar.dart';
import 'package:movie_archive/core/widgets/poster_image.dart';
import 'package:movie_archive/core/widgets/state_views.dart';
import 'package:movie_archive/data/models/movie.dart';
import 'package:movie_archive/data/repositories/movie_repository.dart';

// Pantalla de detalle de una película, con póster, título, año, género, director y sinopsis.
class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage({super.key, required this.movieId});

  final String movieId;

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Movie? _movie;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final movie = await movieRepository.getById(widget.movieId);
      if (!mounted) return;
      setState(() {
        _movie = movie;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Detalle', showBack: true),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView();
    if (_error) return ErrorView(onRetry: _load);
    final movie = _movie;
    if (movie == null) {
      return ErrorView(
        message: 'No se encontró la película. Puede que ya se haya eliminado.',
        onRetry: _load,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x47132340),
                    blurRadius: 28,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: PosterImage(url: movie.imageUrl, radius: 14),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            movie.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip('${movie.year}'),
              _InfoChip(movie.genre),
            ],
          ),
          const SizedBox(height: 20),
          _InfoCard(label: 'Director', value: movie.director),
          const SizedBox(height: 12),
          _InfoCard(label: 'Sinopsis', value: movie.synopsis),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.5,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, height: 1.45)),
        ],
      ),
    );
  }
}
