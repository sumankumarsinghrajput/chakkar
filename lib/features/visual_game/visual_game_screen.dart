import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/services/audio_manager.dart';
import 'visual_models.dart';
import 'visual_provider.dart';
import '../home/home_screen.dart';

class VisualGameScreen extends ConsumerStatefulWidget {
  const VisualGameScreen({super.key});

  @override
  ConsumerState<VisualGameScreen> createState() => _VisualGameScreenState();
}

class _VisualGameScreenState extends ConsumerState<VisualGameScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(visualGameProvider);
    final notifier = ref.read(visualGameProvider.notifier);

    if (gameState.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = notifier.getResult();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => _VisualResultScreen(result: result),
          ),
        );
      });
    }

    final round = gameState.currentRound;
    if (round == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
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
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    ),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (gameState.currentIndex + 1) / gameState.rounds.length,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${gameState.currentIndex + 1}/${gameState.rounds.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                    child: Text(
                      '${gameState.timeLeft}s',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: gameState.timeLeft <= 5
                                ? AppColors.danger
                                : AppColors.primary,
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
                        Text('${gameState.score}', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                round.instruction,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(child: _RoundContent(round: round, gameState: gameState, onAnswer: notifier.answer)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundContent extends StatelessWidget {
  final VisualRound round;
  final VisualGameState gameState;
  final Function(int) onAnswer;

  const _RoundContent({required this.round, required this.gameState, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    switch (round.type) {
      case VisualGameType.oddOneOut:
        return _buildGrid(context, round.displayShapes);
      case VisualGameType.patternMatch:
        return _buildGrid(context, round.displayShapes);
      case VisualGameType.spotDifference:
        return _buildCompareGrids(context);
      case VisualGameType.illusionQuiz:
        return _buildIllusionQuiz(context);
    }
  }

  Widget _buildGrid(BuildContext context, List<ShapeData> shapes) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: shapes.length,
      itemBuilder: (context, index) {
        final isCorrect = index == round.correctIndex;
        final isSelected = index == gameState.selectedIndex;
        Color borderColor = AppColors.primary.withOpacity(0.2);
        if (gameState.answered) {
          if (isCorrect) borderColor = AppColors.success;
          else if (isSelected) borderColor = AppColors.danger;
        }
        return GestureDetector(
          onTap: gameState.answered ? null : () => onAnswer(index),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Icon(shapes[index].icon, color: shapes[index].color, size: 36),
          ),
        );
      },
    );
  }

  Widget _buildCompareGrids(BuildContext context) {
    return Column(
      children: [
        Text('GRID A', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        SizedBox(height: 100, child: _buildSimpleRow(round.displayShapes, null)),
        const SizedBox(height: 16),
        Text('GRID B - Farak dhoondo', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        SizedBox(height: 100, child: _buildSimpleRow(round.compareShapes!, onAnswer)),
      ],
    );
  }

  Widget _buildSimpleRow(List<ShapeData> shapes, Function(int)? onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(shapes.length, (index) {
        final isCorrect = index == round.correctIndex;
        final isSelected = index == gameState.selectedIndex;
        Color borderColor = AppColors.primary.withOpacity(0.2);
        if (gameState.answered && onTap != null) {
          if (isCorrect) borderColor = AppColors.success;
          else if (isSelected) borderColor = AppColors.danger;
        }
        return GestureDetector(
          onTap: (gameState.answered || onTap == null) ? null : () => onTap(index),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Icon(shapes[index].icon, color: shapes[index].color, size: 24),
          ),
        );
      }),
    );
  }

  Widget _buildIllusionQuiz(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: round.displayShapes
              .map((s) => Icon(s.icon, color: s.color, size: 28))
              .toList(),
        ),
        const SizedBox(height: 24),
        if (round.textOptions != null)
          ...List.generate(round.textOptions!.length, (index) {
            final isCorrect = index == round.correctIndex;
            final isSelected = index == gameState.selectedIndex;
            Color bgColor = AppColors.surface;
            Color borderColor = AppColors.primary.withOpacity(0.2);
            if (gameState.answered) {
              if (isCorrect) { bgColor = AppColors.success.withOpacity(0.3); borderColor = AppColors.success; }
              else if (isSelected) { bgColor = AppColors.danger.withOpacity(0.3); borderColor = AppColors.danger; }
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: GestureDetector(
                onTap: gameState.answered ? null : () => onAnswer(index),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Text(
                    round.textOptions![index],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _VisualResultScreen extends StatelessWidget {
  final VisualResult result;
  const _VisualResultScreen({required this.result});

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
              Text(
                result.accuracy >= 60 ? 'SHARP AANKHEIN!' : 'AANKHEIN CHECKUP KARAO!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: result.accuracy >= 60 ? AppColors.success : AppColors.danger,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text('${result.score}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary)),
                    Text('TOTAL SCORE', style: Theme.of(context).textTheme.bodyMedium?.copyWith(letterSpacing: 3)),
                    const SizedBox(height: 16),
                    Text('${result.correct}/${result.total} Correct',
                        style: Theme.of(context).textTheme.titleLarge),
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