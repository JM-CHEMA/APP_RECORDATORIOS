import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Debe ser una función de nivel superior para ejecutarse fuera del isolate UI.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  debugPrint('FCM en segundo plano: ${message.messageId}');
}

class PushMessagingService {
  PushMessagingService._();
  static final instance = PushMessagingService._();
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenSubscription;

  Future<void> initialize() async {
    // Esta entrega se orienta a Android/iOS; FCM Web exige Service Worker.
    if (kIsWeb) return;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    final messaging = FirebaseMessaging.instance;
    final permissions = await messaging.requestPermission();
    debugPrint('Permisos FCM: ${permissions.authorizationStatus}');
    try {
      final token = await messaging.getToken();
      // Solo para las pruebas de la lección; nunca subir tokens reales al repositorio.
      if (kDebugMode) debugPrint('Token FCM de prueba: $token');
    } catch (error) {
      debugPrint('No se pudo obtener token FCM: $error');
    }
    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen(
      (message) => debugPrint(
        'Push recibida: ${message.notification?.title} | '
        '${message.notification?.body} | ${message.data}',
      ),
    );
    _tokenSubscription ??= messaging.onTokenRefresh.listen(
      (token) { if (kDebugMode) debugPrint('Token FCM actualizado: $token'); },
    );
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _tokenSubscription?.cancel();
    _foregroundSubscription = null;
    _tokenSubscription = null;
  }
}
