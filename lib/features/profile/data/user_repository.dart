import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/user_model.dart';

/// Encapsula todas las operaciones del documento users/{uid}.
class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _db.collection('users').doc(uid);

  Future<void> ensureProfile(User user) async {
    final ref = _doc(user.uid);
    // Crear solo cuando falta evita sobreescribir ediciones previas del usuario.
    final existing = await ref.get();
    if (!existing.exists) {
      await ref.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'displayImage': '',
      });
    }
  }

  Stream<UserModel?> watchProfile(String uid) =>
      _doc(uid).snapshots().map((snapshot) => snapshot.exists ? UserModel.fromFirestore(snapshot) : null);

  Future<void> updateProfile(String uid, {required String displayName, required String displayImage}) async {
    await _doc(uid).update({
      'displayName': displayName.trim(),
      'displayImage': displayImage.trim(),
    });
  }
}
