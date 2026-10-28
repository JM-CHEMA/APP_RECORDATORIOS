import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  const NoteModel({required this.id, required this.title,
    required this.content, required this.pinned, required this.createdAt});
  final String id;
  final String title;
  final String content;
  final bool pinned;
  final DateTime createdAt;

  factory NoteModel.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final values = document.data();
    return NoteModel(
      id: document.id,
      title: values['title'] as String? ?? '',
      content: values['content'] as String? ?? '',
      pinned: values['pinned'] as bool? ?? false,
      createdAt: (values['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
