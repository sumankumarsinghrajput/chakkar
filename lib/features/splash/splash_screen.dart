import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/presentation/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'CHAKKAR',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 8,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'THE ULTIMATE BRAIN BATTLE',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            letterSpacing: 3,
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}