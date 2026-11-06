import 'package:flutter/material.dart';
import 'package:movie_archive/core/theme/app_colors.dart';
import 'package:movie_archive/core/widgets/poster_image.dart';
import 'package:movie_archive/data/models/movie.dart';

// Tarjeta del catálogo: póster 2:3 y barra amarilla con el título.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, required this.onTap});

  // Alto de la barra del título.
  static const double titleBarHeight = 52;

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          
            child: Column(
              children: [
                PosterImage(url: movie.imageUrl, radius: 0),
                Container(
                  height: titleBarHeight,
                  width: double.infinity,
                  color: AppColors.yellow,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }
}
