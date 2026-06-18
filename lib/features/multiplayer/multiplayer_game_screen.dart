import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/avatar_widget.dart';
import '../game/game_models.dart';
import 'multiplayer_game_provider.dart';
import 'multiplayer_result_screen.dart';
import 'room_model.dart';

class MultiplayerGameScreen extends ConsumerStatefulWidget {
  final String roomId;
  final bool isHost;
  final List<Question> questions;
  final List<RoomPlayer> players;

  const MultiplayerGameScreen({
    super.key,
    required this.roomId,
    required this.isHost,
    required this.questions,
    required this.players,
  });

  @override
  ConsumerState<MultiplayerGameScreen> createState() =>
      _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState
    extends ConsumerState<MultiplayerGameScreen> {
  late final Map<String, dynamic> _params;

  @override
  void initState() {
    super.initState();
    _params = {
      'roomId': widget.roomId,
      'isHost': widget.isHost,
      'questions': widget.questions,
    };
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(multiplayerGameProvider(_params));
    final notifier =
        ref.read(multiplayerGameProvider(_params).notifier);

    if (gameState.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MultiplayerResultScreen(
              scores: gameState.scores,
              players: widget.players,
              roomId: widget.roomId,
            ),
          ),
        );
      });
    }

    final question = gameState.currentQuestion;
    if (question == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child:
              CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (gameState.currentQuestionIndex + 1) /
                            gameState.questions.length,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${gameState.currentQuestionIndex + 1}/${gameState.questions.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Timer & Round
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ROUND ${gameState.currentQuestionIndex + 1}/${gameState.questions.length}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(letterSpacing: 2),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: gameState.timeLeft <= 5
                          ? AppColors.danger.withOpacity(0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: gameState.timeLeft <= 5
                            ? AppColors.danger
                            : AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${gameState.timeLeft}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            color: gameState.timeLeft <= 5
                                ? AppColors.danger
                                : AppColors.primary,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mini scoreboard
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: widget.players.map((player) {
                    final score =
                        gameState.scores[player.uid] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          AvatarWidget(
                              avatarId: player.avatarId, size: 32),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.username,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 11),
                              ),
                              Text(
                                '$score',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Question
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  question.question,
                  style:
                      Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              // Options
              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    Color bgColor = AppColors.surface;
                    Color borderColor =
                        AppColors.primary.withOpacity(0.2);

                    if (gameState.answered) {
                      if (index == question.correctIndex) {
                        bgColor =
                            AppColors.success.withOpacity(0.3);
                        borderColor = AppColors.success;
                      } else if (index ==
                          gameState.selectedIndex) {
                        bgColor =
                            AppColors.danger.withOpacity(0.3);
                        borderColor = AppColors.danger;
                      }
                    }

                    return GestureDetector(
                      onTap: gameState.answered
                          ? null
                          : () => notifier.answerQuestion(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: borderColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            question.options[index],
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}