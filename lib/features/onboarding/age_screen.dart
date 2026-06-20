import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'onboarding_provider.dart';
import 'gender_screen.dart';

class AgeScreen extends ConsumerStatefulWidget {
  const AgeScreen({super.key});

  @override
  ConsumerState<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends ConsumerState<AgeScreen> {
  int _selectedAge = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'HOW OLD',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      letterSpacing: 4,
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                'ARE YOU?',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 4,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us personalize your game experience',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Age display
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$_selectedAge',
                    style: const TextStyle(
                      fontSize: 56,
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.surface,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withOpacity(0.2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _selectedAge.toDouble(),
                  min: 5,
                  max: 80,
                  onChanged: (value) {
                    setState(() => _selectedAge = value.round());
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('5', style: Theme.of(context).textTheme.bodyMedium),
                  Text('80', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ref.read(onboardingProvider.notifier).setAge(_selectedAge);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GenderScreen()),
                  );
                },
                child: const Text('CONTINUE'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}