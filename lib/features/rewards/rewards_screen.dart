import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/services/audio_manager.dart';
import 'rewards_provider.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DAILY REWARDS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: streakAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (streak) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF78350F), Color(0xFFB45309)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.local_fire_department, color: Color(0xFFFCD34D), size: 40),
                      const SizedBox(height: 8),
                      Text(
                        '${streak.currentStreak + (streak.claimedToday ? 1 : 0)} Day Streak',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                      ),
                      Text(
                        streak.claimedToday ? 'Come back tomorrow!' : 'Claim today\'s reward!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFFFCD34D)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final dayNum = index + 1;
                    final isPast = index < (streak.currentStreak % 7) ||
                        (streak.claimedToday && index <= (streak.currentStreak % 7));
                    final isToday = !streak.claimedToday && index == (streak.currentStreak % 7);
                    final reward = streakRewards[index];

                    Color bg = AppColors.surface;
                    Color border = AppColors.primary.withOpacity(0.2);
                    if (isPast) {
                      bg = AppColors.success.withOpacity(0.15);
                      border = AppColors.success;
                    } else if (isToday) {
                      bg = AppColors.primary.withOpacity(0.2);
                      border = AppColors.primary;
                    }

                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border, width: isToday ? 2 : 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Day $dayNum',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
                          const SizedBox(height: 4),
                          Icon(
                            isPast ? Icons.check_circle : Icons.monetization_on,
                            color: isPast ? AppColors.success : const Color(0xFFF59E0B),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text('$reward',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
                        ],
                      ),
                    );
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: streak.claimedToday
                      ? null
                      : () async {
                          final reward = await ref.read(rewardsNotifierProvider.notifier).claimDailyReward();
                          if (reward > 0) {
                            audioManager.playWin();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('+$reward coins claimed!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          }
                        },
                  child: Text(streak.claimedToday ? 'ALREADY CLAIMED' : 'CLAIM REWARD'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}