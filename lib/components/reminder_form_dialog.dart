import 'package:flutter/material.dart';
import 'date_time_picker_field.dart';
import '../helpers/repositories/event_repository.dart';
import '../models/event_model.dart';
import '../helpers/repositories/note_repository.dart';
import '../models/note_model.dart';
import '../models/reminder_model.dart';

class ReminderInput {
  const ReminderInput({required this.scheduledAt, this.eventId, this.noteId});
  final DateTime scheduledAt;
  final String? eventId;
  final String? noteId;
}

class ReminderFormDialog extends StatefulWidget {
  const ReminderFormDialog({super.key, required this.uid, this.reminder});
  final String uid;
  final ReminderModel? reminder;
  @override
  State<ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<ReminderFormDialog> {
  late DateTime _scheduledAt = widget.reminder?.scheduledAt ?? DateTime.now().add(const Duration(hours: 1));
  late String _relation = widget.reminder?.noteId != null ? 'note' :
      widget.reminder?.eventId != null ? 'event' : 'none';
  late String? _selectedId = widget.reminder?.noteId ?? widget.reminder?.eventId;
  late final Future<(List<NoteModel>, List<EventModel>)> _references = _loadReferences();
  String? _error;

  Future<(List<NoteModel>, List<EventModel>)> _loadReferences() async {
    // Ambas consultas se inician antes de esperar sus resultados.
    final notesFuture = NoteRepository(widget.uid).getAll();
    final eventsFuture = EventRepository(widget.uid).getAll();
    return (await notesFuture, await eventsFuture);
  }

  void _save() {
    if (!_scheduledAt.isAfter(DateTime.now())) {
      setState(() => _error = 'Selecciona una fecha y hora futuras.');
      return;
    }
    if (_relation != 'none' && _selectedId == null) {
      setState(() => _error = 'Selecciona una nota o un evento.');
      return;
    }
    Navigator.pop(context, ReminderInput(
      scheduledAt: _scheduledAt,
      noteId: _relation == 'note' ? _selectedId : null,
      eventId: _relation == 'event' ? _selectedId : null,
    ));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.reminder == null ? 'Nuevo recordatorio' : 'Editar recordatorio'),
    content: SizedBox(width: 440, child: SingleChildScrollView(child: Column(
      mainAxisSize: MainAxisSize.min, children: [
        DateTimePickerField(label: 'Programar para', value: _scheduledAt,
          minimum: DateTime.now(),
          onChanged: (date) => setState(() { _scheduledAt = date; _error = null; })),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _relation,
          decoration: const InputDecoration(labelText: 'Relacionar con'),
          items: const [
            DropdownMenuItem(value: 'none', child: Text('Sin relación')),
            DropdownMenuItem(value: 'note', child: Text('Nota')),
            DropdownMenuItem(value: 'event', child: Text('Evento')),
          ],
          onChanged: (value) => setState(() { _relation = value ?? 'none'; _selectedId = null; }),
        ),
        if (_relation != 'none') FutureBuilder<(List<NoteModel>, List<EventModel>)>(
          future: _references,
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Text('No se pudieron cargar las notas y eventos.');
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final options = _relation == 'note'
                ? snapshot.data!.$1.map((note) => (note.id, note.title)).toList()
                : snapshot.data!.$2.map((event) => (event.id, event.title)).toList();
            final availableId = options.any((entry) => entry.$1 == _selectedId) ? _selectedId : null;
            return DropdownButtonFormField<String>(
              key: ValueKey(_relation),
              initialValue: availableId,
              isExpanded: true,
              decoration: InputDecoration(labelText: _relation == 'note' ? 'Nota' : 'Evento'),
              items: options.map((entry) => DropdownMenuItem(
                value: entry.$1, child: Text(entry.$2, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (value) => setState(() => _selectedId = value),
            );
          },
        ),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 12),
          child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      ],
    ))),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(onPressed: _save, child: const Text('Guardar')),
    ],
  );
}
