enum GameCategory {
  brainTrap,
  memory,
  reaction,
  visual,
  logic,
  focus,
}

enum Difficulty {
  easy,
  medium,
  hard,
  expert,
  insane,
}

extension GameCategoryExt on GameCategory {
  String get title {
    switch (this) {
      case GameCategory.brainTrap:
        return 'Brain Trap';
      case GameCategory.memory:
        return 'Memory Challenge';
      case GameCategory.reaction:
        return 'Reaction Challenge';
      case GameCategory.visual:
        return 'Visual Illusion';
      case GameCategory.logic:
        return 'Logic Challenge';
      case GameCategory.focus:
        return 'Focus Challenge';
    }
  }

  String get subtitle {
    switch (this) {
      case GameCategory.brainTrap:
        return 'Don\'t get fooled!';
      case GameCategory.memory:
        return 'Test your memory';
      case GameCategory.reaction:
        return 'How fast are you?';
      case GameCategory.visual:
        return 'Trust your eyes?';
      case GameCategory.logic:
        return 'Think smart';
      case GameCategory.focus:
        return 'Stay focused';
    }
  }

  String get emoji {
    switch (this) {
      case GameCategory.brainTrap:
        return 'trap';
      case GameCategory.memory:
        return 'memory';
      case GameCategory.reaction:
        return 'reaction';
      case GameCategory.visual:
        return 'visual';
      case GameCategory.logic:
        return 'logic';
      case GameCategory.focus:
        return 'focus';
    }
  }
}

extension DifficultyExt on Difficulty {
  String get title {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
      case Difficulty.insane:
        return 'Insane';
    }
  }

  int get timeLimit {
    switch (this) {
      case Difficulty.easy:
        return 30;
      case Difficulty.medium:
        return 20;
      case Difficulty.hard:
        return 15;
      case Difficulty.expert:
        return 10;
      case Difficulty.insane:
        return 5;
    }
  }

  int get pointsMultiplier {
    switch (this) {
      case Difficulty.easy:
        return 1;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 3;
      case Difficulty.expert:
        return 5;
      case Difficulty.insane:
        return 10;
    }
  }
}

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final GameCategory category;
  final Difficulty difficulty;

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
    required this.difficulty,
  });
}

class GameResult {
  final int score;
  final int correct;
  final int wrong;
  final int total;
  final Duration timeTaken;
  final Difficulty difficulty;
  final GameCategory category;

  const GameResult({
    required this.score,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.timeTaken,
    required this.difficulty,
    required this.category,
  });

  double get accuracy => total == 0 ? 0 : (correct / total) * 100;
}