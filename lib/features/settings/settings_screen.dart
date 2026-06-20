import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/services/audio_manager.dart';
import '../profile/profile_provider.dart';
import '../auth/presentation/welcome_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _soundEnabled = audioManager.soundEnabled;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('AUDIO'),
          _SettingsTile(
            icon: Icons.volume_up,
            title: 'Sound Effects',
            subtitle: 'Meme sounds, correct/wrong, win/lose',
            trailing: Switch(
              value: _soundEnabled,
              activeColor: AppColors.primary,
              onChanged: (v) {
                setState(() {
                  _soundEnabled = v;
                  audioManager.toggleSound();
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('ACCOUNT'),
          profileAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (profile) => Column(
              children: [
                _SettingsTile(
                  icon: Icons.person,
                  title: 'Username',
                  subtitle: profile?.displayUsername ?? '-',
                  trailing: const Icon(
                    Icons.edit,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  onTap: () => _showEditUsername(
                    context,
                    profile?.displayUsername ?? '',
                  ),
                ),
                _SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Email / Account',
                  subtitle: _getDisplayAccount(user),
                ),
                _SettingsTile(
                  icon: Icons.numbers,
                  title: 'User ID',
                  subtitle: user?.uid.substring(0, 12) ?? '-',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('ABOUT'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms & Privacy Policy',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
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

  void _showEditUsername(BuildContext context, String current) {
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
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(letterSpacing: 2),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
