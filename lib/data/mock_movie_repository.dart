import 'package:movie_archive/data/models/movie.dart';
import 'package:movie_archive/data/repositories/movie_repository.dart';

// Datos de ejemplo en memoria. Se pierden al cerrar la app.
class MockMovieRepository implements MovieRepository {
  final List<Movie> _items = [
    const Movie(
      id: '1',
      title: 'Blade Runner',
      year: 1982,
      director: 'Ridley Scott',
      genre: 'Ciencia ficción',
      synopsis: 'En un Los Ángeles futurista, un cazador de replicantes persigue a un grupo de androides fugitivos.',
      imageUrl: 'https://res.cloudinary.com/dpwmdlttg/image/upload/v1793934225/266201_blbihn.jpg',
    ),
    const Movie(
      id: '2',
      title: 'El viaje de Chihiro',
      year: 2001,
      director: 'Hayao Miyazaki',
      genre: 'Animación',
      synopsis: 'Una niña queda atrapada en un mundo de espíritus y debe trabajar para liberar a sus padres.',
      imageUrl: 'https://res.cloudinary.com/dpwmdlttg/image/upload/v1793934267/MV5BM2E2YzcwMTQtNWRlMC00ZGZlLWJhZTEtMDU4ZGIzMWI0NzJmXkEyXkFqcGc._V1_FMjpg_UX1000__t0m3ht.jpg',
    ),
    const Movie(
      id: '3',
      title: 'Parásitos',
      year: 2019,
      director: 'Bong Joon-ho',
      genre: 'Drama',
      synopsis: 'Una familia sin recursos se infiltra poco a poco en la vida de una familia adinerada.',
      imageUrl: 'https://res.cloudinary.com/dpwmdlttg/image/upload/v1793934299/7IiTTgloJzvGI1TAYymCfbfl3vT_jldocb.jpg',
    ),
    const Movie(
      id: '4',
      title: 'Amélie',
      year: 2001,
      director: 'Jean-Pierre Jeunet',
      genre: 'Comedia',
      synopsis: 'Una joven parisina decide mejorar en secreto la vida de las personas a su alrededor.',
      imageUrl: 'https://res.cloudinary.com/dpwmdlttg/image/upload/v1793931479/AhjligPwdb5waNC9uEFr8eb61hS_js7b9g.jpg',
    ),
    const Movie(
      id: '5',
      title: 'Interestelar',
      year: 2014,
      director: 'Christopher Nolan',
      genre: 'Ciencia ficción',
      synopsis: 'Un grupo de astronautas viaja a través de un agujero de gusano en busca de un nuevo hogar para la humanidad.',
      imageUrl: 'https://res.cloudinary.com/dpwmdlttg/image/upload/v1793934346/MV5BMmUwMmFlMzktYWVlNy00N2I0LWFhMTYtZWI2ZTM4N2I3ZTk0XkEyXkFqcGc._V1__vfh5nh.jpg',
    ),
    const Movie(
      id: '6',
      title: 'La llegada',
      year: 2016,
      director: 'Denis Villeneuve',
      genre: 'Ciencia ficción',
      synopsis: 'Una lingüista intenta comunicarse con visitantes extraterrestres que han llegado a la Tierra.',
      imageUrl: 'https://res.cloudinary.com/dpwmdlttg/image/upload/v1792784683/MV5BMTExMzU0ODcxNDheQTJeQWpwZ15BbWU4MDE1OTI4MzAy._V1__iwyfkl.jpg',
    ),
    const Movie(
      id: '7',
      title: 'Mad Max: Furia en el camino',
      year: 2015,
      director: 'George Miller',
      genre: 'Acción',
      synopsis: 'En un desierto postapocalíptico, una guerrera y un fugitivo huyen de un tirano en una persecución sin descanso.',
      imageUrl: 'https://res.cloudinary.com/dpwmdlttg/image/upload/v1793934380/MV5BODE2NWUwYmYtYmNmZi00OTVjLTgxMzEtZWYyMWVmODg5MmM2XkEyXkFqcGc._V1__ohprxv.jpg',
    ),
    const Movie(
      id: '8',
      title: 'El resplandor',
      year: 1980,
      director: 'Stanley Kubrick',
      genre: 'Terror',
      synopsis: 'Un escritor acepta cuidar un hotel aislado durante el invierno y su cordura empieza a quebrarse.',
      imageUrl: 'https://res.cloudinary.com/dpwmdlttg/image/upload/v1793934418/p9hqo2JWhBytLxskz4FBKcP2e1k_ax75eo.jpg',
    ),
    const Movie(
      id: '9',
      title: 'Coco',
      year: 2017,
      director: 'Lee Unkrich',
      genre: 'Animación',
      synopsis: 'Un niño que sueña con ser músico viaja a la Tierra de los Muertos para descubrir la historia de su familia.',
      imageUrl: 'https://res.cloudinary.com/dpwmdlttg/image/upload/v1793934444/MYmKHc_gs20zm.png',
    ),
    const Movie(
      id: '10',
      title: 'Bowling for Columbine',
      year: 2002,
      director: 'Michael Moore',
      genre: 'Documental',
      synopsis: 'Un documental que explora la cultura de las armas y la violencia en Estados Unidos.',
      imageUrl: 'https://res.cloudinary.com/dpwmdlttg/image/upload/v1793934472/lun1ptGstEhxOhmc24pORDXEVkN2Ve_large_acunhm.jpg',
    ),
  ];

  int _nextId = 100;

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<Movie>> getAll() async {
    await _latency();
    final sorted = List<Movie>.of(_items)
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return sorted;
  }

  @override
  Future<Movie?> getById(String id) async {
    await _latency();
    for (final movie in _items) {
      if (movie.id == id) return movie;
    }
    return null;
  }

  @override
  Future<void> save(Movie movie) async {
    await _latency();
    if (movie.id.isEmpty) {
      _items.add(movie.copyWith(id: '${_nextId++}'));
      return;
    }
    final index = _items.indexWhere((m) => m.id == movie.id);
    if (index >= 0) _items[index] = movie;
  }

  @override
  Future<void> delete(String id) async {
    await _latency();
    _items.removeWhere((m) => m.id == id);
  }
}
