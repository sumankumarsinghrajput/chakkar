import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'room_model.dart';

final firestore = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

// Generate room code
String generateRoomCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  final code = List.generate(
    3,
    (_) => chars[random.nextInt(chars.length)],
  ).join();
  final nums = List.generate(4, (_) => random.nextInt(10).toString()).join();
  return '$code-$nums';
}

class RoomNotifier extends StateNotifier<AsyncValue<RoomModel?>> {
  RoomNotifier() : super(const AsyncValue.data(null));

  Future<String?> createRoom({
    required String roomName,
    required int maxPlayers,
    required String difficulty,
    required bool isPublic,
    String? customCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      // Get user profile
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data()!;

      final roomCode = customCode ?? generateRoomCode();

      // Check code not taken
      final existing = await firestore
          .collection('rooms')
          .where('roomCode', isEqualTo: roomCode)
          .where('status', isEqualTo: 'waiting')
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Room code already in use');
      }

      final roomRef = firestore.collection('rooms').doc();

      final hostPlayer = {
        'uid': user.uid,
        'username': userData['displayUsername'],
        'avatarId': userData['avatarId'],
        'level': userData['level'],
        'isReady': true,
        'isHost': true,
      };

      await roomRef.set({
        'roomName': roomName,
        'roomCode': roomCode,
        'hostId': user.uid,
        'maxPlayers': maxPlayers,
        'difficulty': difficulty,
        'isPublic': isPublic,
        'status': 'waiting',
        'players': {user.uid: hostPlayer},
        'pendingRequests': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
      return roomRef.id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<String?> findRoomByCode(String code) async {
    try {
      final query = await firestore
          .collection('rooms')
          .where('roomCode', isEqualTo: code.toUpperCase())
          .where('status', isEqualTo: 'waiting')
          .get();

      if (query.docs.isEmpty) return null;
      return query.docs.first.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> requestJoin(String roomId) async {
    try {
      final user = auth.currentUser;
      if (user == null) return false;

      await firestore.collection('rooms').doc(roomId).update({
        'pendingRequests': FieldValue.arrayUnion([user.uid]),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> approvePlayer(String roomId, String playerId) async {
    try {
      final playerDoc = await firestore.collection('users').doc(playerId).get();
      final playerData = playerDoc.data()!;

      final playerMap = {
        'uid': playerId,
        'username': playerData['displayUsername'],
        'avatarId': playerData['avatarId'],
        'level': playerData['level'],
        'isReady': false,
        'isHost': false,
      };

      await firestore.collection('rooms').doc(roomId).update({
        'players.$playerId': playerMap,
        'pendingRequests': FieldValue.arrayRemove([playerId]),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectPlayer(String roomId, String playerId) async {
    await firestore.collection('rooms').doc(roomId).update({
      'pendingRequests': FieldValue.arrayRemove([playerId]),
    });
  }

  Future<void> leaveRoom(String roomId) async {
    final user = auth.currentUser;
    if (user == null) return;

    final room = await firestore.collection('rooms').doc(roomId).get();
    final data = room.data();
    if (data == null) return;

    // If host leaves, delete entire room
    if (data['hostId'] == user.uid) {
      await firestore.collection('rooms').doc(roomId).delete();
    } else {
      await firestore.collection('rooms').doc(roomId).update({
        'players.${user.uid}': FieldValue.delete(),
      });
    }
  }
}

final roomProvider =
    StateNotifierProvider<RoomNotifier, AsyncValue<RoomModel?>>((ref) {
      return RoomNotifier();
    });

// Stream a single room
final roomStreamProvider = StreamProvider.family<RoomModel?, String>((
  ref,
  roomId,
) {
  return firestore.collection('rooms').doc(roomId).snapshots().map((doc) {
    if (!doc.exists) return null;
    return RoomModel.fromMap(doc.data()!, doc.id);
  });
});

// Stream public rooms
final publicRoomsProvider = StreamProvider<List<RoomModel>>((ref) {
  return firestore
      .collection('rooms')
      .where('isPublic', isEqualTo: true)
      .where('status', isEqualTo: 'waiting')
      .snapshots()
      .map(
        (query) => query.docs
            .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
            .toList(),
      );
});
