// Lista fija de géneros del formulario.
const kGenres = <String>[
  'Acción',
  'Comedia',
  'Drama',
  'Terror',
  'Ciencia ficción',
  'Animación',
  'Documental',
  'Otro',
];

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.director,
    required this.genre,
    required this.synopsis,
    required this.imageUrl,
  });

  // Vacío cuando la película todavía no se ha guardado.
  final String id;
  final String title;
  final int year;
  final String director;
  final String genre;
  final String synopsis;

  // URL del póster vertical (Cloudinary).
  final String imageUrl;

  Movie copyWith({String? id}) {
    return Movie(
      id: id ?? this.id,
      title: title,
      year: year,
      director: director,
      genre: genre,
      synopsis: synopsis,
      imageUrl: imageUrl,
    );
  }
}
