import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'onboarding_provider.dart';
import 'username_screen.dart';

class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});

  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen> {
  String selectedAvatar = 'avatar_1';

  // Avatar data — expandable to hundreds later
  List<Map<String, dynamic>> get avatars {
    final gender = ref.read(onboardingProvider).gender;
    if (gender == 'female') {
      return List.generate(
        12,
        (i) => {
          'id': 'female_${i + 1}',
          'color': _avatarColors[i % _avatarColors.length],
          'icon': _femaleIcons[i % _femaleIcons.length],
        },
      );
    }
    return List.generate(
      12,
      (i) => {
        'id': 'male_${i + 1}',
        'color': _avatarColors[i % _avatarColors.length],
        'icon': _maleIcons[i % _maleIcons.length],
      },
    );
  }

  final List<Color> _avatarColors = [
    const Color(0xFF6366F1),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF3B82F6),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF06B6D4),
  ];

  final List<IconData> _maleIcons = [
    Icons.face,
    Icons.sports_esports,
    Icons.psychology,
    Icons.bolt,
    Icons.star,
    Icons.shield,
  ];

  final List<IconData> _femaleIcons = [
    Icons.face_3,
    Icons.auto_awesome,
    Icons.psychology,
    Icons.bolt,
    Icons.star,
    Icons.favorite,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header
            Text(
              'CHOOSE YOUR',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    letterSpacing: 4,
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              'AVATAR',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 4,
                  ),
            ),
            const SizedBox(height: 24),
            // Selected Avatar Preview
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getSelectedColor(),
                boxShadow: [
                  BoxShadow(
                    color: _getSelectedColor().withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _getSelectedIcon(),
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // Avatar Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = avatars[index];
                    final isSelected = selectedAvatar == avatar['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = avatar['id'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (avatar['color'] as Color)
                              .withOpacity(0.2),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (avatar['color'] as Color)
                                    .withOpacity(0.4),
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          avatar['icon'] as IconData,
                          color: avatar['color'] as Color,
                          size: 36,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(onboardingProvider.notifier)
                      .setAvatar(selectedAvatar);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UsernameScreen(),
                    ),
                  );
                },
                child: const Text('CONTINUE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSelectedColor() {
    final avatar = avatars.firstWhere(
      (a) => a['id'] == selectedAvatar,
      orElse: () => avatars.first,
    );
    return avatar['color'] as Color;
  }

  IconData _getSelectedIcon() {
    final avatar = avatars.firstWhere(
      (a) => a['id'] == selectedAvatar,
      orElse: () => avatars.first,
    );
    return avatar['icon'] as IconData;
  }
}