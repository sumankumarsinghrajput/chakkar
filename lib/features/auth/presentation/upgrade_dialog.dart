import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../data/upgrade_provider.dart';

class UpgradeDialog extends ConsumerWidget {
  final String reason;

  const UpgradeDialog({super.key, required this.reason});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upgradeState = ref.watch(upgradeNotifierProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              'SIGN IN REQUIRED',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              reason,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your progress, coins, and stats will carry over!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.success),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (upgradeState.isLoading)
              const CircularProgressIndicator(color: AppColors.primary)
            else ...[
              ElevatedButton.icon(
                onPressed: () async {
                  final success = await ref
                      .read(upgradeNotifierProvider.notifier)
                      .upgradeWithGoogle();
                  if (context.mounted) {
                    if (success) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sign in failed. Try again.'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _showEmailUpgrade(context, ref),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue with Email',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEmailUpgrade(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Sign In with Email',
          style: TextStyle(color: AppColors.textPrimary),
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
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(upgradeNotifierProvider.notifier)
                  .upgradeWithEmail(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
              if (context.mounted) {
                Navigator.pop(context, success);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sign in failed. Try again.'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
