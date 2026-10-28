import 'package:flutter/material.dart';
import '../utils/app_errors.dart';
import '../components/async_error_view.dart';
import '../helpers/repositories/user_repository.dart';
import '../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.uid});
  final String uid;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _repository = UserRepository();
  final _name = TextEditingController();
  final _image = TextEditingController();
  bool _saving = false;
  bool _filled = false;
  late final Stream<UserModel?> _profileStream = _repository.watchProfile(widget.uid);

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      await _repository.updateProfile(widget.uid,
        displayName: _name.text, displayImage: _image.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(messageForError(error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() { _name.dispose(); _image.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mi perfil')),
    body: StreamBuilder<UserModel?>(
      stream: _profileStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AsyncErrorView(error: snapshot.error!);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final profile = snapshot.data;
        if (profile == null) {
          return const Center(child: Text('Perfil no disponible.'));
        }
        if (!_filled) {
          _name.text = profile.displayName;
          _image.text = profile.displayImage;
          _filled = true;
        }
        return ListView(padding: const EdgeInsets.all(20), children: [
          Text('UID: ${profile.uid}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('Correo: ${profile.email}'),
          const SizedBox(height: 20),
          TextField(controller: _name, maxLength: 100,
            decoration: const InputDecoration(labelText: 'Nombre público')),
          TextField(controller: _image,
            decoration: const InputDecoration(labelText: 'URL de imagen (opcional)')),
          const SizedBox(height: 16),
          FilledButton(onPressed: _saving ? null : _save,
            child: _saving ? const CircularProgressIndicator() : const Text('Guardar perfil')),
        ]);
      },
    ),
  );
}
