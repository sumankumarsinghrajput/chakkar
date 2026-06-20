import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal() {
    _loadSettings();
  }

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;
  bool _memeEnabled = true;
  String _audioTier = 'standard'; // 'standard' or 'mild'

  bool get soundEnabled => _soundEnabled;
  bool get memeEnabled => _memeEnabled;
  String get audioTier => _audioTier;

  void setAudioTier(String tier) {
    _audioTier = tier;
    try {
      Hive.box('chakkar_prefs').put('audio_tier', tier);
    } catch (e) {
      // ignore
    }
  }

  void _loadSettings() {
    try {
      final box = Hive.box('chakkar_prefs');
      _soundEnabled = box.get('sound_enabled', defaultValue: true);
      _audioTier = box.get('audio_tier', defaultValue: 'standard');
    } catch (e) {
      _soundEnabled = true;
      _audioTier = 'standard';
    }
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    try {
      Hive.box('chakkar_prefs').put('sound_enabled', _soundEnabled);
    } catch (e) {
      // box not ready, ignore
    }
  }

  void toggleMeme() => _memeEnabled = !_memeEnabled;

  String? _lastPlayed;

  final Map<String, List<String>> _sounds = {
    'correct': [
      'assets/audio/correct/anime-wow-sound-effect.mp3',
      'assets/audio/correct/baat-to-sahi-hai.mp3',
      'assets/audio/correct/anime-ahh.mp3',
      'assets/audio/correct/shabash-beta.mp3',
    ],
    'correct_rare': [
      'assets/audio/correct/matlab-wo-alag-hi-level-ka-banda-tha.mp3',
    ],
    'wrong': [
      'assets/audio/wrong/aayein-meme.mp3',
      'assets/audio/wrong/abe-sale.mp3',
      'assets/audio/wrong/baigan.mp3',
      'assets/audio/wrong/america-kya-kehta-tha.mp3',
      'assets/audio/wrong/asambhav-carry-minati.mp3',
      'assets/audio/wrong/error_CDOxCYm.mp3',
      'assets/audio/wrong/indian-sorry.mp3',
      'assets/audio/wrong/kya-re-bhik-mangya-deepak-kalal.mp3',
      'assets/audio/wrong/lekin-ye-sala.mp3',
      'assets/audio/wrong/emotional-damage-meme.mp3',
      'assets/audio/wrong/baby-laughing-meme.mp3',
    ],
    'win': [
      'assets/audio/win/abhi-maza-ayagga.mp3',
      'assets/audio/win/kids-saying-yay-sound-effect_3.mp3',
      'assets/audio/win/ooo-hahah.mp3',
    ],
    'win_epic': ['assets/audio/win/galaxy-meme.mp3'],
    'lose': [
      'assets/audio/lose/africa-crying-laugh-commercial.mp3',
      'assets/audio/lose/aisa-mat-karo-meri-jaan.mp3',
      'assets/audio/lose/ale-le-le.mp3',
      'assets/audio/lose/awkward-cricket-sound-effect.mp3',
      'assets/audio/lose/saari-umar-main-joker.mp3',
      'assets/audio/lose/sad-meow-song.mp3',
      'assets/audio/lose/oh-no-no-no-no-laugh.mp3',
    ],
    'lose_rare': ['assets/audio/lose/oh-no-no-no-no-laugh.mp3'],
    'ui': [
      'assets/audio/ui/aji-mangal.mp3',
      'assets/audio/ui/chalo.mp3',
      'assets/audio/ui/comedy_sms_tonewapspell.mp3',
      'assets/audio/ui/mac-quack.mp3',
    ],
    'countdown': [
      'assets/audio/countdown/dun-dun-dun-sound-effect-brass_8nFBccR.mp3',
      'assets/audio/countdown/shocked-sound-effect.mp3',
      'assets/audio/countdown/nahi-nahi-saluke-yaha-kuchh-to-gadbad-hai.mp3',
    ],
    'multiplayer': [
      'assets/audio/multiplayer/among-us-role-reveal-sound.mp3',
      'assets/audio/multiplayer/rom-rom-bhaiyo.mp3',
    ],
    'hacker': ['assets/audio/multiplayer/hacker-hai-bhai-hacker-ajjubhai.mp3'],
    'slap': [
      'assets/audio/slaps/slap-sound-effect-funny-memes.mp3',
      'assets/audio/slaps/punch-gaming-sound-effect-hd_RzlG1GE.mp3',
      'assets/audio/slaps/bone-crack.mp3',
    ],
    'reactions': [
      'assets/audio/reactions/cat-laugh-meme-1.mp3',
      'assets/audio/reactions/chicken-on-tree-screaming.mp3',
      'assets/audio/reactions/faaah.mp3',
      'assets/audio/reactions/funny_82hiegE.mp3',
      'assets/audio/reactions/ghachar-ghachar.mp3',
      'assets/audio/reactions/gopgopgop.mp3',
      'assets/audio/reactions/ki-kore.mp3',
      'assets/audio/reactions/rizzbot-laugh.mp3',
    ],
    'easter_egg': [
      'assets/audio/win/galaxy-meme.mp3',
      'assets/audio/multiplayer/hacker-hai-bhai-hacker-ajjubhai.mp3',
      'assets/audio/correct/matlab-wo-alag-hi-level-ka-banda-tha.mp3',
    ],
  };

  // Public methods
  Future<void> playCorrect({bool isStreak = false}) async {
    if (isStreak) {
      await _playRandom('correct_rare');
    } else {
      await _playRandom('correct');
    }
  }

  Future<void> playWrong({bool isHeavy = false}) async {
    if (isHeavy) {
      await _playRandom('slap');
    } else {
      await _playRandom('wrong');
    }
  }

  Future<void> playWin({bool isEpic = false}) async {
    if (isEpic) {
      await _playRandom('win_epic');
    } else {
      await _playRandom('win');
    }
  }

  Future<void> playLose({bool isRare = false}) async {
    if (isRare) {
      await _playRandom('lose_rare');
    } else {
      await _playRandom('lose');
    }
  }

  Future<void> playCountdown() async => _playRandom('countdown');

  Future<void> playTap() async => _playSound('assets/audio/ui/aji-mangal.mp3');

  Future<void> playNotification() async =>
      _playSound('assets/audio/ui/comedy_sms_tonewapspell.mp3');

  Future<void> playPlayerJoined() async =>
      _playSound('assets/audio/multiplayer/among-us-role-reveal-sound.mp3');

  Future<void> playHostAccept() async =>
      _playSound('assets/audio/win/kids-saying-yay-sound-effect_3.mp3');

  Future<void> playHostReject() async =>
      _playSound('assets/audio/wrong/emotional-damage-meme.mp3');

  Future<void> playRandomReaction() async {
    // 10% chance
    final random = Random();
    if (random.nextInt(10) == 0) {
      await _playRandom('reactions');
    }
  }

  Future<void> playEasterEgg() async {
    // 2% chance
    final random = Random();
    if (random.nextInt(50) == 0) {
      await _playRandom('easter_egg');
    }
  }

  Future<void> _playRandom(String category) async {
    print(
      'AUDIO DEBUG: tier=$_audioTier soundEnabled=$_soundEnabled category=$category',
    );
    if (!_soundEnabled) return;
    final sounds = _sounds[category] ?? [];
    if (sounds.isEmpty) return;

    final random = Random();
    List<String> available = sounds.where((s) => s != _lastPlayed).toList();

    if (available.isEmpty) available = sounds;

    var sound = available[random.nextInt(available.length)];

    // If mild tier, try to use audio_mild version of the same file
    if (_audioTier == 'mild') {
      final mildSound = sound.replaceFirst(
        'assets/audio/',
        'assets/audio_mild/',
      );
      sound =
          mildSound; // fallback to standard happens inside _playSound if file missing
      await _playSoundWithFallback(
        mildSound,
        sound.replaceFirst('assets/audio_mild/', 'assets/audio/'),
      );
      return;
    }

    await _playSound(sound);
  }

  Future<void> _playSoundWithFallback(
    String preferredPath,
    String fallbackPath,
  ) async {
    if (!_soundEnabled) return;
    try {
      await _player.stop();
      final player = AudioPlayer();
      await player.play(AssetSource(preferredPath.replaceFirst('assets/', '')));
      _lastPlayed = preferredPath;
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      // Mild version doesn't exist yet, fallback to standard
      await _playSound(fallbackPath);
    }
  }

  Future<void> _playSound(String path) async {
    if (!_soundEnabled) return;
    try {
      final player = AudioPlayer();
      await player.play(AssetSource(path.replaceFirst('assets/', '')));
      _lastPlayed = path;
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      print('Audio error: $e — $path');
    }
  }

  Future<void> stopAll() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}

final audioManager = AudioManager();
