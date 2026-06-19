import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_models.dart';
import '../../shared/services/audio_manager.dart';

// Sample questions database
final List<Question> _allQuestions = [
  // Brain Trap - Easy
  Question(
    id: 'bt1',
    question: 'How many months have 28 days?',
    options: ['1', '2', '6', '12'],
    correctIndex: 3,
    explanation: 'All 12 months have at least 28 days!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt2',
    question: 'A rooster lays an egg on top of a hill. Which way does it roll?',
    options: ['Left', 'Right', 'Down the hill', 'Roosters don\'t lay eggs'],
    correctIndex: 3,
    explanation: 'Roosters are male — they don\'t lay eggs!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt3',
    question: 'What is 1 + 1 + 1 + 1 + 1 x 0?',
    options: ['0', '4', '5', '6'],
    correctIndex: 1,
    explanation: 'Multiplication first! 1x0=0, then 1+1+1+1+0 = 4',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt4',
    question: 'If you have 3 apples and take away 2, how many do YOU have?',
    options: ['1', '2', '3', '0'],
    correctIndex: 1,
    explanation: 'You TOOK 2 apples, so you have 2!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt5',
    question: 'Which is heavier: 1kg of iron or 1kg of feathers?',
    options: ['Iron', 'Feathers', 'They are equal', 'Depends on size'],
    correctIndex: 2,
    explanation: 'Both weigh exactly 1kg!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  // Logic
  Question(
    id: 'lg1',
    question:
        'If all Bloops are Razzles and all Razzles are Lazzles, are all Bloops definitely Lazzles?',
    options: ['Yes', 'No', 'Maybe', 'Cannot say'],
    correctIndex: 0,
    explanation: 'Bloops → Razzles → Lazzles, so Bloops are Lazzles!',
    category: GameCategory.logic,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lg2',
    question: 'What comes next: 2, 4, 8, 16, ?',
    options: ['24', '32', '18', '20'],
    correctIndex: 1,
    explanation: 'Each number doubles: 16 x 2 = 32',
    category: GameCategory.logic,
    difficulty: Difficulty.easy,
  ),
  // Memory
  Question(
    id: 'mm1',
    question:
        'Which color appears in BOTH the Indian flag and the French flag?',
    options: ['Green', 'Orange', 'Blue', 'White'],
    correctIndex: 3,
    explanation: 'White appears in both flags!',
    category: GameCategory.memory,
    difficulty: Difficulty.easy,
  ),
];

List<Question> getQuestions(GameCategory category, Difficulty difficulty) {
  final filtered = _allQuestions
      .where((q) => q.category == category && q.difficulty == difficulty)
      .toList();

  if (filtered.isEmpty) {
    return _allQuestions.where((q) => q.category == category).toList();
  }
  return filtered;
}

// Game State
class GameState {
  final List<Question> questions;
  final int currentIndex;
  final int score;
  final int correct;
  final int wrong;
  final int timeLeft;
  final bool answered;
  final int? selectedIndex;
  final bool isFinished;

  const GameState({
    required this.questions,
    this.currentIndex = 0,
    this.score = 0,
    this.correct = 0,
    this.wrong = 0,
    this.timeLeft = 30,
    this.answered = false,
    this.selectedIndex,
    this.isFinished = false,
  });

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  GameState copyWith({
    int? currentIndex,
    int? score,
    int? correct,
    int? wrong,
    int? timeLeft,
    bool? answered,
    int? selectedIndex,
    bool? isFinished,
  }) {
    return GameState(
      questions: questions,
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

class GameNotifier extends StateNotifier<GameState> {
  Timer? _timer;
  final Difficulty difficulty;
  final DateTime _startTime = DateTime.now();

  GameNotifier({required List<Question> questions, required this.difficulty})
    : super(GameState(questions: questions, timeLeft: difficulty.timeLimit)) {
    _startTimer();
  }

  void _startTimer() {
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
    Future.delayed(const Duration(seconds: 2), nextQuestion);
  }

  void answerQuestion(int index) {
    if (state.answered) return;
    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = index == question.correctIndex;
    final points = isCorrect
        ? (state.timeLeft * difficulty.pointsMultiplier * 10)
        : 0;

    // Play sound
    if (isCorrect) {
      print('Playing correct sound');
      audioManager.playCorrect();
    } else {
      print('Playing wrong sound');
      audioManager.playWrong();
    }

    state = state.copyWith(
      answered: true,
      selectedIndex: index,
      score: state.score + points,
      correct: isCorrect ? state.correct + 1 : state.correct,
      wrong: isCorrect ? state.wrong : state.wrong + 1,
    );

    Future.delayed(const Duration(seconds: 2), nextQuestion);
  }

  void nextQuestion() {
    if (state.currentIndex + 1 >= state.questions.length) {
      _timer?.cancel();
      state = state.copyWith(isFinished: true);
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      timeLeft: difficulty.timeLimit,
      answered: false,
      selectedIndex: null,
    );
  }

  GameResult getResult() {
    return GameResult(
      score: state.score,
      correct: state.correct,
      wrong: state.wrong,
      total: state.questions.length,
      timeTaken: DateTime.now().difference(_startTime),
      difficulty: difficulty,
      category: state.questions.first.category,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final gameProvider =
    StateNotifierProvider.family<GameNotifier, GameState, Map<String, dynamic>>(
      (ref, params) {
        return GameNotifier(
          questions: params['questions'] as List<Question>,
          difficulty: params['difficulty'] as Difficulty,
        );
      },
    );
