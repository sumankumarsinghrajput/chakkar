import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'game_models.dart';
import 'game_provider.dart';
import 'result_screen.dart';
import '../../shared/services/audio_manager.dart';
import '../store/store_provider.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final List<Question> questions;
  final Difficulty difficulty;
  final GameCategory category;

  const GameplayScreen({
    super.key,
    required this.questions,
    required this.difficulty,
    required this.category,
  });

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  late final Map<String, dynamic> _params;
  int _lastTimeLeft = 999;

  @override
  void initState() {
    super.initState();
    _params = {'questions': widget.questions, 'difficulty': widget.difficulty};
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider(_params));
    final notifier = ref.read(gameProvider(_params).notifier);

    if (gameState.timeLeft == 5 && _lastTimeLeft != 5 && !gameState.answered) {
      _lastTimeLeft = 5;
      audioManager.playCountdown();
    } else if (gameState.timeLeft != 5) {
      _lastTimeLeft = gameState.timeLeft;
    }

    if (gameState.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(result: notifier.getResult()),
          ),
        );
      });
    }

    final question = gameState.currentQuestion;
    if (question == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value:
                            (gameState.currentIndex + 1) /
                            gameState.questions.length,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${gameState.currentIndex + 1}/${gameState.questions.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 95,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: gameState.timeLeft <= 5
                          ? AppColors.danger.withOpacity(0.3)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: gameState.timeLeft <= 5
                            ? AppColors.danger
                            : AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer,
                          color: gameState.timeLeft <= 5
                              ? AppColors.danger
                              : AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${gameState.timeLeft}s',
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: gameState.timeLeft <= 5
                                      ? AppColors.danger
                                      : AppColors.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF59E0B),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${gameState.score}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _BoosterBar(notifier: notifier),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Text(
                  question.question,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    return _OptionButton(
                      label: question.options[index],
                      index: index,
                      gameState: gameState,
                      correctIndex: question.correctIndex,
                      onTap: () => notifier.answerQuestion(index),
                    );
                  },
                ),
              ),
              if (gameState.answered)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question.explanation,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.accent),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final int index;
  final GameState gameState;
  final int correctIndex;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.index,
    required this.gameState,
    required this.correctIndex,
    required this.onTap,
  });

  Color _getColor() {
    if (!gameState.answered) return AppColors.surface;
    if (index == correctIndex) return AppColors.success.withOpacity(0.3);
    if (index == gameState.selectedIndex)
      return AppColors.danger.withOpacity(0.3);
    return AppColors.surface;
  }

  Color _getBorderColor() {
    if (!gameState.answered) return AppColors.primary.withOpacity(0.2);
    if (index == correctIndex) return AppColors.success;
    if (index == gameState.selectedIndex) return AppColors.danger;
    return AppColors.surface;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameState.answered ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getBorderColor(), width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _BoosterBar extends ConsumerWidget {
  final GameNotifier notifier;
  const _BoosterBar({required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(ownedItemsProvider);

    return inventoryAsync.when(
      loading: () => const SizedBox(height: 40),
      error: (_, __) => const SizedBox(height: 40),
      data: (inventory) {
        final List<(String, IconData, String)> boosters = [
          ('extra_time_5', Icons.timer, '+5s'),
          ('double_points', Icons.looks_two, '2x'),
          ('streak_shield', Icons.shield, 'Shield'),
          ('skip_question', Icons.skip_next, 'Skip'),
        ];
        final available = boosters
            .where((b) => (inventory[b.$1] ?? 0) > 0)
            .toList();

        if (available.isEmpty) return const SizedBox(height: 4);

        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: available.map((b) {
              final qty = inventory[b.$1] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () async {
                    await ref
                        .read(storeNotifierProvider.notifier)
                        .useBooster(b.$1);
                    notifier.applyBooster(b.$1);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${b.$3} booster used!'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(b.$2, color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          b.$3,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontFamily: 'Rajdhani',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$qty',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontFamily: 'Rajdhani',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
