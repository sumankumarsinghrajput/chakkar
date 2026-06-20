import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

// 7-day streak cycle, resets after day 7 or if a day is missed
const List<int> streakRewards = [20, 30, 40, 60, 80, 100, 150];

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

class StreakData {
  final int currentStreak;
  final bool claimedToday;
  final String lastClaimDate;

  const StreakData({
    required this.currentStreak,
    required this.claimedToday,
    required this.lastClaimDate,
  });

  int get todayRewardIndex => (currentStreak) % 7;
  int get todayReward => streakRewards[todayRewardIndex];
}

final streakProvider = StreamProvider<StreakData>((ref) {
  final user = _auth.currentUser;
  if (user == null) {
    return Stream.value(const StreakData(currentStreak: 0, claimedToday: false, lastClaimDate: ''));
  }

  return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
    final data = doc.data() ?? {};
    final streak = data['loginStreak'] ?? 0;
    final lastClaim = data['lastClaimDate'] ?? '';
    final claimedToday = lastClaim == _todayKey();
    return StreakData(
      currentStreak: streak,
      claimedToday: claimedToday,
      lastClaimDate: lastClaim,
    );
  });
});

class RewardsNotifier extends StateNotifier<bool> {
  RewardsNotifier() : super(false);

  Future<int> claimDailyReward() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};
    final lastClaim = data['lastClaimDate'] ?? '';
    final currentStreak = data['loginStreak'] ?? 0;

    final today = _todayKey();
    if (lastClaim == today) return 0; // already claimed

    // Check if streak continues (claimed yesterday) or resets
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    int newStreak;
    if (lastClaim == yesterdayKey) {
      newStreak = currentStreak + 1;
    } else {
      newStreak = 0; // reset streak, start at day 1 (index 0)
    }

    final rewardIndex = newStreak % 7;
    final reward = streakRewards[rewardIndex];

    await _firestore.collection('users').doc(user.uid).update({
      'loginStreak': newStreak,
      'lastClaimDate': today,
      'coins': FieldValue.increment(reward),
    });

    return reward;
  }
}

final rewardsNotifierProvider =
    StateNotifierProvider<RewardsNotifier, bool>((ref) => RewardsNotifier());