/// Reglas de validación compartidas por los formularios de acceso.
abstract final class FormValidators {
  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingresa tu correo.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña.';
    }
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña.';
    }
    if (value.length < 6) {
      return 'Usa al menos 6 caracteres.';
    }
    return null;
  }
}
