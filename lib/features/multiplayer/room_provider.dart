import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'room_model.dart';

final firestore = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

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

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data()!;

      final roomCode = customCode ?? generateRoomCode();

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

  Future<String?> createRoomWithFriends({
    required String roomName,
    required List<String> friendUids,
    required String difficulty,
    String? customCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data()!;

      final roomCode = customCode ?? generateRoomCode();
      final maxPlayers = friendUids.length + 1;

      final hostPlayer = {
        'uid': user.uid,
        'username': userData['displayUsername'],
        'avatarId': userData['avatarId'],
        'level': userData['level'],
        'isReady': true,
        'isHost': true,
      };

      // Build players map with host + all selected friends auto-added
      final playersMap = <String, dynamic>{user.uid: hostPlayer};

      for (final friendUid in friendUids) {
        // Re-check live presence right before adding — prevents race conditions
        final presenceSnap = await FirebaseDatabase.instance
            .ref('presence/$friendUid')
            .get();
        final presenceData = presenceSnap.value as Map?;
        final isOnline = presenceData?['state'] == 'online';
        final inGame = presenceData?['inGame'] == true;
        if (!isOnline || inGame) continue; // skip busy/offline friends

        final friendDoc = await firestore
            .collection('users')
            .doc(friendUid)
            .get();
        final friendData = friendDoc.data();
        if (friendData == null) continue;
        playersMap[friendUid] = {
          'uid': friendUid,
          'username': friendData['displayUsername'],
          'avatarId': friendData['avatarId'],
          'level': friendData['level'],
          'isReady': false,
          'isHost': false,
        };
      }

      final roomRef = firestore.collection('rooms').doc();

      await roomRef.set({
        'roomName': roomName,
        'roomCode': roomCode,
        'hostId': user.uid,
        'maxPlayers': maxPlayers,
        'difficulty': difficulty,
        'isPublic': false,
        'status': 'waiting',
        'players': playersMap,
        'pendingRequests': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send room invite notifications to each friend
      for (final friendUid in friendUids) {
        await firestore
            .collection('users')
            .doc(friendUid)
            .collection('roomInvites')
            .add({
              'fromUid': user.uid,
              'fromUsername': userData['displayUsername'],
              'roomId': roomRef.id,
              'roomCode': roomCode,
              'roomName': roomName,
              'autoJoined': true,
              'sentAt': FieldValue.serverTimestamp(),
            });
      }

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

  Future<void> startGame(String roomId) async {
    await firestore.collection('rooms').doc(roomId).update({
      'status': 'playing',
    });
  }

  Future<void> leaveRoom(String roomId) async {
    final user = auth.currentUser;
    if (user == null) return;

    final room = await firestore.collection('rooms').doc(roomId).get();
    final data = room.data();
    if (data == null) return;

    if (data['hostId'] == user.uid) {
      await firestore.collection('rooms').doc(roomId).delete();
    } else {
      await firestore.collection('rooms').doc(roomId).update({
        'players.${user.uid}': FieldValue.delete(),
      });
    }
  }

  Future<void> transferHostIfNeeded(String roomId, String leavingUid) async {
    final roomDoc = await firestore.collection('rooms').doc(roomId).get();
    final data = roomDoc.data();
    if (data == null) return;

    final playersMap = data['players'] as Map<String, dynamic>? ?? {};
    final playerIds = playersMap.keys.toList();
    playerIds.remove(leavingUid);

    if (playerIds.isEmpty) {
      await firestore.collection('rooms').doc(roomId).delete();
      return;
    }

    if (data['hostId'] == leavingUid) {
      final newHostId = playerIds.first;
      await firestore.collection('rooms').doc(roomId).update({
        'hostId': newHostId,
        'players.$newHostId.isHost': true,
        'players.$leavingUid': FieldValue.delete(),
      });
    } else {
      await firestore.collection('rooms').doc(roomId).update({
        'players.$leavingUid': FieldValue.delete(),
      });
    }
  }

  Future<void> handlePlayerLeavesDuringGame(
    String roomId,
    String leavingUid,
  ) async {
    final roomDoc = await firestore.collection('rooms').doc(roomId).get();
    final data = roomDoc.data();
    if (data == null) return;

    final playersMap = data['players'] as Map<String, dynamic>? ?? {};
    final remainingCount = playersMap.length - 1;

    if (remainingCount < 2) {
      await firestore.collection('rooms').doc(roomId).update({
        'status': 'finished',
        'players.$leavingUid': FieldValue.delete(),
      });
      await FirebaseDatabase.instance.ref('games/$roomId').update({
        'isFinished': true,
      });
    } else {
      await firestore.collection('rooms').doc(roomId).update({
        'players.$leavingUid': FieldValue.delete(),
      });
    }
  }
}

final roomProvider =
    StateNotifierProvider<RoomNotifier, AsyncValue<RoomModel?>>((ref) {
      return RoomNotifier();
    });

final roomStreamProvider = StreamProvider.family<RoomModel?, String>((
  ref,
  roomId,
) {
  return firestore.collection('rooms').doc(roomId).snapshots().map((doc) {
    if (!doc.exists) return null;
    return RoomModel.fromMap(doc.data()!, doc.id);
  });
});

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
