import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/avatar_widget.dart';
import 'room_model.dart';

class ShareCardScreen extends StatefulWidget {
  final String username;
  final String avatarId;
  final int rank;
  final int score;
  final int totalPlayers;
  final bool isWinner;

  const ShareCardScreen({
    super.key,
    required this.username,
    required this.avatarId,
    required this.rank,
    required this.score,
    required this.totalPlayers,
    required this.isWinner,
  });

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  final ScreenshotController _screenshotController =
      ScreenshotController();
  bool _isSharing = false;

  String get _funnyCaption {
    if (widget.isWinner) {
      final captions = [
        'My brain just destroyed everyone!',
        'Too smart for this game!',
        'Champion of champions!',
        'Brain.exe working perfectly!',
      ];
      return captions[widget.score % captions.length];
    } else {
      final captions = [
        'My brain needs a restart...',
        'I was just warming up!',
        'Next time I will win, I promise!',
        'Brain.exe has stopped working!',
      ];
      return captions[widget.rank % captions.length];
    }
  }

  Future<void> _shareCard() async {
    setState(() => _isSharing = true);
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/chakkar_result.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text:
            'I just played CHAKKAR - The Ultimate Brain Battle! $_funnyCaption\nDownload now!',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
    setState(() => _isSharing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SHARE RESULT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Share Card Preview
            Screenshot(
              controller: _screenshotController,
              child: _ShareCard(
                username: widget.username,
                avatarId: widget.avatarId,
                rank: widget.rank,
                score: widget.score,
                totalPlayers: widget.totalPlayers,
                isWinner: widget.isWinner,
                caption: _funnyCaption,
              ),
            ),
            const Spacer(),
            // Share Buttons
            ElevatedButton.icon(
              onPressed: _isSharing ? null : _shareCard,
              icon: const Icon(Icons.share),
              label: Text(
                  _isSharing ? 'SHARING...' : 'SHARE RESULT'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side:
                    const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CLOSE',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  final String username;
  final String avatarId;
  final int rank;
  final int score;
  final int totalPlayers;
  final bool isWinner;
  final String caption;

  const _ShareCard({
    required this.username,
    required this.avatarId,
    required this.rank,
    required this.score,
    required this.totalPlayers,
    required this.isWinner,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWinner
              ? [
                  const Color(0xFF1A1A1A),
                  const Color(0xFF2D1F00),
                ]
              : [
                  const Color(0xFF1A1A1A),
                  const Color(0xFF1A0D2E),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWinner
              ? AppColors.primary.withOpacity(0.6)
              : AppColors.secondary.withOpacity(0.6),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHAKKAR',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 4,
                    ),
              ),
              Text(
                'MATCH OVER',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(letterSpacing: 2),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Result
          Text(
            isWinner ? 'WINS!' : 'RANK #$rank',
            style:
                Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: isWinner
                          ? AppColors.success
                          : AppColors.primary,
                    ),
          ),
          const SizedBox(height: 16),
          // Avatar
          AvatarWidget(
            avatarId: avatarId,
            size: 80,
            showBorder: true,
          ),
          const SizedBox(height: 12),
          Text(
            username,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$score',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: AppColors.primary),
                    ),
                    Text(
                      'SCORE',
                      style:
                          Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.textMuted.withOpacity(0.3),
                ),
                Column(
                  children: [
                    Text(
                      '#$rank/$totalPlayers',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: AppColors.secondary),
                    ),
                    Text(
                      'RANK',
                      style:
                          Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Caption
          Text(
            caption,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.accent,
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Footer
          Text(
            'Play CHAKKAR - The Ultimate Brain Battle',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}