import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('FRIENDS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, color: AppColors.textMuted, size: 64),
            SizedBox(height: 16),
            Text(
              'Friends System',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: AppColors.textMuted,
                fontFamily: 'Rajdhani',
              ),
            ),
          ],
        ),
      ),
    );
  }
}