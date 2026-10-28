import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Convierte los errores esperados del backend en mensajes para la interfaz.
String messageForError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'requires-recent-login':
        return 'Vuelve a iniciar sesión para realizar esta operación.';
      case 'network-request-failed':
        return 'No hay conexión. Revisa tu internet.';
      default:
        return error.message ?? 'No se pudo completar la autenticación.';
    }
  }
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'No tienes permisos para realizar esta operación.';
      case 'unavailable':
        return 'Servicio temporalmente no disponible. Inténtalo nuevamente.';
      case 'not-found':
        return 'El registro solicitado ya no existe.';
      default:
        return 'No fue posible acceder a Firebase (${error.code}).';
    }
  }
  return 'Ocurrió un problema inesperado. Inténtalo nuevamente.';
}
