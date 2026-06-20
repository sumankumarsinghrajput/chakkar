import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/game_models.dart';
import '../game/game_provider.dart';
import '../visual_game/visual_models.dart';
import '../visual_game/visual_provider.dart';
import '../../shared/services/audio_manager.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

// Deterministic daily question set: same seed -> same questions for everyone today
List<Question> getDailyQuestions() {
  final seed = _todayKey().hashCode;
  final difficulties = [
    Difficulty.easy,
    Difficulty.medium,
    Difficulty.hard,
    Difficulty.expert,
    Difficulty.insane,
  ];

  final result = <Question>[];
  for (final diff in difficulties) {
    final pool = getQuestions(GameCategory.brainTrap, diff);
    if (pool.isNotEmpty) {
      final index = seed.abs() % pool.length;
      result.add(pool[index]);
    }
  }
  return result;
}

List<VisualRound> getDailyVisualRounds() {
  return List.generate(2, (_) => generateRound());
}

final dailyCompletedProvider = StreamProvider<bool>((ref) {
  final user = _auth.currentUser;
  if (user == null) return Stream.value(false);

  return _firestore
      .collection('users')
      .doc(user.uid)
      .collection('daily')
      .doc(_todayKey())
      .snapshots()
      .map((doc) => doc.exists && (doc.data()?['completed'] == true));
});

class DailyChallengeState {
  final List<Question> questions;
  final List<VisualRound> visualRounds;
  final int currentIndex;
  final int score;
  final int correct;
  final int wrong;
  final int timeLeft;
  final bool answered;
  final int? selectedIndex;
  final bool isFinished;

  const DailyChallengeState({
    required this.questions,
    required this.visualRounds,
    this.currentIndex = 0,
    this.score = 0,
    this.correct = 0,
    this.wrong = 0,
    this.timeLeft = 20,
    this.answered = false,
    this.selectedIndex,
    this.isFinished = false,
  });

  int get totalSteps => questions.length + visualRounds.length;
  bool get isVisualStep => currentIndex >= questions.length;
  Question? get currentQuestion =>
      !isVisualStep && currentIndex < questions.length ? questions[currentIndex] : null;
  VisualRound? get currentVisual =>
      isVisualStep && (currentIndex - questions.length) < visualRounds.length
          ? visualRounds[currentIndex - questions.length]
          : null;

  DailyChallengeState copyWith({
    int? currentIndex,
    int? score,
    int? correct,
    int? wrong,
    int? timeLeft,
    bool? answered,
    int? selectedIndex,
    bool? isFinished,
  }) {
    return DailyChallengeState(
      questions: questions,
      visualRounds: visualRounds,
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

class DailyChallengeNotifier extends StateNotifier<DailyChallengeState> {
  Timer? _timer;

  DailyChallengeNotifier()
      : super(DailyChallengeState(
          questions: getDailyQuestions(),
          visualRounds: getDailyVisualRounds(),
        )) {
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
    Future.delayed(const Duration(seconds: 2), nextStep);
  }

  void answer(int index) {
    if (state.answered) return;
    int correctIndex = -1;

    if (state.isVisualStep) {
      correctIndex = state.currentVisual?.correctIndex ?? -1;
    } else {
      correctIndex = state.currentQuestion?.correctIndex ?? -1;
    }

    final isCorrect = index == correctIndex;
    final points = isCorrect ? (state.timeLeft * 15) : 0;

    if (isCorrect) {
      audioManager.playCorrect();
    } else {
      audioManager.playWrong();
    }

    state = state.copyWith(
      answered: true,
      selectedIndex: index,
      score: state.score + points,
      correct: isCorrect ? state.correct + 1 : state.correct,
      wrong: isCorrect ? state.wrong : state.wrong + 1,
    );

    Future.delayed(const Duration(seconds: 2), nextStep);
  }

  void nextStep() {
    if (state.currentIndex + 1 >= state.totalSteps) {
      _timer?.cancel();
      state = state.copyWith(isFinished: true);
      _completeChallenge();
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      timeLeft: 20,
      answered: false,
      selectedIndex: null,
    );
    _startTimer();
  }

  Future<void> _completeChallenge() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final accuracy = state.totalSteps == 0 ? 0 : state.correct / state.totalSteps;
    final coinReward = (accuracy * 100).round().clamp(10, 100);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily')
        .doc(_todayKey())
        .set({
      'completed': true,
      'score': state.score,
      'correct': state.correct,
      'total': state.totalSteps,
      'coinReward': coinReward,
      'completedAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(user.uid).update({
      'coins': FieldValue.increment(coinReward),
    });
  }

  int get coinReward {
    final accuracy = state.totalSteps == 0 ? 0 : state.correct / state.totalSteps;
    return (accuracy * 100).round().clamp(10, 100);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final dailyChallengeProvider =
    StateNotifierProvider.autoDispose<DailyChallengeNotifier, DailyChallengeState>(
        (ref) => DailyChallengeNotifier());