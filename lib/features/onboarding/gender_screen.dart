import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'onboarding_provider.dart';
import 'avatar_screen.dart';

class GenderScreen extends ConsumerWidget {
  const GenderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header
              Text(
                'CHOOSE YOUR',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      letterSpacing: 4,
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                'GENDER',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 4,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us personalize your avatar collection',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Gender Cards
              Row(
                children: [
                  Expanded(
                    child: _GenderCard(
                      label: 'BOY',
                      icon: Icons.male,
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        ref
                            .read(onboardingProvider.notifier)
                            .setGender('male');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AvatarScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GenderCard(
                      label: 'GIRL',
                      icon: Icons.female,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        ref
                            .read(onboardingProvider.notifier)
                            .setGender('female');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AvatarScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Custom option
              GestureDetector(
                onTap: () {
                  ref
                      .read(onboardingProvider.notifier)
                      .setGender('custom');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AvatarScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CUSTOM',
                        style:
                            Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}