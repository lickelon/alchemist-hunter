import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/town/application/game_providers.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopScreen extends ConsumerWidget {
  const WorkshopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState state = ref.watch(gameControllerProvider);
    final List<PotionBlueprint> potions = ref.watch(potionsProvider);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Card(
          child: ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Workshop Resources'),
            subtitle: Text('Essence: ${state.essence} / ArcaneDust: (준비중)'),
          ),
        ),
        const SizedBox(height: 8),
        WorkshopQueueCard(
          getQueue: () => ref.read(gameControllerProvider).queue,
          onEnqueue: () => ref.read(gameControllerProvider.notifier).enqueuePotion(potions.first.id, 3),
          onTick: () => ref.read(gameControllerProvider.notifier).tickCraftQueue(),
        ),
        const SizedBox(height: 8),
        WorkshopMaterialCard(
          getMaterials: () {
            final List<MapEntry<String, int>> latest =
                ref.read(gameControllerProvider).materialInventory.entries.toList();
            latest.sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value));
            return latest;
          },
        ),
        const SizedBox(height: 8),
        WorkshopCraftedPotionCard(
          getStacks: () => ref.read(gameControllerProvider).craftedPotionStacks,
          getDetails: () => ref.read(gameControllerProvider).craftedPotionDetails,
        ),
        const SizedBox(height: 8),
        WorkshopLogCard(getLogs: () => ref.read(gameControllerProvider).logs),
      ],
    );
  }
}
