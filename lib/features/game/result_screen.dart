import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/services/audio_manager.dart';
import 'game_models.dart';
import '../home/home_screen.dart';
import 'category_screen.dart';

class ResultScreen extends StatefulWidget {
  final GameResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  GameResult get result => widget.result;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (result.accuracy >= 60) {
        audioManager.playWin();
      } else {
        audioManager.playLose();
      }
    });
  }

  final List<String> _loseMessages = [
    'Mera kutta bhi\nbehtar khelta hai!',
    'Dimaag ghar pe\nbhool aaye kya?',
    'Brain.exe stopped\nworking!',
    'Bhagwan bhi naraz\nhonge aaj!',
    'Maa-baap rone\nlage honge!',
    'Tu khel raha tha\nya so raha tha?',
  ];

  String get _title {
    if (result.accuracy >= 80) return 'BRAIN MASTER!';
    if (result.accuracy >= 60) return 'WELL DONE!';
    if (result.accuracy >= 40) return 'KEEP TRYING!';
    final random = result.score % _loseMessages.length;
    return _loseMessages[random];
  }

  Color get _titleColor {
    if (result.accuracy >= 80) return AppColors.success;
    if (result.accuracy >= 60) return AppColors.primary;
    if (result.accuracy >= 40) return const Color(0xFFF59E0B);
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                _title,
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(color: _titleColor),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              // Score Card
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
                    Text(
                      '${result.score}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'TOTAL SCORE',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(letterSpacing: 3),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'CORRECT',
                          value: '${result.correct}',
                          color: AppColors.success,
                        ),
                        _StatItem(
                          label: 'WRONG',
                          value: '${result.wrong}',
                          color: AppColors.danger,
                        ),
                        _StatItem(
                          label: 'ACCURACY',
                          value: '${result.accuracy.toStringAsFixed(0)}%',
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'CATEGORY',
                      value: result.category.title,
                      color: AppColors.secondary,
                    ),
                    _StatItem(
                      label: 'DIFFICULTY',
                      value: result.difficulty.title,
                      color: AppColors.primary,
                    ),
                    _StatItem(
                      label: 'TIME',
                      value: '${result.timeTaken.inSeconds}s',
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoryScreen()),
                  );
                },
                child: const Text('PLAY AGAIN'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'HOME',
                  style: TextStyle(color: AppColors.primary),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: color),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: 11, letterSpacing: 1),
        ),
      ],
    );
  }
}
