import '../../../core/services/local_notification_service.dart';
import '../../events/data/event_repository.dart';
import '../../notes/data/note_repository.dart';
import '../domain/reminder_model.dart';
import 'reminder_repository.dart';

/// Coordina Firestore y avisos locales; la UI no conoce los detalles del plugin.
/// Firestore es la fuente de verdad; si la programación falla se puede reintentar.
class ReminderCoordinator {
  ReminderCoordinator(this.uid)
      : repository = ReminderRepository(uid),
        _notifications = LocalNotificationService.instance;

  final String uid;
  final ReminderRepository repository;
  final LocalNotificationService _notifications;

  Future<({String title, String body})> _notificationContent(ReminderModel reminder) async {
    if (reminder.noteId != null) {
      final notes = await NoteRepository(uid).getAll();
      for (final note in notes) {
        if (note.id == reminder.noteId) return (title: 'Recordatorio de nota', body: note.title);
      }
    }
    if (reminder.eventId != null) {
      final events = await EventRepository(uid).getAll();
      for (final event in events) {
        if (event.id == reminder.eventId) return (title: 'Recordatorio de evento', body: event.title);
      }
    }
    return (title: 'Recordatorio', body: 'Tienes una actividad programada.');
  }

  Future<void> _schedule(ReminderModel reminder) async {
    final message = await _notificationContent(reminder);
    await _notifications.schedule(
      uid: uid, reminderId: reminder.id,
      title: message.title, body: message.body, scheduledAt: reminder.scheduledAt,
    );
  }

  Future<void> create({required DateTime scheduledAt, String? noteId, String? eventId}) async {
    final reminder = await repository.create(scheduledAt: scheduledAt, noteId: noteId, eventId: eventId);
    await _schedule(reminder);
  }

  Future<void> update(ReminderModel reminder) async {
    await repository.update(reminder);
    await _notifications.cancel(uid, reminder.id);
    await _schedule(reminder);
  }

  Future<void> delete(ReminderModel reminder) async {
    await repository.delete(reminder.id);
    await _notifications.cancel(uid, reminder.id);
  }

  /// Resincroniza los recordatorios pendientes tras reabrir la app.
  Future<void> rescheduleUpcoming() async {
    final reminders = await repository.getAll();
    for (final reminder in reminders) {
      if (reminder.scheduledAt.isAfter(DateTime.now())) await _schedule(reminder);
    }
  }
}
