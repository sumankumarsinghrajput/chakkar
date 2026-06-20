import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'visual_models.dart';
import '../../shared/services/audio_manager.dart';

final _random = Random();

ShapeData _randomShape({List<int>? excludeIconIndices}) {
  int iconIdx;
  do {
    iconIdx = _random.nextInt(visualIcons.length);
  } while (excludeIconIndices != null && excludeIconIndices.contains(iconIdx));
  final colorIdx = _random.nextInt(visualColors.length);
  return ShapeData(icon: visualIcons[iconIdx], color: visualColors[colorIdx]);
}

VisualRound _generatePatternMatch() {
  final count = 4 + _random.nextInt(2); // 4-5 shapes
  final pattern = List.generate(count, (_) => _randomShape());
  // Shuffle a copy to create the answer grid, pick correct index = position matching first item
  final correctIdx = _random.nextInt(count);
  return VisualRound(
    type: VisualGameType.patternMatch,
    instruction: 'Yaad rakho pattern, fir sahi position batao',
    displayShapes: pattern,
    correctIndex: correctIdx,
  );
}

VisualRound _generateOddOneOut() {
  final baseIcon = visualIcons[_random.nextInt(visualIcons.length)];
  final baseColor = visualColors[_random.nextInt(visualColors.length)];
  final gridSize = 6 + _random.nextInt(3); // 6-8 shapes
  final oddIndex = _random.nextInt(gridSize);

  ShapeData oddShape;
  final useColorDiff = _random.nextBool();
  if (useColorDiff) {
    Color oddColor;
    do {
      oddColor = visualColors[_random.nextInt(visualColors.length)];
    } while (oddColor == baseColor);
    oddShape = ShapeData(icon: baseIcon, color: oddColor);
  } else {
    IconData oddIcon;
    do {
      oddIcon = visualIcons[_random.nextInt(visualIcons.length)];
    } while (oddIcon == baseIcon);
    oddShape = ShapeData(icon: oddIcon, color: baseColor);
  }

  final shapes = List.generate(
    gridSize,
    (i) =>
        i == oddIndex ? oddShape : ShapeData(icon: baseIcon, color: baseColor),
  );

  return VisualRound(
    type: VisualGameType.oddOneOut,
    instruction: 'Alag shape dhoondo',
    displayShapes: shapes,
    correctIndex: oddIndex,
  );
}

VisualRound _generateSpotDifference() {
  final gridSize = 6;
  final original = List.generate(gridSize, (_) => _randomShape());
  final changedIndex = _random.nextInt(gridSize);
  final modified = List<ShapeData>.from(original);
  ShapeData newShape;
  do {
    newShape = _randomShape();
  } while (newShape.icon == original[changedIndex].icon &&
      newShape.color == original[changedIndex].color);
  modified[changedIndex] = newShape;

  return VisualRound(
    type: VisualGameType.spotDifference,
    instruction: 'Dono grid mein farak dhoondo',
    displayShapes: original,
    compareShapes: modified,
    correctIndex: changedIndex,
  );
}

VisualRound _generateIllusionQuiz() {
  final illusions = [
    () {
      final count = 5 + _random.nextInt(10);
      final shape = _randomShape();
      return VisualRound(
        type: VisualGameType.illusionQuiz,
        instruction: 'Kitne shapes hain gin lo',
        displayShapes: List.generate(count, (_) => shape),
        correctIndex: 0,
        textOptions: [
          '$count',
          '${count + 2}',
          '${count - 2 < 1 ? count + 1 : count - 2}',
          '${count + 4}',
        ]..shuffle(_random),
      );
    },
    () {
      final color = visualColors[_random.nextInt(visualColors.length)];
      final shapes = List.generate(
        8,
        (_) => ShapeData(icon: Icons.circle, color: color),
      );
      return VisualRound(
        type: VisualGameType.illusionQuiz,
        instruction: 'Sabhi shapes ka color same hai?',
        displayShapes: shapes,
        correctIndex: 0,
        textOptions: ['Haan, sab same', 'Nahi, alag hain']..shuffle(_random),
      );
    },
  ];
  final chosen = illusions[_random.nextInt(illusions.length)]();
  // fix correctIndex based on textOptions position
  if (chosen.textOptions != null) {
    final correctAnswerText = chosen.instruction.contains('Kitne')
        ? chosen.displayShapes.length.toString()
        : 'Haan, sab same';
    final idx = chosen.textOptions!.indexOf(correctAnswerText);
    return VisualRound(
      type: chosen.type,
      instruction: chosen.instruction,
      displayShapes: chosen.displayShapes,
      correctIndex: idx == -1 ? 0 : idx,
      textOptions: chosen.textOptions,
    );
  }
  return chosen;
}

