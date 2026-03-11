import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/application/workshop_providers.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopScreen extends ConsumerWidget {
  const WorkshopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int essence = ref.watch(workshopEssenceProvider);
    final List<CraftQueueJob> queue = ref.watch(craftQueueProvider);
    final List<MapEntry<String, int>> materials = ref.watch(
      sortedMaterialInventoryProvider,
    );
    final Map<String, int> craftedPotionStacks = ref.watch(
      craftedPotionStacksProvider,
    );
    final List<String> logs = ref.watch(recentLogsProvider);
    final int materialTotalCount = materials.fold<int>(
      0,
      (int total, MapEntry<String, int> entry) => total + entry.value,
    );

    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Card(
          child: ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Workshop Resources'),
            subtitle: Text('Essence: $essence / ArcaneDust: (준비중)'),
          ),
        ),
        const SizedBox(height: 8),
        WorkshopQueueCard(jobCount: queue.length),
        const SizedBox(height: 8),
        WorkshopMaterialCard(
          materialTypeCount: materials.length,
          totalCount: materialTotalCount,
        ),
        const SizedBox(height: 8),
        WorkshopCraftedPotionCard(stackCount: craftedPotionStacks.length),
        const SizedBox(height: 8),
        WorkshopLogCard(logCount: logs.length),
      ],
    );
  }
}
