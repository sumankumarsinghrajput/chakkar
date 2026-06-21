import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/avatar_widget.dart';
import '../friends/friends_provider.dart';
import 'create_room_screen.dart';

class InviteFriendsScreen extends ConsumerWidget {
  const InviteFriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('INVITE FRIENDS'),
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
            Text(
              'Create a room first, then invite friends below',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('CREATE A ROOM'),
            ),
            const SizedBox(height: 24),
            Text(
              'YOUR FRIENDS',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(letterSpacing: 2),
            ),
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
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            AvatarWidget(avatarId: friend.avatarId, size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(friend.username, style: Theme.of(context).textTheme.titleLarge),
                            ),
                            Text(
                              'Create a room to invite',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}