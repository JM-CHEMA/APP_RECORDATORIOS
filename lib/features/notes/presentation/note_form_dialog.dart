import 'package:flutter/material.dart';
import '../domain/note_model.dart';

class NoteInput {
  const NoteInput({required this.title, required this.content, required this.pinned});
  final String title;
  final String content;
  final bool pinned;
}

class NoteFormDialog extends StatefulWidget {
  const NoteFormDialog({super.key, this.note});
  final NoteModel? note;
  @override
  State<NoteFormDialog> createState() => _NoteFormDialogState();
}

class _NoteFormDialogState extends State<NoteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(text: widget.note?.title ?? '');
  late final TextEditingController _content = TextEditingController(text: widget.note?.content ?? '');
  late bool _pinned = widget.note?.pinned ?? false;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, NoteInput(title: _title.text.trim(),
      content: _content.text.trim(), pinned: _pinned));
  }

  @override
  void dispose() { _title.dispose(); _content.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.note == null ? 'Nueva nota' : 'Editar nota'),
    content: SizedBox(width: 420, child: SingleChildScrollView(child: Form(
      key: _formKey,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: _title, maxLength: 120,
          decoration: const InputDecoration(labelText: 'Título'),
          validator: (value) => value == null || value.trim().isEmpty ? 'Escribe un título.' : null),
        TextFormField(controller: _content, maxLines: 4, maxLength: 3000,
          decoration: const InputDecoration(labelText: 'Contenido')),
        SwitchListTile(title: const Text('Fijar nota'),
          value: _pinned, onChanged: (value) => setState(() => _pinned = value)),
      ]),
    ))),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(onPressed: _save, child: const Text('Guardar')),
    ],
  );
}
