import 'package:go_router/go_router.dart';
import 'package:movie_archive/features/archive/archive_page.dart';
import 'package:movie_archive/features/archive/movie_form_page.dart';
import 'package:movie_archive/features/auth/login_page.dart';
import 'package:movie_archive/features/auth/register_page.dart';
import 'package:movie_archive/features/catalog/catalog_page.dart';
import 'package:movie_archive/features/detail/movie_detail_page.dart';

// Rutas de la app.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => const CatalogPage(),
    ),
    GoRoute(
      path: '/archive',
      builder: (context, state) => const ArchivePage(),
    ),
    // '/movie/new' debe ir antes de '/movie/:id' porque GoRouter evalúa las rutas en orden y la primera que coincide es la que se usa.
    GoRoute(
      path: '/movie/new',
      builder: (context, state) => const MovieFormPage(),
    ),
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) =>
          MovieDetailPage(movieId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/movie/:id/edit',
      builder: (context, state) =>
          MovieFormPage(movieId: state.pathParameters['id']),
    ),
  ],
);
