import 'package:flutter/material.dart';

enum VisualGameType { patternMatch, oddOneOut, spotDifference, illusionQuiz }

class ShapeData {
  final IconData icon;
  final Color color;

  const ShapeData({required this.icon, required this.color});
}

const List<IconData> visualIcons = [
  Icons.circle,
  Icons.square,
  Icons.change_history,
  Icons.star,
  Icons.favorite,
  Icons.hexagon,
  Icons.diamond,
  Icons.pentagon,
];

const List<Color> visualColors = [
  Color(0xFFFF6B00),
  Color(0xFF8B5CF6),
  Color(0xFF00E5FF),
  Color(0xFF00FF88),
  Color(0xFFFF3B3B),
  Color(0xFFFFD600),
  Color(0xFFEC4899),
  Color(0xFF3B82F6),
];

class VisualRound {
  final VisualGameType type;
  final String instruction;
  final List<ShapeData> displayShapes;
  final List<ShapeData>? compareShapes;
  final int correctIndex;
  final List<String>? textOptions;

  const VisualRound({
    required this.type,
    required this.instruction,
    required this.displayShapes,
    this.compareShapes,
    required this.correctIndex,
    this.textOptions,
  });
}

class VisualResult {
  final int score;
  final int correct;
  final int wrong;
  final int total;
  final Duration timeTaken;

  const VisualResult({
    required this.score,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.timeTaken,
  });

  double get accuracy => total == 0 ? 0 : (correct / total) * 100;
}