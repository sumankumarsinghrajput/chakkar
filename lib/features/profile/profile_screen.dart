import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/avatar_widget.dart';
import '../auth/presentation/welcome_screen.dart';
import 'profile_provider.dart';
import '../match_history/match_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PROFILE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No profile found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar & Name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      AvatarWidget(
                        avatarId: user.avatarId,
                        size: 80,
                        showBorder: true,
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _showEditUsername(
                          context,
                          ref,
                          user.displayUsername,
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.displayUsername,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${user.level}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // XP Bar
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${user.xp} XP',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '${user.xpForNextLevel} XP',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: user.xpProgress.clamp(0.0, 1.0),
                              backgroundColor: AppColors.card,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Stats Row
                Row(
                  children: [
                    _StatCard(
                      label: 'GAMES',
                      value: '${user.wins + user.losses}',
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'WINS',
                      value: '${user.wins}',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'WIN RATE',
                      value: '${user.winRate.toStringAsFixed(0)}%',
                      color: AppColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Coins & Rank
                Row(
                  children: [
                    _StatCard(
                      label: 'COINS',
                      value: '${user.coins}',
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'LOSSES',
                      value: '${user.losses}',
                      color: AppColors.danger,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Account Info
                _ProfileMenuItem(
                  icon: Icons.email_outlined,
                  label: 'ACCOUNT',
                  subtitle: _getDisplayAccount(
                    FirebaseAuth.instance.currentUser,
                  ),
                  onTap: () {},
                  showArrow: false,
                ),
                const SizedBox(height: 8),
                _ProfileMenuItem(
                  icon: Icons.numbers,
                  label: 'USER ID',
                  subtitle:
                      FirebaseAuth.instance.currentUser?.uid.substring(0, 12) ??
                      '-',
                  onTap: () {},
                  showArrow: false,
                ),
                const SizedBox(height: 8),
                _ProfileMenuItem(
                  icon: Icons.face,
                  label: 'AVATARS',
                  subtitle: 'Collect & Change',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _ProfileMenuItem(
                  icon: Icons.bar_chart,
                  label: 'STATS',
                  subtitle: 'Detailed Statistics',
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                // Sign Out
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(profileNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SIGN OUT',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

void _showEditUsername(BuildContext context, WidgetRef ref, String current) {
  final controller = TextEditingController(text: current);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Edit Username',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'New username',
          hintStyle: TextStyle(color: AppColors.textMuted),
        ),
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
            final newName = controller.text.trim();
            if (newName.isEmpty) return;
            Navigator.pop(context);
            try {
              await ref
                  .read(profileNotifierProvider.notifier)
                  .updateUsername(newName);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Username updated!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

String _getDisplayAccount(User? user) {
  if (user == null) return 'Not signed in';
  final googleProvider = user.providerData
      .where((p) => p.providerId == 'google.com')
      .firstOrNull;
  if (googleProvider != null) return googleProvider.email ?? 'Google Account';

  final emailProvider = user.providerData
      .where(
        (p) =>
            p.providerId == 'password' &&
            !(p.email ?? '').endsWith('@chakkar.app'),
      )
      .firstOrNull;
  if (emailProvider != null) return emailProvider.email ?? 'Email Account';

  return 'Guest Account';
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
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
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool showArrow;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleLarge),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textMuted,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
