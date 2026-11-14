import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:movie_archive/data/services/firestore_rest.dart';

/// Traduce un error técnico a un mensaje claro para la persona usuaria.
String describeError(
  Object error, {
  String fallback = 'Ocurrió un error. Inténtalo de nuevo.',
}) {
  if (error is ApiException) {
    switch (error.statusCode) {
      case 400:
        return 'Los datos enviados no son válidos. Revisa el formulario.';
      case 401:
        return 'Tu sesión expiró. Cierra sesión y vuelve a entrar.';
      case 403:
        return 'No tienes permiso para realizar esta acción.';
      case 404:
        return 'La película ya no existe. Puede que se haya eliminado.';
      case 429:
        return 'Demasiadas solicitudes. Espera un momento e inténtalo de nuevo.';
    }
    if (error.statusCode >= 500) {
      return 'El servicio no está disponible. Inténtalo en unos minutos.';
    }
    return fallback;
  }

  if (error is SocketException ||
      error is TimeoutException ||
      error is http.ClientException) {
    return 'Sin conexión. Revisa tu internet e inténtalo de nuevo.';
  }

  return fallback;
}
