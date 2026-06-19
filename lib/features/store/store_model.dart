enum StoreItemType { booster, theme, frame }

class StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final StoreItemType type;
  final String icon;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.icon,
  });
}

final List<StoreItem> storeItems = [
  StoreItem(
    id: 'extra_time_5',
    name: '+5 Seconds',
    description: 'Extra time per question for 1 game',
    price: 50,
    type: StoreItemType.booster,
    icon: 'timer',
  ),
  StoreItem(
    id: 'skip_question',
    name: 'Skip Token',
    description: 'Skip a hard question without losing streak',
    price: 75,
    type: StoreItemType.booster,
    icon: 'skip',
  ),
  StoreItem(
    id: 'double_points',
    name: '2x Points',
    description: 'Double points for 1 game',
    price: 100,
    type: StoreItemType.booster,
    icon: 'double',
  ),
  StoreItem(
    id: 'frame_gold',
    name: 'Gold Frame',
    description: 'Golden avatar border',
    price: 200,
    type: StoreItemType.frame,
    icon: 'frame',
  ),
  StoreItem(
    id: 'frame_neon',
    name: 'Neon Frame',
    description: 'Glowing neon avatar border',
    price: 250,
    type: StoreItemType.frame,
    icon: 'frame',
  ),
  StoreItem(
    id: 'streak_shield',
    name: 'Streak Shield',
    description: 'Protects your streak from 1 wrong answer',
    price: 150,
    type: StoreItemType.booster,
    icon: 'shield',
  ),
];

class CoinPack {
  final String id;
  final int coins;
  final String label;
  final bool bestValue;

  const CoinPack({
    required this.id,
    required this.coins,
    required this.label,
    this.bestValue = false,
  });
}

final List<CoinPack> coinPacks = [
  CoinPack(id: 'pack_100', coins: 100, label: 'Starter'),
  CoinPack(id: 'pack_500', coins: 500, label: 'Popular', bestValue: true),
  CoinPack(id: 'pack_1000', coins: 1000, label: 'Value'),
  CoinPack(id: 'pack_2500', coins: 2500, label: 'Mega'),
];