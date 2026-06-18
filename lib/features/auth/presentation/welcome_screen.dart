import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../data/auth_provider.dart';
import '../../home/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../onboarding/gender_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) async {
        if (user != null) {
          // Check if profile exists
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (!context.mounted) return;
          if (doc.exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GenderScreen()),
            );
          }
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo Area
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'CHAKKAR',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'THE ULTIMATE BRAIN BATTLE',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(letterSpacing: 3),
              ),
              const Spacer(flex: 2),
              // Buttons
              if (authState.isLoading)
                const SizedBox(
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else ...[
                // Google Button
                _buildButton(
                  context: context,
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata,
                  color: AppColors.surface,
                  onTap: () => ref
                      .read(authNotifierProvider.notifier)
                      .signInWithGoogle(),
                ),
                const SizedBox(height: 12),
                // Email Button
                _buildButton(
                  context: context,
                  label: 'Continue with Email',
                  icon: Icons.email_outlined,
                  color: AppColors.surface,
                  onTap: () => _showEmailDialog(context, ref),
                ),
                const SizedBox(height: 12),
                // Guest Button
                _buildButton(
                  context: context,
                  label: 'Play as Guest',
                  icon: Icons.person_outline,
                  color: AppColors.card,
                  onTap: () =>
                      ref.read(authNotifierProvider.notifier).signInAsGuest(),
                ),
                if (authState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      authState.error.toString(),
                      style: const TextStyle(color: AppColors.danger),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
              const Spacer(),
              Text(
                'By continuing you agree to our Terms & Privacy Policy',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLogin = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            isLogin ? 'Sign In' : 'Sign Up',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin ? 'No account? Sign Up' : 'Have account? Sign In',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (isLogin) {
                  ref
                      .read(authNotifierProvider.notifier)
                      .signInWithEmail(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                } else {
                  ref
                      .read(authNotifierProvider.notifier)
                      .signUpWithEmail(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                }
              },
              child: Text(isLogin ? 'Sign In' : 'Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
