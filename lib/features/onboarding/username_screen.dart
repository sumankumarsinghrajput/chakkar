import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'onboarding_provider.dart';
import '../home/home_screen.dart';

class UsernameScreen extends ConsumerStatefulWidget {
  const UsernameScreen({super.key});

  @override
  ConsumerState<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends ConsumerState<UsernameScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _checking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,16}$');
    return regex.hasMatch(username);
  }

  Future<void> _submit() async {
    final username = _controller.text.trim();

    if (!_isValidUsername(username)) {
      setState(() {
        _error =
            '3-16 characters. Letters, numbers, underscores only.';
      });
      return;
    }

    setState(() {
      _checking = true;
      _error = null;
    });

    final success =
        await ref.read(onboardingProvider.notifier).saveProfile(username);

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _checking = false;
        _error = ref.read(onboardingProvider).error ?? 'Something went wrong';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'CREATE YOUR',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      letterSpacing: 4,
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                'USERNAME',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 4,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This is how other players will know you',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Username Input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _error != null
                        ? AppColors.danger
                        : AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                  maxLength: 16,
                  decoration: InputDecoration(
                    hintText: 'EnterUsername',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 22,
                      fontFamily: 'Rajdhani',
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (_) {
                    if (_error != null) {
                      setState(() => _error = null);
                    }
                  },
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                '3-16 characters. Letters, numbers, underscores only.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Submit Button
              state.isLoading || _checking
                  ? const CircularProgressIndicator(
                      color: AppColors.primary,
                    )
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('LETS GO'),
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}