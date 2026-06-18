import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/avatar_widget.dart';
import 'leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final myRankAsync = ref.watch(myRankProvider);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _TabButton(label: 'GLOBAL', selected: true),
                _TabButton(label: 'FRIENDS', selected: false),
              ],
            ),
          ),
          // My rank card
          myRankAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (rank) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person,
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'YOUR RANK',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(letterSpacing: 2),
                  ),
                  const Spacer(),
                  Text(
                    '#$rank',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Leaderboard list
          Expanded(
            child: leaderboardAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary),
              ),
              error: (e, _) =>
                  Center(child: Text(e.toString())),
              data: (players) => ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  final rank = index + 1;
                  final isMe = player.uid == currentUid;

                  Color rankColor = AppColors.textSecondary;
                  if (rank == 1)
                    rankColor = const Color(0xFFFFD700);
                  if (rank == 2)
                    rankColor = const Color(0xFFC0C0C0);
                  if (rank == 3)
                    rankColor = const Color(0xFFCD7F32);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMe
                            ? AppColors.primary
                            : AppColors.card,
                        width: isMe ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Rank
                        SizedBox(
                          width: 36,
                          child: Text(
                            '#$rank',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: rankColor),
                          ),
                        ),
                        // Avatar
                        AvatarWidget(
                            avatarId: player.avatarId,
                            size: 40),
                        const SizedBox(width: 12),
                        // Name & level
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.displayUsername,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: isMe
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                              ),
                              Text(
                                'Level ${player.level}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        // Wins
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${player.wins}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: rankColor),
                            ),
                            Text(
                              'WINS',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;

  const _TabButton({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? Colors.white
                    : AppColors.textMuted,
              ),
        ),
      ),
    );
  }
}