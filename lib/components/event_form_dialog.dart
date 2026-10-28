import 'package:flutter/material.dart';
import 'date_time_picker_field.dart';
import '../models/event_model.dart';

class EventInput {
  const EventInput({required this.title, required this.description,
    required this.startDate, required this.endDate});
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
}

class EventFormDialog extends StatefulWidget {
  const EventFormDialog({super.key, this.event});
  final EventModel? event;
  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.event?.title ?? '');
  late final _description = TextEditingController(text: widget.event?.description ?? '');
  late DateTime _start = widget.event?.startDate ?? DateTime.now().add(const Duration(hours: 1));
  late DateTime _end = widget.event?.endDate ?? DateTime.now().add(const Duration(hours: 2));
  String? _dateError;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (!_end.isAfter(_start)) {
      setState(() => _dateError = 'El fin debe ser posterior al inicio.');
      return;
    }
    Navigator.pop(context, EventInput(title: _title.text.trim(),
      description: _description.text.trim(), startDate: _start, endDate: _end));
  }

  @override
  void dispose() { _title.dispose(); _description.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.event == null ? 'Nuevo evento' : 'Editar evento'),
    content: SizedBox(width: 440, child: SingleChildScrollView(child: Form(
      key: _formKey,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: _title, maxLength: 120,
          decoration: const InputDecoration(labelText: 'Título'),
          validator: (value) => value == null || value.trim().isEmpty ? 'Escribe un título.' : null),
        TextFormField(controller: _description, maxLength: 1000, maxLines: 2,
          decoration: const InputDecoration(labelText: 'Descripción')),
        DateTimePickerField(label: 'Inicio', value: _start,
          onChanged: (date) => setState(() { _start = date; _dateError = null; })),
        DateTimePickerField(label: 'Fin', value: _end,
          onChanged: (date) => setState(() { _end = date; _dateError = null; })),
        if (_dateError != null) Text(_dateError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
    ))),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(onPressed: _save, child: const Text('Guardar')),
    ],
  );
}
