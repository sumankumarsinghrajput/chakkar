import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/avatar_widget.dart';
import '../friends/friends_provider.dart';
import '../friends/friends_model.dart';
import 'room_provider.dart';
import 'lobby_screen.dart';

class CreateRoomWithFriendsScreen extends ConsumerStatefulWidget {
  const CreateRoomWithFriendsScreen({super.key});

  @override
  ConsumerState<CreateRoomWithFriendsScreen> createState() => _CreateRoomWithFriendsScreenState();
}

class _CreateRoomWithFriendsScreenState extends ConsumerState<CreateRoomWithFriendsScreen> {
  final Set<String> _selectedUids = {};
  final _roomNameController = TextEditingController(text: 'Friends Match');
  String _difficulty = 'easy';
  bool _isCreating = false;

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PLAY WITH FRIENDS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _roomNameController,
              style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Rajdhani'),
              decoration: InputDecoration(
                labelText: 'Room Name',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Text('Select Friends to Invite (online only)', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Expanded(
              child: friendsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (friends) {
                  if (friends.isEmpty) {
                    return Center(
                      child: Text('No friends yet. Add some from the Friends tab!',
                          style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                    );
                  }
                  return ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return _FriendSelectTile(
                        friend: friend,
                        isSelected: _selectedUids.contains(friend.uid),
                        onToggle: (uid, canSelect) {
                          if (!canSelect) return;
                          setState(() {
                            if (_selectedUids.contains(uid)) {
                              _selectedUids.remove(uid);
                            } else {
                              _selectedUids.add(uid);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _selectedUids.isEmpty || _isCreating
                  ? null
                  : () async {
                      setState(() => _isCreating = true);
                      final roomId = await ref.read(roomProvider.notifier).createRoomWithFriends(
                            roomName: _roomNameController.text.trim().isEmpty
                                ? 'Friends Match'
                                : _roomNameController.text.trim(),
                            friendUids: _selectedUids.toList(),
                            difficulty: _difficulty,
                          );
                      if (roomId != null && context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LobbyScreen(roomId: roomId)),
                        );
                      } else {
                        setState(() => _isCreating = false);
                      }
                    },
              child: _isCreating
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('CREATE ROOM (${_selectedUids.length} selected)'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FriendSelectTile extends ConsumerWidget {
  final FriendUser friend;
  final bool isSelected;
  final Function(String uid, bool canSelect) onToggle;

  const _FriendSelectTile({required this.friend, required this.isSelected, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenceAsync = ref.watch(friendPresenceProvider(friend.uid));

    return presenceAsync.when(
      loading: () => const SizedBox(height: 60),
      error: (_, __) => const SizedBox(height: 60),
      data: (presence) {
        final canSelect = presence.isOnline && !presence.inGame;
        return GestureDetector(
          onTap: () => onToggle(friend.uid, canSelect),
          child: Opacity(
            opacity: canSelect ? 1.0 : 0.4,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      AvatarWidget(avatarId: friend.avatarId, size: 40),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: presence.isOnline ? AppColors.success : AppColors.textMuted,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(friend.username, style: Theme.of(context).textTheme.titleLarge),
                        Text(
                          presence.inGame
                              ? 'In a game'
                              : presence.isOnline
                                  ? 'Online'
                                  : 'Offline',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: presence.isOnline && !presence.inGame ? AppColors.success : AppColors.textMuted,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (canSelect)
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}