import 'package:flutter/material.dart';
import '../utils/date_formatters.dart';
import '../models/note_model.dart';

/// Presentación visual de una nota. Las operaciones se gestionan en NotesPage.
class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, required this.onEdit, required this.onDelete});
  final NoteModel note;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(note.pinned ? Icons.push_pin : Icons.note_outlined),
      title: Text(note.title),
      subtitle: Text('${note.content}\n${DateFormatters.dateTime(note.createdAt)}',
        maxLines: 3, overflow: TextOverflow.ellipsis),
      isThreeLine: true,
      onTap: onEdit,
      trailing: IconButton(
        tooltip: 'Eliminar nota', onPressed: onDelete,
        icon: const Icon(Icons.delete_outline)),
    ),
  );
}
