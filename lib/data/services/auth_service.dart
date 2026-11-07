import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_archive/data/services/user_api.dart';

// Error de autenticación con un mensaje listo para mostrar en pantalla.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

// Sesión del usuario (Firebase Auth). Es un `ChangeNotifier` para que el router se actualice cuando la persona entra o sale.
class AuthService extends ChangeNotifier {
  AuthService(this._users, {FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final UserApi _users;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _subscription;
  User? _user;
  bool _registering = false;

  bool get isLoggedIn => _user != null;
  User? get currentUser => _user;

  // Espera el estado inicial de la sesión. Se llama en `main()` antes de `runApp` para no mostrar el login un instante si ya había sesión.
  Future<void> init() async {
    _user = await _auth.authStateChanges().first;
    _subscription = _auth.authStateChanges().listen((user) {
      _user = user;
      // Durante el registro se espera a que termine de guardarse el perfil.
      if (!_registering) notifyListeners();
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    }
  }

  // Crea la cuenta y el documento `users/{uid}`. Si no se puede guardar el perfil, elimina la cuenta recién creada para que se pueda reintentar.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required DateTime birthDate,
  }) async {
    _registering = true;
    try {
      final credential = await _createAccount(email, password);
      final user = credential.user!;
      try {
        await user.updateDisplayName(name);
        await _users.createUser(
          uid: user.uid,
          name: name,
          email: email,
          birthDate: birthDate,
        );
      } catch (_) {
        try {
          await user.delete();
        } catch (_) {
          // Si tampoco se puede eliminar, la cuenta queda creada.
        }
        throw const AuthException(
          'No se pudo completar el registro. Revisa tu conexión e inténtalo de nuevo.',
        );
      }
    } finally {
      _registering = false;
      notifyListeners();
    }
  }

  Future<UserCredential> _createAccount(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  // ID token para las solicitudes HTTP. Devuelve `null` sin sesión.
  Future<String?> idToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken(forceRefresh);
  }

  String _message(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo. Inicia sesión.';
      case 'weak-password':
        return 'La contraseña es muy débil. Usa al menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sin conexión. Revisa tu internet e inténtalo de nuevo.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';
      case 'operation-not-allowed':
        return 'El acceso con correo y contraseña no está habilitado en Firebase.';
      default:
        return 'No se pudo completar la operación. Inténtalo de nuevo.';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
