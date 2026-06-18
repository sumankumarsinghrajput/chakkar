import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'game_models.dart';
import 'difficulty_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SELECT CATEGORY'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: GameCategory.values.length,
          itemBuilder: (context, index) {
            final category = GameCategory.values[index];
            return _CategoryCard(category: category);
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final GameCategory category;

  const _CategoryCard({required this.category});

  Color get _color {
    switch (category) {
      case GameCategory.brainTrap:
        return AppColors.primary;
      case GameCategory.memory:
        return AppColors.secondary;
      case GameCategory.reaction:
        return AppColors.accent;
      case GameCategory.visual:
        return const Color(0xFFEC4899);
      case GameCategory.logic:
        return AppColors.success;
      case GameCategory.focus:
        return const Color(0xFFF59E0B);
    }
  }

  IconData get _icon {
    switch (category) {
      case GameCategory.brainTrap:
        return Icons.psychology;
      case GameCategory.memory:
        return Icons.memory;
      case GameCategory.reaction:
        return Icons.bolt;
      case GameCategory.visual:
        return Icons.remove_red_eye;
      case GameCategory.logic:
        return Icons.account_tree;
      case GameCategory.focus:
        return Icons.center_focus_strong;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DifficultyScreen(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _color.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _color.withOpacity(0.2),
              ),
              child: Icon(_icon, color: _color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              category.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              category.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}