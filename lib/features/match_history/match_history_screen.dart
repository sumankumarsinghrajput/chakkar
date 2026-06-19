import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import 'match_model.dart';
import 'match_provider.dart';

class MatchHistoryScreen extends ConsumerWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(matchHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MATCH HISTORY'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (matches) {
          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, color: AppColors.textMuted, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No matches yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Play a game to see history here',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return _MatchCard(match: match);
            },
          );
        },
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchRecord match;
  const _MatchCard({required this.match});

  String _formatCategory(String category) {
    switch (category) {
      case 'GameCategory.brainTrap':
        return 'Brain Trap';
      case 'GameCategory.memory':
        return 'Memory';
      case 'GameCategory.logic':
        return 'Logic';
      case 'GameCategory.visual':
        return 'Visual Illusion';
      default:
        return category;
    }
  }

  String _formatDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Difficulty.easy':
        return 'Easy';
      case 'Difficulty.medium':
        return 'Medium';
      case 'Difficulty.hard':
        return 'Hard';
      case 'Difficulty.expert':
        return 'Expert';
      case 'Difficulty.insane':
        return 'Insane';
      default:
        return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMultiplayer = match.mode == MatchMode.multiplayer;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: match.isWin
              ? AppColors.success.withOpacity(0.3)
              : AppColors.danger.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Result icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: match.isWin
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.danger.withOpacity(0.2),
            ),
            child: Icon(
              match.isWin ? Icons.emoji_events : Icons.close,
              color: match.isWin ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isMultiplayer ? Icons.groups : Icons.person,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatCategory(match.category),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Text(
                  '${_formatDifficulty(match.difficulty)} • ${DateFormat('MMM d, h:mm a').format(match.playedAt)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (isMultiplayer && match.rank != null)
                  Text(
                    'Rank #${match.rank}/${match.totalPlayers}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.accent,
                        ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${match.score}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: match.isWin ? AppColors.success : AppColors.primary,
                    ),
              ),
              Text(
                '${match.accuracy.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}