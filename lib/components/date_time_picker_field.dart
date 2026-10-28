import 'package:flutter/material.dart';
import '../utils/date_formatters.dart';

/// Campo de solo lectura que combina calendario y selector de hora.
class DateTimePickerField extends StatelessWidget {
  const DateTimePickerField({super.key, required this.label, required this.value,
    required this.onChanged, this.minimum});
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? minimum;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final earliest = minimum ?? DateTime(2000);
    final first = DateTime(earliest.year, earliest.month, earliest.day);
    final preferred = value.isBefore(first) ? first : value;
    final day = await showDatePicker(
      context: context,
      initialDate: preferred,
      firstDate: first,
      lastDate: DateTime(now.year + 20),
    );
    if (day == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (time == null || !context.mounted) return;
    onChanged(DateTime(day.year, day.month, day.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => _pick(context),
    icon: const Icon(Icons.event),
    label: Text('$label: ${DateFormatters.dateTime(value)}'),
  );
}
