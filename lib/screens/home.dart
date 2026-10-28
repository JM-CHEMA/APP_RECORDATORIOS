import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helpers/services/notification_service.dart';
import '../utils/app_errors.dart';
import '../helpers/repositories/user_repository.dart';

import 'segunda_pantalla.dart';

/// Pantalla principal de la aplicación.
class MyHome extends StatefulWidget {
  const MyHome({super.key, required this.title});

  final String title;

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  bool _cerrandoSesion = false;

  late final Future<void> _prepararPerfil;

  @override
  void initState() {
    super.initState();

    // Comprueba si el suario existe
    _prepararPerfil = _asegurarPerfil();
  }

  /// Crea el perfil cuando no existe
  Future<void> _asegurarPerfil() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('No existe una sesión activa.');
    }

    await UserRepository().ensureProfile(user);
  }

  /// Cierra la sesion
  Future<void> _cerrarSesion() async {
    if (_cerrandoSesion) return;

    setState(() {
      _cerrandoSesion = true;
    });

    try {
      try {
        await LocalNotificationService.instance.cancelAll();
      } catch (error) {
        debugPrint('Error al cancelar notificaciones: $error');
      }

      await FirebaseAuth.instance.signOut();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(messageForError(error))));
    } finally {
      if (mounted) {
        setState(() {
          _cerrandoSesion = false;
        });
      }
    }
  }

  /// Navega a otra pantalla.
  void _abrir(Widget pagina) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Herramientas
          IconButton(
            tooltip: 'Mis herramientas',
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () {
              _abrir(const SegundaPantalla());
            },
          ),

          // Cierre de sesión.
          if (_cerrandoSesion)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: _cerrarSesion,
            ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Image.asset(
              'assets/images/recordatorio.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),

            // Información del usuario
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuario autenticado',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text('UID: ${user.uid}'),
                    const SizedBox(height: 8),
                    Text('Correo: ${user.email ?? "Sin correo"}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Muestra el estado de preparación del perfil
            FutureBuilder<void>(
              future: _prepararPerfil,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text(
                    'No se pudo sincronizar el perfil.',
                    textAlign: TextAlign.center,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
