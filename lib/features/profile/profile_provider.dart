import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';

final profileProvider = StreamProvider<UserModel?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  });
});

class ProfileNotifier extends StateNotifier<bool> {
  ProfileNotifier() : super(false);

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> updateUsername(String newUsername) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Check availability
    final existing = await FirebaseFirestore.instance
        .collection('usernames')
        .doc(newUsername.toLowerCase())
        .get();

    if (existing.exists) throw Exception('Username already taken');

    // Get old username
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final oldUsername = userDoc.data()?['username'] ?? '';

    // Delete old username
    await FirebaseFirestore.instance
        .collection('usernames')
        .doc(oldUsername)
        .delete();

    // Update user
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'username': newUsername.toLowerCase(),
      'displayUsername': newUsername,
    });

    // Reserve new username
    await FirebaseFirestore.instance
        .collection('usernames')
        .doc(newUsername.toLowerCase())
        .set({'uid': user.uid});
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, bool>((ref) {
  return ProfileNotifier();
});