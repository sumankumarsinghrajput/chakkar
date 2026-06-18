import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/avatar_widget.dart';
import 'room_model.dart';
import 'room_provider.dart';
import '../home/home_screen.dart';
import '../game/game_models.dart';
import '../game/game_provider.dart';
import 'multiplayer_game_screen.dart';

class LobbyScreen extends ConsumerWidget {
  final String roomId;
  final bool isJoining;

  const LobbyScreen({super.key, required this.roomId, this.isJoining = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomStreamProvider(roomId));

    return roomAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text(e.toString())),
      ),
      data: (room) {
        if (room == null) {
          // Auto navigate home without showing error screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          });
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final currentUid = auth.currentUser?.uid;
        final isHost = room.hostId == currentUid;

        // If joining player got approved, navigate to game
        final isApproved = room.players.any((p) => p.uid == currentUid);

        // If game started, navigate all players to game
        if (room.status == RoomStatus.playing && !isJoining) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final questions = getQuestions(
              GameCategory.brainTrap,
              Difficulty.easy,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MultiplayerGameScreen(
                  roomId: roomId,
                  isHost: isHost,
                  questions: questions,
                  players: room.players,
                ),
              ),
            );
          });
        }

        // If joining player got approved show lobby
        if (isJoining && !isHost && isApproved) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LobbyScreen(roomId: roomId, isJoining: false),
              ),
            );
          });
        }

        // Show join request popup for host
        if (isHost && room.pendingRequests.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showJoinRequest(context, ref, room, room.pendingRequests.first);
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await ref
                              .read(roomProvider.notifier)
                              .leaveRoom(roomId);
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          room.roomName.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Room Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ROOM CODE',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(letterSpacing: 2),
                              ),
                              Text(
                                room.roomCode,
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      letterSpacing: 4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: room.roomCode),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Room code copied!'),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.copy,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Players
                  Text(
                    'PLAYERS (${room.playerCount}/${room.maxPlayers})',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        ...room.players.map(
                          (player) => _PlayerTile(
                            player: player,
                            isHost: isHost,
                            roomId: roomId,
                            ref: ref,
                          ),
                        ),
                        // Empty slots
                        ...List.generate(
                          room.maxPlayers - room.playerCount,
                          (i) => _EmptySlot(),
                        ),
                      ],
                    ),
                  ),
                  // Waiting message for joining player
                  if (isJoining && !isHost)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Waiting for host approval...',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Start button for host
                  if (isHost)
                    ElevatedButton(
                      onPressed: room.playerCount >= 2
                          ? () async {
                              await ref
                                  .read(roomProvider.notifier)
                                  .startGame(roomId);
                            }
                          : null,
                      child: Text(
                        room.playerCount >= 2
                            ? 'START GAME'
                            : 'WAITING FOR PLAYERS...',
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showJoinRequest(
    BuildContext context,
    WidgetRef ref,
    RoomModel room,
    String playerId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _JoinRequestDialog(roomId: roomId, playerId: playerId, ref: ref),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final RoomPlayer player;
  final bool isHost;
  final String roomId;
  final WidgetRef ref;

  const _PlayerTile({
    required this.player,
    required this.isHost,
    required this.roomId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: player.isHost
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.card,
        ),
      ),
      child: Row(
        children: [
          AvatarWidget(avatarId: player.avatarId, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.username,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (player.isHost) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HOST',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontFamily: 'Rajdhani',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Level ${player.level}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(Icons.circle, color: AppColors.success, size: 10),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textMuted.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.card,
              border: Border.all(color: AppColors.textMuted.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.person_add_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Waiting for player...',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _JoinRequestDialog extends ConsumerWidget {
  final String roomId;
  final String playerId;
  final WidgetRef ref;

  const _JoinRequestDialog({
    required this.roomId,
    required this.playerId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: firestore.collection('users').doc(playerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        final data = snapshot.data!.data()!;
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'NEW JOIN REQUEST',
            style: TextStyle(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarWidget(avatarId: data['avatarId'] ?? '', size: 64),
              const SizedBox(height: 12),
              Text(
                data['displayUsername'] ?? '',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Level ${data['level'] ?? 1}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'wants to join your room',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref
                          .read(roomProvider.notifier)
                          .rejectPlayer(roomId, playerId);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    child: const Text(
                      'REJECT',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(roomProvider.notifier)
                          .approvePlayer(roomId, playerId);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('ACCEPT'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
