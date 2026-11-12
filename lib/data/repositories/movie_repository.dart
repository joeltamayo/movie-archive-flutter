import 'package:movie_archive/data/models/movie.dart';
import 'package:movie_archive/data/services/firestore_rest.dart';
import 'package:movie_archive/data/services/services.dart';

// Contrato de acceso a datos de películas. Las pantallas solo conocen esto.
abstract class MovieRepository {
  Future<List<Movie>> getAll();

  // Devuelve `null` si la película no existe.
  Future<Movie?> getById(String id);

  // Crea la película si `movie.id` está vacío; si no, la actualiza.
  Future<void> save(Movie movie);
  Future<void> delete(String id);
}

// Implementación con solicitudes HTTP a la colección `movies` de Firestore.
class FirestoreMovieRepository implements MovieRepository {
  FirestoreMovieRepository(this._rest, {this.currentUid});

  final FirestoreRest _rest;

  // Devuelve el uid de la persona con sesión (se guarda en `createdBy`).
  final String? Function()? currentUid;

  static const _collection = 'movies';
  static const _editableFields = [
    'title',
    'year',
    'director',
    'genre',
    'synopsis',
    'imageUrl',
  ];

  // Trae toda la colección (de 100 en 100, siguiendo `nextPageToken`) y la ordena por título.
  @override
  Future<List<Movie>> getAll() async {
    final movies = <Movie>[];
    String? pageToken;
    do {
      final json = await _rest.get(
        _collection,
        query: {
          'pageSize': '100',
          'pageToken': ?pageToken,
        },
      );
      final documents = json['documents'];
      if (documents is List) {
        for (final doc in documents) {
          if (doc is Map<String, dynamic>) {
            movies.add(Movie.fromFirestoreJson(doc));
          }
        }
      }
      final next = json['nextPageToken'];
      pageToken = next is String && next.isNotEmpty ? next : null;
    } while (pageToken != null);

    movies.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return movies;
  }

  @override
  Future<Movie?> getById(String id) async {
    try {
      final doc = await _rest.get('$_collection/$id');
      return Movie.fromFirestoreJson(doc);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> save(Movie movie) async {
    final now = DateTime.now();

    if (movie.id.isEmpty) {
      // Alta: Firestore genera el id del documento.
      final fields = movie.toFirestoreFields()
        ..['createdAt'] = fsTimestamp(now)
        ..['updatedAt'] = fsTimestamp(now);
      final uid = currentUid?.call();
      if (uid != null) fields['createdBy'] = fsString(uid);
      await _rest.post(_collection, {'fields': fields});
      return;
    }

    // Edición: solo se cambian los campos editables y `updatedAt`.
    final fields = movie.toFirestoreFields()
      ..['updatedAt'] = fsTimestamp(now);
    await _rest.patch(
      '$_collection/${movie.id}',
      {'fields': fields},
      query: {
        'updateMask.fieldPaths': [..._editableFields, 'updatedAt'],
        'currentDocument.exists': 'true',
      },
    );
  }

  @override
  Future<void> delete(String id) async {
    await _rest.delete('$_collection/$id');
  }
}

// Repositorio que usan las pantallas. Para trabajar solo con datos de ejemplo
final MovieRepository movieRepository = FirestoreMovieRepository(
  firestoreRest,
  currentUid: () => authService.currentUser?.uid,
);