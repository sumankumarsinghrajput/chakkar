import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'friends_model.dart';
import 'package:firebase_database/firebase_database.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

// Search users by username prefix
final userSearchProvider =
    StateNotifierProvider<UserSearchNotifier, AsyncValue<List<FriendUser>>>(
      (ref) => UserSearchNotifier(),
    );

class UserSearchNotifier extends StateNotifier<AsyncValue<List<FriendUser>>> {
  UserSearchNotifier() : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final lowerQuery = query.trim().toLowerCase();
      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: lowerQuery)
          .where('username', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
          .limit(20)
          .get();

      final currentUid = _auth.currentUser?.uid;
      final results = snapshot.docs
          .where((doc) => doc.id != currentUid)
          .map((doc) => FriendUser.fromMap(doc.data(), doc.id))
          .toList();

      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Friends list
final friendsListProvider = StreamProvider<List<FriendUser>>((ref) {
  final user = _auth.currentUser;
  if (user == null) return Stream.value([]);

  return _firestore
      .collection('users')
      .doc(user.uid)
      .collection('friends')
      .snapshots()
      .asyncMap((snapshot) async {
        final friends = <FriendUser>[];
        for (final doc in snapshot.docs) {
          final friendDoc = await _firestore
              .collection('users')
              .doc(doc.id)
              .get();
          if (friendDoc.exists) {
            friends.add(FriendUser.fromMap(friendDoc.data()!, doc.id));
          }
        }
        return friends;
      });
});

// Incoming friend requests
final friendRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final user = _auth.currentUser;
  if (user == null) return Stream.value([]);

  return _firestore
      .collection('users')
      .doc(user.uid)
      .collection('friendRequests')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => FriendRequest.fromMap(doc.data(), doc.id))
            .toList(),
      );
});

class FriendsNotifier extends StateNotifier<bool> {
  FriendsNotifier() : super(false);

  Future<void> sendFriendRequest(String targetUid) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final myDoc = await _firestore.collection('users').doc(user.uid).get();
    final myData = myDoc.data();
    if (myData == null) return;

    await _firestore
        .collection('users')
        .doc(targetUid)
        .collection('friendRequests')
        .doc(user.uid)
        .set({
          'fromUid': user.uid,
          'fromUsername': myData['displayUsername'],
          'fromAvatarId': myData['avatarId'],
          'status': 'pending',
          'sentAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> acceptFriendRequest(String fromUid) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Add each other as friends
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(fromUid)
        .set({'addedAt': FieldValue.serverTimestamp()});

    await _firestore
        .collection('users')
        .doc(fromUid)
        .collection('friends')
        .doc(user.uid)
        .set({'addedAt': FieldValue.serverTimestamp()});

    // Remove the request
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friendRequests')
        .doc(fromUid)
        .delete();
  }

  Future<void> rejectFriendRequest(String fromUid) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friendRequests')
        .doc(fromUid)
        .delete();
  }

  Future<void> removeFriend(String friendUid) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(friendUid)
        .delete();

    await _firestore
        .collection('users')
        .doc(friendUid)
        .collection('friends')
        .doc(user.uid)
        .delete();
  }

  Future<void> inviteToRoom(
    String friendUid,
    String roomId,
    String roomCode,
    String roomName,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final myDoc = await _firestore.collection('users').doc(user.uid).get();
    final myName = myDoc.data()?['displayUsername'] ?? 'A friend';

    await _firestore
        .collection('users')
        .doc(friendUid)
        .collection('roomInvites')
        .add({
          'fromUid': user.uid,
          'fromUsername': myName,
          'roomId': roomId,
          'roomCode': roomCode,
          'roomName': roomName,
          'sentAt': FieldValue.serverTimestamp(),
        });
  }
}

final friendsNotifierProvider = StateNotifierProvider<FriendsNotifier, bool>(
  (ref) => FriendsNotifier(),
);

class RoomInvite {
  final String id;
  final String fromUsername;
  final String roomId;
  final String roomCode;
  final String roomName;

  const RoomInvite({
    required this.id,
    required this.fromUsername,
    required this.roomId,
    required this.roomCode,
    required this.roomName,
  });

  factory RoomInvite.fromMap(Map<String, dynamic> map, String id) {
    return RoomInvite(
      id: id,
      fromUsername: map['fromUsername'] ?? '',
      roomId: map['roomId'] ?? '',
      roomCode: map['roomCode'] ?? '',
      roomName: map['roomName'] ?? '',
    );
  }
}

final roomInvitesProvider = StreamProvider<List<RoomInvite>>((ref) {
  final user = _auth.currentUser;
  if (user == null) return Stream.value([]);

  return _firestore
      .collection('users')
      .doc(user.uid)
      .collection('roomInvites')
      .orderBy('sentAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => RoomInvite.fromMap(doc.data(), doc.id))
            .toList(),
      );
});

Future<void> dismissRoomInvite(String inviteId) async {
  final user = _auth.currentUser;
  if (user == null) return;
  await _firestore
      .collection('users')
      .doc(user.uid)
      .collection('roomInvites')
      .doc(inviteId)
      .delete();
}

class PresenceInfo {
  final bool isOnline;
  final bool inGame;
  const PresenceInfo({required this.isOnline, required this.inGame});
}

final friendPresenceProvider = StreamProvider.family<PresenceInfo, String>((ref, uid) {
  final db = FirebaseDatabase.instance;
  return db.ref('presence/$uid').onValue.map((event) {
    final data = event.snapshot.value as Map?;
    if (data == null) return const PresenceInfo(isOnline: false, inGame: false);
    return PresenceInfo(
      isOnline: data['state'] == 'online',
      inGame: data['inGame'] == true,
    );
  });
});