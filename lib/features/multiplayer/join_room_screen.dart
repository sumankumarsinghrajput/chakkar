import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'room_provider.dart';
import 'lobby_screen.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter a room code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final roomId =
        await ref.read(roomProvider.notifier).findRoomByCode(code);

    if (roomId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Room not found. Check the code and try again.';
      });
      return;
    }

    final success =
        await ref.read(roomProvider.notifier).requestJoin(roomId);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            roomId: roomId,
            isJoining: true,
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Failed to join room. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('JOIN ROOM'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'ENTER ROOM CODE',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    letterSpacing: 3,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _error != null
                      ? AppColors.danger
                      : AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _codeController,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 4,
                    ),
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'e.g. ABC-1234',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    letterSpacing: 2,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
                onChanged: (_) => setState(() => _error = null),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : ElevatedButton(
                    onPressed: _joinRoom,
                    child: const Text('JOIN ROOM'),
                  ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Can\'t find the room?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => setState(() => _error = null),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side:
                    const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'REFRESH',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}