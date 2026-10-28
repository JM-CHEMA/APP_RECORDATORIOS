import 'package:flutter/material.dart';
import '../helpers/services/notification_service.dart';
import '../utils/app_errors.dart';
import '../components/async_error_view.dart';
import '../components/confirm_delete.dart';
import '../helpers/services/reminder_coordinator.dart';
import '../models/reminder_model.dart';
import '../components/reminder_form_dialog.dart';
import '../components/reminder_tile.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key, required this.uid});
  final String uid;
  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  late final ReminderCoordinator _coordinator = ReminderCoordinator(widget.uid);
  late final Stream<List<ReminderModel>> _stream = _coordinator.repository.watchAll();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Solicitar permiso durante la interacción normal con la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final permitted = await LocalNotificationService.instance.requestPermission();
        if (!permitted && mounted) _showMessage('Autoriza las notificaciones desde ajustes del dispositivo.');
        if (permitted) await _coordinator.rescheduleUpcoming();
      } catch (error) {
        if (mounted) _showMessage('Revisa la configuración de notificaciones: $error');
      }
    });
  }

  Future<void> _edit([ReminderModel? reminder]) async {
    final input = await showDialog<ReminderInput>(context: context,
      builder: (_) => ReminderFormDialog(uid: widget.uid, reminder: reminder));
    if (input == null || !mounted || _busy) return;
    setState(() => _busy = true);
    try {
      if (reminder == null) {
        await _coordinator.create(scheduledAt: input.scheduledAt, noteId: input.noteId, eventId: input.eventId);
      } else {
        await _coordinator.update(ReminderModel(
          id: reminder.id, scheduledAt: input.scheduledAt,
          noteId: input.noteId, eventId: input.eventId));
      }
    } catch (error) {
      _showMessage(error is ArgumentError ? error.message.toString() : messageForError(error));
      _showMessage('Si se guardó en Firestore pero no se programó el aviso, usa Sincronizar.');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _delete(ReminderModel reminder) async {
    if (_busy || !await confirmDelete(context) || !mounted) return;
    setState(() => _busy = true);
    try { await _coordinator.delete(reminder); }
    catch (error) { _showMessage(messageForError(error)); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _sync() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _coordinator.rescheduleUpcoming();
      _showMessage('Avisos pendientes sincronizados.');
    } catch (error) { _showMessage(messageForError(error)); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _showMessage(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mis recordatorios'), actions: [
      IconButton(tooltip: 'Sincronizar notificaciones', onPressed: _busy ? null : _sync,
        icon: const Icon(Icons.sync)),
    ]),
    body: StreamBuilder<List<ReminderModel>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return AsyncErrorView(error: snapshot.error!);
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final reminders = snapshot.data!;
        if (reminders.isEmpty) return const Center(child: Text('Aún no tienes recordatorios.'));
        return ListView.builder(
          padding: const EdgeInsets.all(12), itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return ReminderTile(
              reminder: reminder,
              onEdit: _busy ? null : () => _edit(reminder),
              onDelete: _busy ? null : () => _delete(reminder),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _busy ? null : () => _edit(),
      label: const Text('Recordatorio'), icon: const Icon(Icons.add)),
  );
}
