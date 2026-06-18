import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'achievement_model.dart';

class UserAchievement {
  final Achievement achievement;
  final bool isUnlocked;
  final bool isClaimed;
  final int currentCount;

  const UserAchievement({
    required this.achievement,
    required this.isUnlocked,
    required this.isClaimed,
    required this.currentCount,
  });
}

final achievementsProvider =
    StreamProvider<List<UserAchievement>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    final data = doc.data() ?? {};
    final unlockedIds = List<String>.from(
        data['unlockedAchievements'] ?? []);
    final claimedIds =
        List<String>.from(data['claimedAchievements'] ?? []);
    final wins = data['wins'] ?? 0;

    return allAchievements.map((achievement) {
      int currentCount = 0;
      if (achievement.id == 'first_win' ||
          achievement.id == 'brain_master' ||
          achievement.id == 'veteran') {
        currentCount = wins;
      }

      final isUnlocked = unlockedIds.contains(achievement.id) ||
          currentCount >= achievement.requiredCount;

      return UserAchievement(
        achievement: achievement,
        isUnlocked: isUnlocked,
        isClaimed: claimedIds.contains(achievement.id),
        currentCount: currentCount,
      );
    }).toList();
  });
});

class AchievementNotifier extends StateNotifier<bool> {
  AchievementNotifier() : super(false);

  Future<void> claimAchievement(String achievementId,
      int rewardCoins) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'claimedAchievements':
          FieldValue.arrayUnion([achievementId]),
      'coins': FieldValue.increment(rewardCoins),
    });
  }
}

final achievementNotifierProvider =
    StateNotifierProvider<AchievementNotifier, bool>((ref) {
  return AchievementNotifier();
});