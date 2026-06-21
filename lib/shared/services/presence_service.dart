import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final _db = FirebaseDatabase.instance;
  bool _started = false;

  void start() {
    if (_started) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _started = true;

    final myStatusRef = _db.ref('presence/${user.uid}');
    final connectedRef = _db.ref('.info/connected');

    connectedRef.onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      if (!connected) return;

      // When this device disconnects, automatically set status to offline
      myStatusRef.onDisconnect().set({
        'state': 'offline',
        'lastChanged': ServerValue.timestamp,
        'inGame': false,
      }).then((_) {
        // Then set ourselves online
        myStatusRef.set({
          'state': 'online',
          'lastChanged': ServerValue.timestamp,
          'inGame': false,
        });
      });
    });
  }

  Future<void> setInGame(bool inGame) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db.ref('presence/${user.uid}').update({'inGame': inGame});
  }

  Future<void> goOffline() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db.ref('presence/${user.uid}').set({
      'state': 'offline',
      'lastChanged': ServerValue.timestamp,
      'inGame': false,
    });
  }

  void stop() {
    _started = false;
  }
}

final presenceService = PresenceService();