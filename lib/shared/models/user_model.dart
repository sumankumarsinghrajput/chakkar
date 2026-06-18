class UserModel {
  final String uid;
  final String username;
  final String displayUsername;
  final String gender;
  final String avatarId;
  final int xp;
  final int level;
  final int coins;
  final int wins;
  final int losses;

  const UserModel({
    required this.uid,
    required this.username,
    required this.displayUsername,
    required this.gender,
    required this.avatarId,
    required this.xp,
    required this.level,
    required this.coins,
    required this.wins,
    required this.losses,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      displayUsername: map['displayUsername'] ?? '',
      gender: map['gender'] ?? '',
      avatarId: map['avatarId'] ?? '',
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      coins: map['coins'] ?? 0,
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
    );
  }

  double get winRate {
    final total = wins + losses;
    if (total == 0) return 0;
    return (wins / total) * 100;
  }

  int get xpForNextLevel => level * 1000;
  double get xpProgress => xp / xpForNextLevel;
}