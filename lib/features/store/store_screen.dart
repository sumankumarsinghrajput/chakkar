import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../profile/profile_provider.dart';
import 'store_model.dart';
import 'store_provider.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedAsync = ref.watch(ownedItemsProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('STORE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          profileAsync.when(
            data: (user) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Color(0xFFF59E0B),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user?.coins ?? 0}',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontFamily: 'Rajdhani',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: ownedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (inventory) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'COIN PACKS',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: coinPacks.length,
                itemBuilder: (context, index) {
                  final pack = coinPacks[index];
                  return _CoinPackCard(pack: pack, ref: ref);
                },
              ),
              const SizedBox(height: 24),
              Text(
                'BOOSTERS & ITEMS',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              ...storeItems.map(
                (item) => _StoreItemCard(
                  item: item,
                  quantity: inventory[item.id] ?? 0,
                  ref: ref,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CoinPackCard extends StatelessWidget {
  final CoinPack pack;
  final WidgetRef ref;

  const _CoinPackCard({required this.pack, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF78350F), Color(0xFFB45309)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: pack.bestValue
            ? Border.all(color: const Color(0xFFFFD700), width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 18,
            child: pack.bestValue
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontFamily: 'Rajdhani',
                      ),
                    ),
                  )
                : null,
          ),
          const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 26),
          Text(
            '${pack.coins}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          Text(
            pack.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'SOON',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final StoreItem item;
  final int quantity;
  final WidgetRef ref;

  const _StoreItemCard({
    required this.item,
    required this.quantity,
    required this.ref,
  });

  IconData get _icon {
    switch (item.icon) {
      case 'timer':
        return Icons.timer;
      case 'skip':
        return Icons.skip_next;
      case 'double':
        return Icons.looks_two;
      case 'frame':
        return Icons.crop_square;
      case 'shield':
        return Icons.shield;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
            ),
            child: Icon(_icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (quantity > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'x$quantity',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontFamily: 'Rajdhani',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final success = await ref
                  .read(storeNotifierProvider.notifier)
                  .purchaseItem(item.id, item.price);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? '${item.name} purchased!' : 'Not enough coins!',
                    ),
                    backgroundColor: success
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.price}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
