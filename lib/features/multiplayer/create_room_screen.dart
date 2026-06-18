import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'room_provider.dart';
import 'lobby_screen.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() =>
      _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _roomNameController = TextEditingController();
  final _customCodeController = TextEditingController();
  int _maxPlayers = 4;
  String _difficulty = 'easy';
  bool _isPublic = true;
  bool _useCustomCode = false;
  late String _autoCode;

  @override
  void initState() {
    super.initState();
    _autoCode = generateRoomCode();
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _customCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CREATE ROOM'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context, 'ROOM NAME'),
            const SizedBox(height: 8),
            _inputField(
              controller: _roomNameController,
              hint: 'Enter room name',
            ),
            const SizedBox(height: 16),
            _label(context, 'MAX PLAYERS'),
            const SizedBox(height: 8),
            _DropdownField(
              value: _maxPlayers.toString(),
              items: ['2', '3', '4', '5', '6'],
              onChanged: (v) =>
                  setState(() => _maxPlayers = int.parse(v!)),
            ),
            const SizedBox(height: 16),
            _label(context, 'DIFFICULTY'),
            const SizedBox(height: 8),
            _DropdownField(
              value: _difficulty,
              items: ['easy', 'medium', 'hard', 'expert', 'insane'],
              onChanged: (v) => setState(() => _difficulty = v!),
            ),
            const SizedBox(height: 16),
            _label(context, 'ROOM CODE'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      _useCustomCode
                          ? (_customCodeController.text.isEmpty
                              ? 'Enter custom code'
                              : _customCodeController.text)
                          : _autoCode,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 3,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() => _autoCode = generateRoomCode());
                  },
                  icon: const Icon(Icons.refresh,
                      color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Switch(
                  value: _useCustomCode,
                  onChanged: (v) =>
                      setState(() => _useCustomCode = v),
                  activeColor: AppColors.primary,
                ),
                Text(
                  'Use custom code',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (_useCustomCode)
              _inputField(
                controller: _customCodeController,
                hint: 'Enter custom code (e.g. BRAIN123)',
                onChanged: (_) => setState(() {}),
              ),
            const SizedBox(height: 16),
            _label(context, 'ROOM TYPE'),
            const SizedBox(height: 8),
            Row(
              children: [
                _TypeButton(
                  label: 'PUBLIC',
                  icon: Icons.public,
                  selected: _isPublic,
                  onTap: () => setState(() => _isPublic = true),
                ),
                const SizedBox(width: 12),
                _TypeButton(
                  label: 'PRIVATE',
                  icon: Icons.lock,
                  selected: !_isPublic,
                  onTap: () => setState(() => _isPublic = false),
                ),
              ],
            ),
            const SizedBox(height: 32),
            roomState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : ElevatedButton(
                    onPressed: _createRoom,
                    child: const Text('CREATE ROOM'),
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _createRoom() async {
    if (_roomNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a room name')),
      );
      return;
    }

    final roomId = await ref.read(roomProvider.notifier).createRoom(
          roomName: _roomNameController.text.trim(),
          maxPlayers: _maxPlayers,
          difficulty: _difficulty,
          isPublic: _isPublic,
          customCode: _useCustomCode
              ? _customCodeController.text.trim().toUpperCase()
              : _autoCode,
        );

    if (roomId != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LobbyScreen(roomId: roomId),
        ),
      );
    }
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            letterSpacing: 2,
            color: AppColors.textSecondary,
          ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
            color: AppColors.textPrimary, fontFamily: 'Rajdhani'),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.surface,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Rajdhani',
            fontSize: 16,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.2),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textMuted,
                  size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}