VisualRound generateRound() {
  final types = VisualGameType.values;
  final type = types[_random.nextInt(types.length)];
  switch (type) {
    case VisualGameType.patternMatch:
      return _generatePatternMatch();
    case VisualGameType.oddOneOut:
      return _generateOddOneOut();
    case VisualGameType.spotDifference:
      return _generateSpotDifference();
    case VisualGameType.illusionQuiz:
      return _generateIllusionQuiz();
  }
}

class VisualGameState {
  final List<VisualRound> rounds;
  final int currentIndex;
  final int score;
  final int correct;
  final int wrong;
  final int timeLeft;
  final bool answered;
  final int? selectedIndex;
  final bool isFinished;

  const VisualGameState({
    required this.rounds,
    this.currentIndex = 0,
    this.score = 0,
    this.correct = 0,
    this.wrong = 0,
    this.timeLeft = 15,
    this.answered = false,
    this.selectedIndex,
    this.isFinished = false,
  });

  VisualRound? get currentRound =>
      currentIndex < rounds.length ? rounds[currentIndex] : null;

  VisualGameState copyWith({
    int? currentIndex,
    int? score,
    int? correct,
    int? wrong,
    int? timeLeft,
    bool? answered,
    int? selectedIndex,
    bool? isFinished,
  }) {
    return VisualGameState(
      rounds: rounds,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      timeLeft: timeLeft ?? this.timeLeft,
      answered: answered ?? this.answered,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class VisualGameNotifier extends StateNotifier<VisualGameState> {
  Timer? _timer;
  final DateTime _startTime = DateTime.now();

  VisualGameNotifier()
    : super(VisualGameState(rounds: List.generate(5, (_) => generateRound()))) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.answered) return;
      if (state.timeLeft <= 0) {
        _timeUp();
      } else {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      }
    });
  }

  void _timeUp() {
    state = state.copyWith(answered: true, wrong: state.wrong + 1);
    audioManager.playWrong();
    Future.delayed(const Duration(seconds: 2), nextRound);
  }

  void answer(int index) {
    if (state.answered) return;
    final round = state.currentRound;
    if (round == null) return;

    final isCorrect = index == round.correctIndex;
    final points = isCorrect ? (state.timeLeft * 10) : 0;

    if (isCorrect) {
      audioManager.playCorrect();
    } else {
      audioManager.playWrong();
      audioManager.vibrateWrong();
    }

    state = state.copyWith(
      answered: true,
      selectedIndex: index,
      score: state.score + points,
      correct: isCorrect ? state.correct + 1 : state.correct,
      wrong: isCorrect ? state.wrong : state.wrong + 1,
    );

    Future.delayed(const Duration(seconds: 2), nextRound);
  }

  void nextRound() {
    if (state.currentIndex + 1 >= state.rounds.length) {
      _timer?.cancel();
      state = state.copyWith(isFinished: true);
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      timeLeft: 15,
      answered: false,
      selectedIndex: null,
    );
    _startTimer();
  }

  VisualResult getResult() {
    return VisualResult(
      score: state.score,
      correct: state.correct,
      wrong: state.wrong,
      total: state.rounds.length,
      timeTaken: DateTime.now().difference(_startTime),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final visualGameProvider =
    StateNotifierProvider.autoDispose<VisualGameNotifier, VisualGameState>(
      (ref) => VisualGameNotifier(),
    );
