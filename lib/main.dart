import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'helpers/services/push_messaging_service.dart';
import 'app_theme.dart';
import 'firebase_options.dart';
import 'components/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
  // FCM se prepara sin bloquear el primer dibujo de la aplicación.
  unawaited(_configurarMensajeria());
}

Future<void> _configurarMensajeria() async {
  try {
    await PushMessagingService.instance.initialize();
  } catch (error) {
    debugPrint('FCM no disponible: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Freepi Recordatorios',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const AuthGate(),
  );
}
