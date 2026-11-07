import 'package:movie_archive/data/services/auth_service.dart';
import 'package:movie_archive/data/services/firestore_rest.dart';
import 'package:movie_archive/data/services/user_api.dart';
import 'package:movie_archive/firebase_options.dart';

// Instancias únicas de los servicios. Las variables globales se crean la primera vez que se usan, es decir, después de Firebase.initializeApp.

final FirestoreRest firestoreRest = FirestoreRest(
  projectId: DefaultFirebaseOptions.currentPlatform.projectId,
  tokenProvider: ({bool forceRefresh = false}) =>
      authService.idToken(forceRefresh: forceRefresh),
);

final UserApi userApi = UserApi(firestoreRest);

final AuthService authService = AuthService(userApi);
