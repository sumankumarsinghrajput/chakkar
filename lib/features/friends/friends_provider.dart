import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'friends_model.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

// Search users by username prefix
final userSearchProvider =
    StateNotifierProvider<UserSearchNotifier, AsyncValue<List<FriendUser>>>(
        (ref) => UserSearchNotifier());

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
      final friendDoc = await _firestore.collection('users').doc(doc.id).get();
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
      .map((snapshot) =>
          snapshot.docs.map((doc) => FriendRequest.fromMap(doc.data(), doc.id)).toList());
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
}

final friendsNotifierProvider =
    StateNotifierProvider<FriendsNotifier, bool>((ref) => FriendsNotifier());