import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  const EventModel({required this.id, required this.title, required this.description,
    required this.startDate, required this.endDate});
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  factory EventModel.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final values = document.data();
    return EventModel(
      id: document.id,
      title: values['title'] as String? ?? '',
      description: values['description'] as String? ?? '',
      startDate: (values['startDate'] as Timestamp).toDate(),
      endDate: (values['endDate'] as Timestamp).toDate(),
    );
  }
}
