import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  const ReminderModel({required this.id, required this.scheduledAt,
    this.eventId, this.noteId});
  final String id;
  final DateTime scheduledAt;
  final String? eventId;
  final String? noteId;

  factory ReminderModel.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final values = document.data();
    return ReminderModel(
      id: document.id,
      scheduledAt: (values['scheduledAt'] as Timestamp).toDate(),
      eventId: values['eventId'] as String?,
      noteId: values['noteId'] as String?,
    );
  }
}
