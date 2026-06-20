import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/avatar_widget.dart';
import 'room_model.dart';
import '../home/home_screen.dart';
import 'lobby_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'share_card_screen.dart';
import '../match_history/match_provider.dart';
import '../match_history/match_model.dart';
import '../../shared/services/audio_manager.dart';

class MultiplayerResultScreen extends StatefulWidget {
  final Map<String, int> scores;
  final List<RoomPlayer> players;
  final String roomId;

  const MultiplayerResultScreen({
    super.key,
    required this.scores,
    required this.players,
    required this.roomId,
  });

  @override
  State<MultiplayerResultScreen> createState() =>
      _MultiplayerResultScreenState();
}

class _MultiplayerResultScreenState extends State<MultiplayerResultScreen> {
  Map<String, int> get scores => widget.scores;
  List<RoomPlayer> get players => widget.players;
  String get roomId => widget.roomId;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveMatch();
  }

  void _saveMatch() {
    if (_saved) return;
    _saved = true;

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final ranked = _rankedPlayers;
    final myEntry = ranked.firstWhere(
      (e) => e.key.uid == currentUid,
      orElse: () => ranked.first,
    );
    final myRank = ranked.indexOf(myEntry) + 1;

    saveMatchRecord(
      mode: MatchMode.multiplayer,
      category: 'GameCategory.brainTrap',
      difficulty: 'Difficulty.easy',
      score: myEntry.value,
      correct: 0,
      wrong: 0,
      total: 0,
      isWin: myRank == 1,
      rank: myRank,
      totalPlayers: players.length,
    );
  }

  List<MapEntry<RoomPlayer, int>> get _rankedPlayers {
    final playerScores = players.map((p) {
      return MapEntry(p, scores[p.uid] ?? 0);
    }).toList();
    playerScores.sort((a, b) => b.value.compareTo(a.value));
    return playerScores;
  }

  @override
  Widget build(BuildContext context) {
    final ranked = _rankedPlayers;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final myRank = ranked.indexWhere((e) => e.key.uid == currentUid) + 1;
    final isWinner = myRank == 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Result Title
              Text(
                isWinner ? 'YOU WIN!' : 'MATCH OVER!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: isWinner ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isWinner ? 'Brain Master!' : 'Rank #$myRank',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Scoreboard
              Expanded(
                child: ListView.builder(
                  itemCount: ranked.length,
                  itemBuilder: (context, index) {
                    final entry = ranked[index];
                    final player = entry.key;
                    final score = entry.value;
                    final isMe = player.uid == currentUid;
                    final rank = index + 1;

                    Color rankColor = AppColors.textSecondary;
                    if (rank == 1) rankColor = const Color(0xFFFFD700);
                    if (rank == 2) rankColor = const Color(0xFFC0C0C0);
                    if (rank == 3) rankColor = const Color(0xFFCD7F32);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isMe
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isMe ? AppColors.primary : AppColors.card,
                          width: isMe ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Rank
                          SizedBox(
                            width: 32,
                            child: Text(
                              '#$rank',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: rankColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Avatar
                          AvatarWidget(avatarId: player.avatarId, size: 44),
                          const SizedBox(width: 12),
                          // Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  player.username,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: isMe
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                ),
                                if (player.isHost)
                                  const Text(
                                    'HOST',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                      fontFamily: 'Rajdhani',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Score
                          Text(
                            '$score',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: rankColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Buttons
              ElevatedButton.icon(
                onPressed: () {
                  final currentUid = FirebaseAuth.instance.currentUser?.uid;
                  final myEntry = ranked.firstWhere(
                    (e) => e.key.uid == currentUid,
                    orElse: () => ranked.last,
                  );
                  final myRank = ranked.indexOf(myEntry) + 1;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShareCardScreen(
                        username: myEntry.key.username,
                        avatarId: myEntry.key.avatarId,
                        rank: myRank,
                        score: myEntry.value,
                        totalPlayers: ranked.length,
                        isWinner: myRank == 1,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('SHARE RESULT'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(roomId)
                      .update({'status': 'waiting'});
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LobbyScreen(roomId: roomId),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                ),
                child: const Text('BACK TO LOBBY'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  audioManager.stopAll();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'HOME',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
