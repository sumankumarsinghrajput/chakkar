import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/avatar_widget.dart';
import 'home_provider.dart';
import '../game/category_screen.dart';
import '../multiplayer/multiplayer_menu_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../achievements/achievements_screen.dart';
import '../profile/profile_screen.dart';
import '../friends/friends_screen.dart';
import '../match_history/match_history_screen.dart';
import '../store/store_screen.dart';
import '../daily_challenge/daily_screen.dart';
import '../daily_challenge/daily_provider.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (user) => Column(
            children: [
              _TopBar(user: user),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _DailyChallenge(),
                      const SizedBox(height: 12),
                      _MenuCard(
                        title: 'SINGLE PLAYER',
                        subtitle: 'Play vs AI',
                        icon: Icons.person,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CategoryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _MenuCard(
                        title: 'MULTIPLAYER',
                        subtitle: 'Play with Real Players',
                        icon: Icons.groups,
                        gradient: AppColors.primaryGradient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MultiplayerMenuScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _MenuCard(
                        title: 'ACHIEVEMENTS',
                        subtitle: 'Unlock Rewards',
                        icon: Icons.emoji_events,
                        gradient: AppColors.purpleGradient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AchievementsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _MenuCard(
                        title: 'STORE',
                        subtitle: 'Coins, Boosters & More',
                        icon: Icons.storefront,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF065F46), Color(0xFF10B981)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StoreScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(context: context),
    );
  }
}

class _TopBar extends StatelessWidget {
  final dynamic user;
  const _TopBar({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          // Avatar
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: AvatarWidget(
              avatarId: user?.avatarId ?? 'male_1',
              size: 44,
              showBorder: true,
            ),
          ),
          const SizedBox(width: 10),
          // Username & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayUsername ?? 'Player',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Level ${user?.level ?? 1}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          // Coins
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Color(0xFFF59E0B),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user?.coins ?? 0}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Color(0xFFF59E0B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Friends
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendsScreen()),
              );
            },
            icon: const Icon(
              Icons.people_outline,
              color: AppColors.textSecondary,
            ),
          ),
          // Settings
          // Settings
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
    );
  }
}

class _DailyChallenge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(dailyCompletedProvider);

    return completedAsync.when(
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
      data: (isCompleted) {
        return GestureDetector(
          onTap: isCompleted
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DailyChallengeScreen(),
                    ),
                  );
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCompleted
                    ? [const Color(0xFF1F2937), const Color(0xFF374151)]
                    : [const Color(0xFF78350F), const Color(0xFFB45309)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    (isCompleted
                            ? AppColors.textMuted
                            : const Color(0xFFF59E0B))
                        .withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.local_fire_department,
                  color: isCompleted
                      ? AppColors.success
                      : const Color(0xFFF59E0B),
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY CHALLENGE',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      Text(
                        isCompleted
                            ? 'Come back tomorrow!'
                            : 'Complete & Earn Big!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isCompleted
                              ? AppColors.textMuted
                              : const Color(0xFFFCD34D),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PLAY',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _NavItem(icon: Icons.home, label: 'Home', active: true),
          _NavItem(icon: Icons.card_giftcard, label: 'Rewards', onTap: () {}),
          _NavItem(
            icon: Icons.history,
            label: 'History',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MatchHistoryScreen()),
            ),
          ),
          _NavItem(
            icon: Icons.leaderboard,
            label: 'Ranks',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            ),
          ),
          _NavItem(
            icon: Icons.storefront,
            label: 'Shop',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StoreScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? AppColors.primary : AppColors.textMuted,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Rajdhani',
              color: active ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
