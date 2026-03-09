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
    final List<MapEntry<String, int>> materials = state.materialInventory.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Card(
          child: ListTile(
            title: const Text('Workshop Resources'),
            subtitle: Text('Essence: ${state.essence} / ArcaneDust: (준비중)'),
          ),
        ),
        const SizedBox(height: 8),
        WorkshopQueueCard(
          queue: state.queue,
          onEnqueue: () => ref.read(gameControllerProvider.notifier).enqueuePotion(potions.first.id, 3),
          onTick: () => ref.read(gameControllerProvider.notifier).tickCraftQueue(),
        ),
        const SizedBox(height: 8),
        WorkshopMaterialCard(materials: materials),
        const SizedBox(height: 8),
        WorkshopCraftedPotionCard(
          stacks: state.craftedPotionStacks,
          details: state.craftedPotionDetails,
        ),
        const SizedBox(height: 8),
        WorkshopLogCard(logs: state.logs),
      ],
    );
  }
}
