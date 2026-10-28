import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/note_model.dart';

class NoteRepository {
  NoteRepository(this.uid, {FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final String uid;
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _notes =>
      _db.collection('users').doc(uid).collection('notes');

  Stream<List<NoteModel>> watchAll() => _notes.snapshots().map((snapshot) {
    final items = snapshot.docs.map(NoteModel.fromFirestore).toList();
    items.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return items;
  });

  Future<List<NoteModel>> getAll() async =>
      (await _notes.get()).docs.map(NoteModel.fromFirestore).toList();

  Future<void> create({required String title, required String content, required bool pinned}) async {
    await _notes.add({
      'title': title.trim(), 'content': content.trim(), 'pinned': pinned,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(String id, {required String title, required String content, required bool pinned}) async {
    await _notes.doc(id).update({'title': title.trim(), 'content': content.trim(), 'pinned': pinned});
  }

  Future<void> delete(String id) async => _notes.doc(id).delete();
}
