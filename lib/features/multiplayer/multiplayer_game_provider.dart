import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/game_models.dart';

final _db = FirebaseDatabase.instance;
final _auth = FirebaseAuth.instance;

class MultiplayerGameState {
  final int currentQuestionIndex;
  final int timeLeft;
  final bool answered;
  final int? selectedIndex;
  final Map<String, int> scores;
  final bool isFinished;
  final List<Question> questions;

  const MultiplayerGameState({
    this.currentQuestionIndex = 0,
    this.timeLeft = 20,
    this.answered = false,
    this.selectedIndex,
    this.scores = const {},
    this.isFinished = false,
    required this.questions,
  });

  Question? get currentQuestion =>
      currentQuestionIndex < questions.length
          ? questions[currentQuestionIndex]
          : null;

  MultiplayerGameState copyWith({
    int? currentQuestionIndex,
    int? timeLeft,
    bool? answered,
    int? selectedIndex,
    Map<String, int>? scores,
    bool? isFinished,
  }) {
    return MultiplayerGameState(
      questions: questions,
      currentQuestionIndex:
          currentQuestionIndex ?? this.currentQuestionIndex,
      timeLeft: timeLeft ?? this.timeLeft,
      answered: answered ?? this.answered,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      scores: scores ?? this.scores,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class MultiplayerGameNotifier
    extends StateNotifier<MultiplayerGameState> {
  final String roomId;
  final bool isHost;
  Timer? _timer;
  StreamSubscription? _gameSub;

  MultiplayerGameNotifier({
    required this.roomId,
    required this.isHost,
    required List<Question> questions,
  }) : super(MultiplayerGameState(questions: questions)) {
    _initGame();
  }

  void _initGame() {
    _gameSub = _db.ref('games/$roomId').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return;

      final scores = Map<String, int>.from(
        (data['scores'] as Map<dynamic, dynamic>? ?? {})
            .map((k, v) => MapEntry(k.toString(), v as int)),
      );

      final questionIndex = data['currentQuestion'] as int? ?? 0;
      final isFinished = data['isFinished'] as bool? ?? false;

      final prevIndex = state.currentQuestionIndex;

      state = state.copyWith(
        currentQuestionIndex: questionIndex,
        scores: scores,
        isFinished: isFinished,
        answered: questionIndex != prevIndex ? false : state.answered,
        selectedIndex: questionIndex != prevIndex ? null : state.selectedIndex,
        timeLeft: questionIndex != prevIndex ? 20 : state.timeLeft,
      );

      if (questionIndex != prevIndex) {
        _startTimer();
      }
    });

    if (isHost) {
      _setupGame();
    }
    _startTimer();
  }

  Future<void> _setupGame() async {
    await _db.ref('games/$roomId').set({
      'currentQuestion': 0,
      'isFinished': false,
      'scores': {},
      'startedAt': ServerValue.timestamp,
    });
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
    state = state.copyWith(answered: true);
    if (isHost) {
      Future.delayed(const Duration(seconds: 2), _nextQuestion);
    }
  }

  Future<void> answerQuestion(int index) async {
    if (state.answered) return;
    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = index == question.correctIndex;
    final points = isCorrect ? (state.timeLeft * 10) : 0;

    state = state.copyWith(
      answered: true,
      selectedIndex: index,
    );

    if (points > 0) {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _db
            .ref('games/$roomId/scores/$uid')
            .set(ServerValue.increment(points));
      }
    }

    if (isHost) {
      Future.delayed(const Duration(seconds: 2), _nextQuestion);
    }
  }

  Future<void> _nextQuestion() async {
    final nextIndex = state.currentQuestionIndex + 1;
    if (nextIndex >= state.questions.length) {
      await _db.ref('games/$roomId').update({'isFinished': true});
    } else {
      await _db
          .ref('games/$roomId')
          .update({'currentQuestion': nextIndex});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gameSub?.cancel();
    super.dispose();
  }
}

final multiplayerGameProvider =
    StateNotifierProvider.family<MultiplayerGameNotifier,
        MultiplayerGameState, Map<String, dynamic>>((ref, params) {
  return MultiplayerGameNotifier(
    roomId: params['roomId'] as String,
    isHost: params['isHost'] as bool,
    questions: params['questions'] as List<Question>,
  );
});