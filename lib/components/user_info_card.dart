import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Muestra los datos proporcionados por Firebase Authentication.
class UserInfoCard extends StatelessWidget {
  const UserInfoCard({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sesión activa', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const Text('ID del usuario'),
            SelectableText(user.uid, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            const Text('Correo electrónico'),
            SelectableText(user.email ?? 'Sin correo registrado'),
          ],
        ),
      ),
    );
  }
}
