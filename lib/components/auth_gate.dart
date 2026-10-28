import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/home.dart';
import '../pages/login.dart';

/// Pantalla raíz que decide qué sección mostrar según la sesión de Firebase.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Stream<User?> _sesion;

  @override
  void initState() {
    super.initState();
    _escucharSesion();
  }

  void _escucharSesion() {
    _sesion = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _sesion,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudo consultar la sesión.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(_escucharSesion),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == null
            ? const Login()
            : const MyHome(title: 'Freepi Recordatorios');
      },
    );
  }
}
