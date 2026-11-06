// Validaciones reutilizables para los formularios.
class Validators {
  Validators._();

  static String? notEmpty(
    String? value, {
    String message = 'Este campo es obligatorio',
  }) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    final empty = notEmpty(value, message: 'Escribe tu correo');
    if (empty != null) return empty;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim());
    return ok ? null : 'Correo no válido. Ejemplo: nombre@correo.com';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Escribe tu contraseña';
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? year(String? value) {
    const message = 'Año no válido. Escribe 4 dígitos, por ejemplo 1982.';
    final text = value?.trim() ?? '';
    final parsed = int.tryParse(text);
    final maxYear = DateTime.now().year + 5;
    if (text.length != 4 || parsed == null || parsed < 1888 || parsed > maxYear) {
      return message;
    }
    return null;
  }

  static String? imageUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Pega la URL de la imagen';
    final uri = Uri.tryParse(text);
    final ok = uri != null &&
        uri.hasAuthority &&
        (uri.scheme == 'http' || uri.scheme == 'https');
    return ok ? null : 'La URL debe empezar con http:// o https://';
  }
}
