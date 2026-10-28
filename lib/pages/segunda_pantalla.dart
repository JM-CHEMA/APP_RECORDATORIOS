import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/home_menu_card.dart';
import '../features/events/presentation/events_page.dart';
import '../features/notes/presentation/notes_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/reminders/presentation/reminders_page.dart';

class SegundaPantalla extends StatelessWidget {
  const SegundaPantalla({super.key});

  /// Abre la nueva pantalla
  void _abrir(BuildContext context, Widget pagina) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el usuario que mantiene una sesión activa.
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No hay una sesión activa.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis herramientas'), centerTitle: true),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Mis herramientas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            HomeMenuCard(
              title: 'Mi perfil',
              subtitle: 'Consultar y editar nombre e imagen',
              icon: Icons.person_outline,
              onTap: () => _abrir(context, ProfilePage(uid: user.uid)),
            ),

            const SizedBox(height: 8),

            HomeMenuCard(
              title: 'Notas',
              subtitle: 'Crear, editar, fijar y eliminar notas',
              icon: Icons.note_alt_outlined,
              onTap: () => _abrir(context, NotesPage(uid: user.uid)),
            ),

            const SizedBox(height: 8),

            HomeMenuCard(
              title: 'Eventos',
              subtitle: 'Administrar fechas y horarios',
              icon: Icons.event_outlined,
              onTap: () => _abrir(context, EventsPage(uid: user.uid)),
            ),

            const SizedBox(height: 8),

            HomeMenuCard(
              title: 'Recordatorios',
              subtitle: 'Programar avisos y asociar notas o eventos',
              icon: Icons.notifications_active_outlined,
              onTap: () => _abrir(context, RemindersPage(uid: user.uid)),
            ),
          ],
        ),
      ),
    );
  }
}
