import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  bool isAdmin;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.isAdmin,
  });

  factory AppUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAdmin': isAdmin,
    };
  }

  Future<void> updateAdminStatus(bool isAdmin) async {
    await FirebaseFirestore.instance.collection('users').doc(id).update({
      'isAdmin': isAdmin,
    });
    this.isAdmin = isAdmin;
  }
}