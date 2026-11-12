import 'package:movie_archive/data/services/firestore_rest.dart';

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

  // Lee un documento de Firestore REST. El id es el último segmento de `name`.
  factory Movie.fromFirestoreJson(Map<String, dynamic> doc) {
    final name = doc['name'];
    final rawFields = doc['fields'];
    final fields = rawFields is Map<String, dynamic>
        ? rawFields
        : <String, dynamic>{};
    return Movie(
      id: name is String ? name.split('/').last : '',
      title: fsReadString(fields, 'title'),
      year: fsReadInt(fields, 'year'),
      director: fsReadString(fields, 'director'),
      genre: fsReadString(fields, 'genre'),
      synopsis: fsReadString(fields, 'synopsis'),
      imageUrl: fsReadString(fields, 'imageUrl'),
    );
  }

  // Vacío cuando la película todavía no se ha guardado.
  final String id;
  final String title;
  final int year;
  final String director;
  final String genre;
  final String synopsis;

  // URL del póster vertical (Cloudinary).
  final String imageUrl;

  // Campos con formato Firestore (sin id ni fechas de control).
  Map<String, dynamic> toFirestoreFields() {
    return {
      'title': fsString(title),
      'year': fsInt(year),
      'director': fsString(director),
      'genre': fsString(genre),
      'synopsis': fsString(synopsis),
      'imageUrl': fsString(imageUrl),
    };
  }

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
