import 'package:flutter/material.dart';
import '../utils/app_errors.dart';
import '../components/async_error_view.dart';
import '../components/confirm_delete.dart';
import '../helpers/repositories/event_repository.dart';
import '../models/event_model.dart';
import '../components/event_form_dialog.dart';
import '../components/event_card.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key, required this.uid});
  final String uid;
  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final EventRepository _repository = EventRepository(widget.uid);
  late final Stream<List<EventModel>> _stream = _repository.watchAll();
  bool _busy = false;

  Future<void> _edit([EventModel? event]) async {
    final input = await showDialog<EventInput>(context: context,
      builder: (_) => EventFormDialog(event: event));
    if (input == null || !mounted || _busy) return;
    setState(() => _busy = true);
    try {
      if (event == null) {
        await _repository.create(title: input.title, description: input.description,
          startDate: input.startDate, endDate: input.endDate);
      } else {
        await _repository.update(event.id, title: input.title, description: input.description,
          startDate: input.startDate, endDate: input.endDate);
      }
    } catch (error) { _showError(error); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _delete(EventModel event) async {
    if (_busy || !await confirmDelete(context) || !mounted) return;
    setState(() => _busy = true);
    try { await _repository.delete(event.id); }
    catch (error) { _showError(error); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _showError(Object error) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error is ArgumentError ? error.message.toString() : messageForError(error))));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mis eventos')),
    body: StreamBuilder<List<EventModel>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return AsyncErrorView(error: snapshot.error!);
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final events = snapshot.data!;
        if (events.isEmpty) return const Center(child: Text('Aún no tienes eventos.'));
        return ListView.builder(
          padding: const EdgeInsets.all(12), itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              event: event,
              onEdit: _busy ? null : () => _edit(event),
              onDelete: _busy ? null : () => _delete(event),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _busy ? null : () => _edit(),
      label: const Text('Nuevo evento'), icon: const Icon(Icons.add)),
  );
}
