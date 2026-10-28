import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({required this.uid, required this.email,
    required this.displayName, required this.displayImage});
  final String uid;
  final String email;
  final String displayName;
  final String displayImage;

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final values = doc.data() ?? {};
    return UserModel(
      uid: doc.id,
      email: values['email'] as String? ?? '',
      displayName: values['displayName'] as String? ?? '',
      displayImage: values['displayImage'] as String? ?? '',
    );
  }
}
