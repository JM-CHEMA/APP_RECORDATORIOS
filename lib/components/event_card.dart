import 'package:flutter/material.dart';
import '../utils/date_formatters.dart';
import '../models/event_model.dart';

/// Componente visual para un evento con su intervalo de fechas.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.onEdit, required this.onDelete});
  final EventModel event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.event_note),
      title: Text(event.title),
      subtitle: Text(
        '${event.description}\n'
        '${DateFormatters.dateTime(event.startDate)} — '
        '${DateFormatters.dateTime(event.endDate)}',
        maxLines: 3, overflow: TextOverflow.ellipsis),
      isThreeLine: true,
      onTap: onEdit,
      trailing: IconButton(
        tooltip: 'Eliminar evento', onPressed: onDelete,
        icon: const Icon(Icons.delete_outline)),
    ),
  );
}
