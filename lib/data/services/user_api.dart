import 'package:movie_archive/data/services/firestore_rest.dart';

// Perfil de usuario en la colección `users` (un documento por `uid`).
class UserApi {
  UserApi(this._rest);

  final FirestoreRest _rest;

  // Crea (o reemplaza) el documento `users/{uid}`.
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required DateTime birthDate,
  }) async {
    await _rest.patch('users/$uid', {
      'fields': {
        'name': fsString(name),
        'email': fsString(email),
        // Solo la fecha, a medianoche UTC, para que no cambie por zona horaria.
        'birthDate': fsTimestamp(
          DateTime.utc(birthDate.year, birthDate.month, birthDate.day),
        ),
        'createdAt': fsTimestamp(DateTime.now()),
      },
    });
  }
}
