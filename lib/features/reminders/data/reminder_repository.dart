import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/reminder_model.dart';

class ReminderRepository {
  ReminderRepository(this.uid, {FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final String uid;
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _reminders =>
      _db.collection('users').doc(uid).collection('reminders');

  Stream<List<ReminderModel>> watchAll() => _reminders.snapshots().map((snapshot) {
    final items = snapshot.docs.map(ReminderModel.fromFirestore).toList();
    items.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return items;
  });

  Future<List<ReminderModel>> getAll() async =>
      (await _reminders.get()).docs.map(ReminderModel.fromFirestore).toList();

  Future<ReminderModel> create({required DateTime scheduledAt, String? noteId, String? eventId}) async {
    if (!scheduledAt.isAfter(DateTime.now())) throw ArgumentError('La fecha debe ser futura.');
    final doc = await _reminders.add({
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'eventId': eventId, 'noteId': noteId,
    });
    return ReminderModel(id: doc.id, scheduledAt: scheduledAt, noteId: noteId, eventId: eventId);
  }

  Future<void> update(ReminderModel reminder) async {
    if (!reminder.scheduledAt.isAfter(DateTime.now())) throw ArgumentError('La fecha debe ser futura.');
    await _reminders.doc(reminder.id).update({
      'scheduledAt': Timestamp.fromDate(reminder.scheduledAt),
      'noteId': reminder.noteId, 'eventId': reminder.eventId,
    });
  }

  Future<void> delete(String id) async => _reminders.doc(id).delete();
}
