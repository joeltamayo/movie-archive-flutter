import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Error devuelto por Firestore (código HTTP y cuerpo de la respuesta).
class ApiException implements Exception {
  const ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}

// Entrega el ID token de la sesión actual. Con `forceRefresh` pide uno nuevo.
typedef TokenProvider = Future<String?> Function({bool forceRefresh});

// Cliente HTTP de la API REST de Firestore.
//
// Cada solicitud lleva el ID token de Firebase Auth en la cabecera. Si responde 401 (token vencido) renueva el token y reintenta una vez.
class FirestoreRest {
  FirestoreRest({
    required this.projectId,
    required this.tokenProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String projectId;
  final TokenProvider tokenProvider;
  final http.Client _client;

  static const _timeout = Duration(seconds: 20);

  // `path` es relativo a `documents/`, por ejemplo `users/abc123`.
  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.https(
      'firestore.googleapis.com',
      '/v1/projects/$projectId/databases/(default)/documents/$path',
      query,
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _send('GET', _uri(path, query));
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, dynamic>? query,
  }) {
    return _send('POST', _uri(path, query), body: body);
  }

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body, {
    Map<String, dynamic>? query,
  }) {
    return _send('PATCH', _uri(path, query), body: body);
  }

  Future<void> delete(String path) async {
    await _send('DELETE', _uri(path));
  }

  Future<Map<String, dynamic>> _send(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final token = await tokenProvider(forceRefresh: attempt == 1);
      if (token == null) {
        throw const ApiException(401, 'No hay una sesión activa.');
      }

      final request = http.Request(method, uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Content-Type'] = 'application/json';
      if (body != null) request.body = jsonEncode(body);

      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 401 && attempt == 0) continue;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final text = utf8.decode(response.bodyBytes);
        if (kDebugMode) {
          debugPrint('Firestore $method ${uri.path} -> ${response.statusCode}: $text');
        }
        throw ApiException(response.statusCode, text);
      }
      if (response.bodyBytes.isEmpty) return <String, dynamic>{};

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    }
    throw const ApiException(401, 'La sesión expiró.');
  }
}

// Valores con el formato de tipos de Firestore REST (escritura).

Map<String, dynamic> fsString(String value) => {'stringValue': value};

  // `path` es relativo a `documents/`, por ejemplo `users/abc123`.
Map<String, dynamic> fsInt(int value) => {'integerValue': '$value'};

Map<String, dynamic> fsTimestamp(DateTime value) =>
    {'timestampValue': value.toUtc().toIso8601String()};

// Lectura de campos de un documento (`fields`). Si falta el campo o tiene otro tipo, devuelven un valor vacío en lugar de lanzar un error.
String fsReadString(Map<String, dynamic> fields, String key) {
  final value = fields[key];
  if (value is Map<String, dynamic>) {
    final text = value['stringValue'];
    if (text is String) return text;
  }
  return '';
}

int fsReadInt(Map<String, dynamic> fields, String key) {
  final value = fields[key];
  if (value is Map<String, dynamic>) {
    final integer = value['integerValue'];
    if (integer is String) return int.tryParse(integer) ?? 0;
    if (integer is num) return integer.toInt();
    final decimal = value['doubleValue'];
    if (decimal is num) return decimal.toInt();
  }
  return 0;
}
