import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movie_archive/core/router/app_router.dart';
import 'package:movie_archive/core/theme/app_theme.dart';
import 'package:movie_archive/data/services/services.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

// Inicializa Firebase antes de usar cualquier servicio que dependa de él.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await authService.init(); // Inicializa el estado de la sesión (FirebaseAuth.instance.currentUser).

  runApp(const MovieArchiveApp());
}

class MovieArchiveApp extends StatelessWidget {
  const MovieArchiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Movie Archive',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX'), Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
