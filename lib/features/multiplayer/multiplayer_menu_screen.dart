import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';

class MultiplayerMenuScreen extends StatelessWidget {
  const MultiplayerMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MULTIPLAYER'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _MenuOption(
              title: 'CREATE ROOM',
              subtitle: 'Create your own room',
              icon: Icons.add_circle_outline,
              color: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CreateRoomScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _MenuOption(
              title: 'JOIN ROOM',
              subtitle: 'Join with Code',
              icon: Icons.login,
              color: AppColors.secondary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const JoinRoomScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _MenuOption(
              title: 'FRIENDS',
              subtitle: 'Invite & Play',
              icon: Icons.people,
              color: AppColors.accent,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _MenuOption(
              title: 'RECENT PLAYERS',
              subtitle: 'Play Again',
              icon: Icons.history,
              color: const Color(0xFFF59E0B),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _MenuOption(
              title: 'LEADERBOARD',
              subtitle: 'See Top Players',
              icon: Icons.emoji_events,
              color: AppColors.success,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.textPrimary),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: color, size: 16),
          ],
        ),
      ),
    );
  }
}