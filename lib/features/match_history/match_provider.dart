import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'match_model.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

Future<void> saveMatchRecord({
  required MatchMode mode,
  required String category,
  required String difficulty,
  required int score,
  required int correct,
  required int wrong,
  required int total,
  required bool isWin,
  int? rank,
  int? totalPlayers,
}) async {
  final user = _auth.currentUser;
  if (user == null) return;

  final record = MatchRecord(
    id: '',
    mode: mode,
    category: category,
    difficulty: difficulty,
    score: score,
    correct: correct,
    wrong: wrong,
    total: total,
    isWin: isWin,
    rank: rank,
    totalPlayers: totalPlayers,
    playedAt: DateTime.now(),
  );

  await _firestore
      .collection('users')
      .doc(user.uid)
      .collection('matches')
      .add(record.toMap());

  // Update win/loss counters on user doc
  await _firestore.collection('users').doc(user.uid).update({
    if (isWin) 'wins': FieldValue.increment(1),
    if (!isWin) 'losses': FieldValue.increment(1),
    'xp': FieldValue.increment(score ~/ 10),
  });
}

final matchHistoryProvider = StreamProvider<List<MatchRecord>>((ref) {
  final user = _auth.currentUser;
  if (user == null) return Stream.value([]);

  return _firestore
      .collection('users')
      .doc(user.uid)
      .collection('matches')
      .orderBy('playedAt', descending: true)
      .limit(30)
      .snapshots()
      .map((query) =>
          query.docs.map((doc) => MatchRecord.fromMap(doc.data(), doc.id)).toList());
});