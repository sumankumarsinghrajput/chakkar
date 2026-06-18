import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String avatarId;
  final double size;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    required this.avatarId,
    this.size = 40,
    this.showBorder = false,
  });

  Color _getColor() {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
    ];
    final index = avatarId.hashCode % colors.length;
    return colors[index.abs()];
  }

  IconData _getIcon() {
    if (avatarId.startsWith('female')) {
      return Icons.face_3;
    }
    return Icons.face;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(
          color: showBorder ? AppColors.primary : color.withOpacity(0.5),
          width: showBorder ? 2 : 1,
        ),
      ),
      child: Icon(
        _getIcon(),
        color: color,
        size: size * 0.5,
      ),
    );
  }
}