import 'package:alchemist_hunter/features/game/domain/models.dart';
import 'package:alchemist_hunter/features/game/providers/game_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeaponsScreen extends ConsumerWidget {
  const WeaponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState state = ref.watch(gameControllerProvider);
    final List<MaterialEntity> materials = ref.watch(materialsProvider);
    final List<PotionBlueprint> potions = ref.watch(potionsProvider);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Card(
          child: ListTile(
            title: const Text('Economy'),
            subtitle: Text('Gold: ${state.gold} / Diamonds: ${state.diamonds}'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('General Shop', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...state.generalShop.items.take(4).map(
                  (ShopItem item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${item.name} (${item.quantity})'),
                    subtitle: Text('Price: ${item.price}'),
                    trailing: FilledButton.tonal(
                      onPressed: () {
                        ref
                            .read(gameControllerProvider.notifier)
                            .buyGeneralMaterial(item.materialId, 1);
                      },
                      child: const Text('Buy 1'),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    FilledButton.tonal(
                      onPressed: () {
                        ref.read(gameControllerProvider.notifier).forceRefresh(ShopType.general);
                      },
                      child: Text('Refresh (${state.generalShop.forcedRefreshCost})'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Craft Queue', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    FilledButton.tonal(
                      onPressed: () {
                        ref
                            .read(gameControllerProvider.notifier)
                            .enqueuePotion(potions.first.id, 3);
                      },
                      child: const Text('Enqueue x3'),
                    ),
                    FilledButton(
                      onPressed: () {
                        ref.read(gameControllerProvider.notifier).tickCraftQueue();
                      },
                      child: const Text('Process Tick'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.queue.isEmpty)
                  const Text('Queue is empty')
                else
                  ...state.queue.take(5).map(
                    (CraftQueueJob job) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('${job.potionId} ${job.currentRepeat}/${job.repeatCount}'),
                      subtitle: Text(
                        'status: ${job.status.name}, retries: ${job.retryCount}, eta: ${job.eta.inSeconds}s',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Inventory Snapshot', style: TextStyle(fontWeight: FontWeight.w700)),
                Text('Materials: ${materials.length} / Potions: ${potions.length}'),
                const SizedBox(height: 4),
                Text('Owned entries: ${state.inventory.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Logs', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...state.logs.take(8).map((String e) => Text('• $e')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
