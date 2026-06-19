import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'game_models.dart';
import 'game_provider.dart';
import 'gameplay_screen.dart';

class DifficultyScreen extends StatelessWidget {
  final GameCategory category;

  const DifficultyScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(category.title.toUpperCase()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SELECT DIFFICULTY',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                letterSpacing: 3,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How brave are you?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: Difficulty.values.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final difficulty = Difficulty.values[index];
                  return _DifficultyCard(
                    difficulty: difficulty,
                    category: category,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final GameCategory category;

  const _DifficultyCard({required this.difficulty, required this.category});

  Color get _color {
    switch (difficulty) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.medium:
        return const Color(0xFF3B82F6);
      case Difficulty.hard:
        return AppColors.primary;
      case Difficulty.expert:
        return AppColors.secondary;
      case Difficulty.insane:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = getQuestions(category, difficulty);

    return GestureDetector(
      onTap: () {
        if (questions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No questions available for this difficulty yet!'),
              backgroundColor: AppColors.surface,
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameplayScreen(
              questions: questions,
              difficulty: difficulty,
              category: category,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _color.withOpacity(0.2),
              ),
              child: Icon(Icons.bolt, color: _color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.title.toUpperCase(),
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: _color),
                  ),
                  Text(
                    '${difficulty.timeLimit}s per question  •  ${difficulty.pointsMultiplier}x points',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: _color, size: 16),
          ],
        ),
      ),
    );
  }
}