import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../visual_game/visual_models.dart';
import 'daily_provider.dart';
import '../home/home_screen.dart';

class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyChallengeProvider);
    final notifier = ref.read(dailyChallengeProvider.notifier);

    if (state.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => _DailyResultScreen(
              score: state.score,
              correct: state.correct,
              total: state.totalSteps,
              coinReward: notifier.coinReward,
            ),
          ),
        );
      });
    }

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
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (state.currentIndex + 1) / state.totalSteps,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${state.currentIndex + 1}/${state.totalSteps}',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: state.timeLeft <= 5
                          ? AppColors.danger.withOpacity(0.3)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: state.timeLeft <= 5
                            ? AppColors.danger
                            : const Color(0xFFF59E0B).withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      '${state.timeLeft}s',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: state.timeLeft <= 5 ? AppColors.danger : const Color(0xFFF59E0B),
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18),
                        const SizedBox(width: 4),
                        Text('${state.score}', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: state.isVisualStep
                    ? _VisualStep(round: state.currentVisual!, state: state, onAnswer: notifier.answer)
                    : _QuestionStep(question: state.currentQuestion!, state: state, onAnswer: notifier.answer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionStep extends StatelessWidget {
  final dynamic question;
  final DailyChallengeState state;
  final Function(int) onAnswer;

  const _QuestionStep({required this.question, required this.state, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
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
              Color bg = AppColors.surface;
              Color border = const Color(0xFFF59E0B).withOpacity(0.2);
              if (state.answered) {
                if (index == question.correctIndex) {
                  bg = AppColors.success.withOpacity(0.3);
                  border = AppColors.success;
                } else if (index == state.selectedIndex) {
                  bg = AppColors.danger.withOpacity(0.3);
                  border = AppColors.danger;
                }
              }
              return GestureDetector(
                onTap: state.answered ? null : () => onAnswer(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      question.options[index],
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VisualStep extends StatelessWidget {
  final VisualRound round;
  final DailyChallengeState state;
  final Function(int) onAnswer;

  const _VisualStep({required this.round, required this.state, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(round.instruction, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Expanded(
          child: round.textOptions != null
              ? Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: round.displayShapes.map((s) => Icon(s.icon, color: s.color, size: 28)).toList(),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(round.textOptions!.length, (index) {
                      Color bg = AppColors.surface;
                      Color border = const Color(0xFFF59E0B).withOpacity(0.2);
                      if (state.answered) {
                        if (index == round.correctIndex) {
                          bg = AppColors.success.withOpacity(0.3);
                          border = AppColors.success;
                        } else if (index == state.selectedIndex) {
                          bg = AppColors.danger.withOpacity(0.3);
                          border = AppColors.danger;
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: GestureDetector(
                          onTap: state.answered ? null : () => onAnswer(index),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border, width: 2),
                            ),
                            child: Text(round.textOptions![index],
                                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                          ),
                        ),
                      );
                    }),
                  ],
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: round.displayShapes.length,
                  itemBuilder: (context, index) {
                    Color border = const Color(0xFFF59E0B).withOpacity(0.2);
                    if (state.answered) {
                      if (index == round.correctIndex) border = AppColors.success;
                      else if (index == state.selectedIndex) border = AppColors.danger;
                    }
                    return GestureDetector(
                      onTap: state.answered ? null : () => onAnswer(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border, width: 2),
                        ),
                        child: Icon(round.displayShapes[index].icon, color: round.displayShapes[index].color, size: 36),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _DailyResultScreen extends StatelessWidget {
  final int score;
  final int correct;
  final int total;
  final int coinReward;

  const _DailyResultScreen({
    required this.score,
    required this.correct,
    required this.total,
    required this.coinReward,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.local_fire_department, color: Color(0xFFF59E0B), size: 64),
              const SizedBox(height: 16),
              Text(
                'CHALLENGE COMPLETE!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: const Color(0xFFF59E0B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text('$score',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary)),
                    Text('TOTAL SCORE', style: Theme.of(context).textTheme.bodyMedium?.copyWith(letterSpacing: 3)),
                    const SizedBox(height: 16),
                    Text('$correct/$total Correct', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 6),
                          Text('+$coinReward Coins',
                              style: const TextStyle(
                                  color: Color(0xFFF59E0B), fontFamily: 'Rajdhani', fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                ),
                child: const Text('HOME'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}