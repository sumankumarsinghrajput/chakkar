import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';

final leaderboardProvider = StreamProvider<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('wins', descending: true)
      .limit(50)
      .snapshots()
      .map((query) => query.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList());
});

final myRankProvider = FutureProvider<int>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 0;

  final query = await FirebaseFirestore.instance
      .collection('users')
      .orderBy('wins', descending: true)
      .get();

  final index =
      query.docs.indexWhere((doc) => doc.id == user.uid);
  return index + 1;
});