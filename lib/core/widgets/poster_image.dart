import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_archive/core/theme/app_colors.dart';

// Póster vertical 2:3. Si la URL está vacía o falla, muestra un marcador gris con un ícono de película.
class PosterImage extends StatelessWidget {
  const PosterImage({super.key, required this.url, this.radius = 8});

  final String url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final trimmed = url.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: trimmed.isEmpty
            ? const _PosterPlaceholder()
            : CachedNetworkImage(
                imageUrl: trimmed,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (context, url) =>
                    const _PosterPlaceholder(loading: true),
                errorWidget: (context, url, error) =>
                    const _PosterPlaceholder(),
              ),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.field,
      child: Center(
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.navy,
                ),
              )
            : const Icon(Icons.movie_outlined, color: AppColors.muted, size: 32),
      ),
    );
  }
}
