class RoomPlayer {
  final String uid;
  final String username;
  final String avatarId;
  final int level;
  final bool isReady;
  final bool isHost;

  const RoomPlayer({
    required this.uid,
    required this.username,
    required this.avatarId,
    required this.level,
    this.isReady = false,
    this.isHost = false,
  });

  factory RoomPlayer.fromMap(Map<String, dynamic> map) {
    return RoomPlayer(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      avatarId: map['avatarId'] ?? '',
      level: map['level'] ?? 1,
      isReady: map['isReady'] ?? false,
      isHost: map['isHost'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'avatarId': avatarId,
      'level': level,
      'isReady': isReady,
      'isHost': isHost,
    };
  }
}

enum RoomStatus { waiting, starting, playing, finished }

class RoomModel {
  final String roomId;
  final String roomName;
  final String roomCode;
  final String hostId;
  final int maxPlayers;
  final String difficulty;
  final bool isPublic;
  final RoomStatus status;
  final List<RoomPlayer> players;
  final List<String> pendingRequests;

  const RoomModel({
    required this.roomId,
    required this.roomName,
    required this.roomCode,
    required this.hostId,
    required this.maxPlayers,
    required this.difficulty,
    required this.isPublic,
    required this.status,
    required this.players,
    required this.pendingRequests,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    final playersMap = map['players'] as Map<String, dynamic>? ?? {};
    final players = playersMap.values
        .map((p) => RoomPlayer.fromMap(p as Map<String, dynamic>))
        .toList();

    return RoomModel(
      roomId: id,
      roomName: map['roomName'] ?? '',
      roomCode: map['roomCode'] ?? '',
      hostId: map['hostId'] ?? '',
      maxPlayers: map['maxPlayers'] ?? 4,
      difficulty: map['difficulty'] ?? 'easy',
      isPublic: map['isPublic'] ?? true,
      status: RoomStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RoomStatus.waiting,
      ),
      players: players,
      pendingRequests: List<String>.from(map['pendingRequests'] ?? []),
    );
  }

  bool get isFull => players.length >= maxPlayers;
  int get playerCount => players.length;
}