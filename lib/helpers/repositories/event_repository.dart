import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event_model.dart';

class EventRepository {
  EventRepository(this.uid, {FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final String uid;
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('users').doc(uid).collection('events');

  Stream<List<EventModel>> watchAll() => _events.snapshots().map((snapshot) {
    final items = snapshot.docs.map(EventModel.fromFirestore).toList();
    items.sort((a, b) => a.startDate.compareTo(b.startDate));
    return items;
  });

  Future<List<EventModel>> getAll() async =>
      (await _events.get()).docs.map(EventModel.fromFirestore).toList();

  Future<void> create({required String title, required String description,
      required DateTime startDate, required DateTime endDate}) async {
    if (!endDate.isAfter(startDate)) throw ArgumentError('La fecha final debe ser posterior a la inicial.');
    await _events.add({
      'title': title.trim(), 'description': description.trim(),
      'startDate': Timestamp.fromDate(startDate), 'endDate': Timestamp.fromDate(endDate),
    });
  }

  Future<void> update(String id, {required String title, required String description,
      required DateTime startDate, required DateTime endDate}) async {
    if (!endDate.isAfter(startDate)) throw ArgumentError('La fecha final debe ser posterior a la inicial.');
    await _events.doc(id).update({
      'title': title.trim(), 'description': description.trim(),
      'startDate': Timestamp.fromDate(startDate), 'endDate': Timestamp.fromDate(endDate),
    });
  }

  Future<void> delete(String id) async => _events.doc(id).delete();
}
