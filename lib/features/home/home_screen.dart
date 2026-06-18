import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'HOME SCREEN\nComing Soon',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}