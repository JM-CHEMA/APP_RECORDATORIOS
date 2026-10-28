import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../domain/reminder_model.dart';

/// Representación visual de un recordatorio. No accede a Firestore.
class ReminderTile extends StatelessWidget {
  const ReminderTile({super.key, required this.reminder, required this.onEdit, required this.onDelete});
  final ReminderModel reminder;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final relation = reminder.noteId != null
        ? 'Nota: ${reminder.noteId}'
        : reminder.eventId != null
            ? 'Evento: ${reminder.eventId}'
            : 'Independiente';
    return Card(child: ListTile(
      leading: const Icon(Icons.notifications_active_outlined),
      title: Text(DateFormatters.dateTime(reminder.scheduledAt)),
      subtitle: Text(relation),
      onTap: onEdit,
      trailing: IconButton(
        tooltip: 'Eliminar recordatorio', onPressed: onDelete,
        icon: const Icon(Icons.delete_outline)),
    ));
  }
}
