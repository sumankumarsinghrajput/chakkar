class FriendUser {
  final String uid;
  final String username;
  final String avatarId;
  final int level;
  final int wins;

  const FriendUser({
    required this.uid,
    required this.username,
    required this.avatarId,
    required this.level,
    required this.wins,
  });

  factory FriendUser.fromMap(Map<String, dynamic> map, String uid) {
    return FriendUser(
      uid: uid,
      username: map['displayUsername'] ?? '',
      avatarId: map['avatarId'] ?? '',
      level: map['level'] ?? 1,
      wins: map['wins'] ?? 0,
    );
  }
}

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequest {
  final String id;
  final String fromUid;
  final String fromUsername;
  final String fromAvatarId;
  final FriendRequestStatus status;

  const FriendRequest({
    required this.id,
    required this.fromUid,
    required this.fromUsername,
    required this.fromAvatarId,
    required this.status,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> map, String id) {
    return FriendRequest(
      id: id,
      fromUid: map['fromUid'] ?? '',
      fromUsername: map['fromUsername'] ?? '',
      fromAvatarId: map['fromAvatarId'] ?? '',
      status: FriendRequestStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
    );
  }
}