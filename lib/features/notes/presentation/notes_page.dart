import 'package:flutter/material.dart';
import '../../../core/utils/app_errors.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/confirm_delete.dart';
import '../data/note_repository.dart';
import '../domain/note_model.dart';
import 'note_form_dialog.dart';
import 'widgets/note_card.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key, required this.uid});
  final String uid;
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final NoteRepository _repository = NoteRepository(widget.uid);
  late final Stream<List<NoteModel>> _stream = _repository.watchAll();
  bool _busy = false;

  Future<void> _edit([NoteModel? note]) async {
    final input = await showDialog<NoteInput>(
      context: context, builder: (_) => NoteFormDialog(note: note));
    if (input == null || !mounted || _busy) return;
    setState(() => _busy = true);
    try {
      if (note == null) {
        await _repository.create(title: input.title, content: input.content, pinned: input.pinned);
      } else {
        await _repository.update(note.id, title: input.title, content: input.content, pinned: input.pinned);
      }
    } catch (error) { _showError(error); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _delete(NoteModel note) async {
    if (_busy || !await confirmDelete(context) || !mounted) return;
    setState(() => _busy = true);
    try { await _repository.delete(note.id); }
    catch (error) { _showError(error); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _showError(Object error) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageForError(error))));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mis notas')),
    body: StreamBuilder<List<NoteModel>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return AsyncErrorView(error: snapshot.error!);
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final notes = snapshot.data!;
        if (notes.isEmpty) return const Center(child: Text('Aún no tienes notas.'));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(
              note: note,
              onEdit: _busy ? null : () => _edit(note),
              onDelete: _busy ? null : () => _delete(note),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _busy ? null : () => _edit(),
      label: const Text('Nueva nota'), icon: const Icon(Icons.add)),
  );
}
