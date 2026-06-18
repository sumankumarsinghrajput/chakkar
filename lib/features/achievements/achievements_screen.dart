import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'achievement_model.dart';
import 'achievement_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ACHIEVEMENTS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: achievementsAsync.when(
        loading: () => const Center(
          child:
              CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (achievements) {
          final unlocked =
              achievements.where((a) => a.isUnlocked).length;
          final total = achievements.length;

          return Column(
            children: [
              // Progress header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'YOUR POINTS',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(letterSpacing: 2),
                        ),
                        Text(
                          '$unlocked/$total',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: unlocked / total,
                        backgroundColor: AppColors.card,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              // Filter tabs
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _TabBtn(label: 'ALL', selected: true),
                    _TabBtn(label: 'UNLOCKED'),
                    _TabBtn(label: 'LOCKED'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Achievements list
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final ua = achievements[index];
                    return _AchievementCard(
                      userAchievement: ua,
                      onClaim: () {
                        ref
                            .read(achievementNotifierProvider
                                .notifier)
                            .claimAchievement(
                              ua.achievement.id,
                              ua.achievement.rewardCoins,
                            );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final UserAchievement userAchievement;
  final VoidCallback onClaim;

  const _AchievementCard({
    required this.userAchievement,
    required this.onClaim,
  });

  IconData get _icon {
    switch (userAchievement.achievement.icon) {
      case 'trophy':
        return Icons.emoji_events;
      case 'brain':
        return Icons.psychology;
      case 'star':
        return Icons.star;
      case 'room':
        return Icons.meeting_room;
      case 'invite':
        return Icons.person_add;
      case 'lucky':
        return Icons.casino;
      case 'confused':
        return Icons.help;
      case 'restart':
        return Icons.restart_alt;
      case 'speed':
        return Icons.bolt;
      case 'veteran':
        return Icons.military_tech;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = userAchievement.isUnlocked;
    final isClaimed = userAchievement.isClaimed;
    final achievement = userAchievement.achievement;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.surface
            : AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.textMuted.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.card,
            ),
            child: Icon(
              _icon,
              color: isUnlocked
                  ? AppColors.primary
                  : AppColors.textMuted,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        color: isUnlocked
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                ),
                Text(
                  achievement.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                ),
                if (!isUnlocked)
                  Text(
                    '${userAchievement.currentCount}/${achievement.requiredCount}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: AppColors.accent,
                          fontSize: 11,
                        ),
                  ),
              ],
            ),
          ),
          // Reward / Claim
          Column(
            children: [
              if (isUnlocked && !isClaimed)
                GestureDetector(
                  onTap: onClaim,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.success),
                    ),
                    child: const Text(
                      'CLAIM',
                      style: TextStyle(
                        color: AppColors.success,
                        fontFamily: 'Rajdhani',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else if (isClaimed)
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 28)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Color(0xFFF59E0B), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${achievement.rewardCoins}',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontFamily: 'Rajdhani',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;

  const _TabBtn({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? Colors.white
                    : AppColors.textMuted,
                fontSize: 12,
              ),
        ),
      ),
    );
  }
}