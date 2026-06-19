import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchMode { single, multiplayer }

class MatchRecord {
  final String id;
  final MatchMode mode;
  final String category;
  final String difficulty;
  final int score;
  final int correct;
  final int wrong;
  final int total;
  final bool isWin;
  final int? rank;
  final int? totalPlayers;
  final DateTime playedAt;

  const MatchRecord({
    required this.id,
    required this.mode,
    required this.category,
    required this.difficulty,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.isWin,
    this.rank,
    this.totalPlayers,
    required this.playedAt,
  });

  factory MatchRecord.fromMap(Map<String, dynamic> map, String id) {
    return MatchRecord(
      id: id,
      mode: map['mode'] == 'multiplayer' ? MatchMode.multiplayer : MatchMode.single,
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? '',
      score: map['score'] ?? 0,
      correct: map['correct'] ?? 0,
      wrong: map['wrong'] ?? 0,
      total: map['total'] ?? 0,
      isWin: map['isWin'] ?? false,
      rank: map['rank'],
      totalPlayers: map['totalPlayers'],
      playedAt: (map['playedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mode': mode == MatchMode.multiplayer ? 'multiplayer' : 'single',
      'category': category,
      'difficulty': difficulty,
      'score': score,
      'correct': correct,
      'wrong': wrong,
      'total': total,
      'isWin': isWin,
      'rank': rank,
      'totalPlayers': totalPlayers,
      'playedAt': FieldValue.serverTimestamp(),
    };
  }

  double get accuracy => total == 0 ? 0 : (correct / total) * 100;
}