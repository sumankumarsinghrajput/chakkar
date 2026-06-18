enum AchievementCategory { beginner, champion, social, special }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int rewardCoins;
  final AchievementCategory category;
  final int requiredCount;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rewardCoins,
    required this.category,
    required this.requiredCount,
  });
}

// All achievements
final List<Achievement> allAchievements = [
  Achievement(
    id: 'first_win',
    title: 'First Win',
    description: 'Win your first match',
    icon: 'trophy',
    rewardCoins: 50,
    category: AchievementCategory.beginner,
    requiredCount: 1,
  ),
  Achievement(
    id: 'brain_master',
    title: 'Brain Master',
    description: 'Win 10 matches',
    icon: 'brain',
    rewardCoins: 200,
    category: AchievementCategory.champion,
    requiredCount: 10,
  ),
  Achievement(
    id: 'perfect_score',
    title: 'Perfect Score',
    description: 'Score 500 in a single match',
    icon: 'star',
    rewardCoins: 100,
    category: AchievementCategory.champion,
    requiredCount: 1,
  ),
  Achievement(
    id: 'room_creator',
    title: 'Room Creator',
    description: 'Create 3 rooms',
    icon: 'room',
    rewardCoins: 75,
    category: AchievementCategory.social,
    requiredCount: 3,
  ),
  Achievement(
    id: 'invite_master',
    title: 'Invite Master',
    description: 'Invite 10 players',
    icon: 'invite',
    rewardCoins: 150,
    category: AchievementCategory.social,
    requiredCount: 10,
  ),
  Achievement(
    id: 'lucky_guesser',
    title: 'Lucky Guesser',
    description: 'Win a match with 1 correct answer',
    icon: 'lucky',
    rewardCoins: 50,
    category: AchievementCategory.special,
    requiredCount: 1,
  ),
  Achievement(
    id: 'certified_confused',
    title: 'Certified Confused',
    description: 'Get 5 wrong answers in a row',
    icon: 'confused',
    rewardCoins: 25,
    category: AchievementCategory.special,
    requiredCount: 5,
  ),
  Achievement(
    id: 'brain_restart',
    title: 'Brain Restart Required',
    description: 'Score 0 in a match',
    icon: 'restart',
    rewardCoins: 10,
    category: AchievementCategory.special,
    requiredCount: 1,
  ),
  Achievement(
    id: 'speed_demon',
    title: 'Speed Demon',
    description: 'Answer 5 questions in under 3 seconds each',
    icon: 'speed',
    rewardCoins: 200,
    category: AchievementCategory.champion,
    requiredCount: 5,
  ),
  Achievement(
    id: 'veteran',
    title: 'Veteran',
    description: 'Play 50 matches',
    icon: 'veteran',
    rewardCoins: 500,
    category: AchievementCategory.champion,
    requiredCount: 50,
  ),
];