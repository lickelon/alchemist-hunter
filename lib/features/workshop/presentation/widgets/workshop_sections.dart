import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter/material.dart';

class WorkshopQueueCard extends StatelessWidget {
  const WorkshopQueueCard({
    super.key,
    required this.queue,
    required this.onEnqueue,
    required this.onTick,
  });

  final List<CraftQueueJob> queue;
  final VoidCallback onEnqueue;
  final VoidCallback onTick;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                FilledButton.tonal(onPressed: onEnqueue, child: const Text('Queue Potion x3')),
                FilledButton(onPressed: onTick, child: const Text('Process Tick')),
              ],
            ),
            const SizedBox(height: 8),
            if (queue.isEmpty)
              const Text('Queue is empty')
            else
              ...queue.take(6).map(
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
    );
  }
}

class WorkshopMaterialCard extends StatelessWidget {
  const WorkshopMaterialCard({super.key, required this.materials});

  final List<MapEntry<String, int>> materials;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Items (Stack View)', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (materials.isEmpty)
              const Text('No materials')
            else
              ...materials.take(10).map(
                (MapEntry<String, int> e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.key),
                  trailing: Text('x${e.value}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WorkshopCraftedPotionCard extends StatelessWidget {
  const WorkshopCraftedPotionCard({
    super.key,
    required this.stacks,
    required this.details,
  });

  final Map<String, int> stacks;
  final Map<String, CraftedPotion> details;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Crafted Potions (Tap for Detail)',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (stacks.isEmpty)
              const Text('No crafted potions')
            else
              ...stacks.entries.map((MapEntry<String, int> entry) {
                final CraftedPotion? detail = details[entry.key];
                return ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text('${entry.key} x${entry.value}'),
                  subtitle: Text('Quality ${detail?.qualityGrade.name.toUpperCase() ?? '-'}'),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Score ${(detail?.qualityScore ?? 0).toStringAsFixed(2)} / Traits ${detail?.traits.toString() ?? '{}'}',
                      ),
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}

class WorkshopLogCard extends StatelessWidget {
  const WorkshopLogCard({super.key, required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Logs', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...logs.take(8).map((String e) => Text('• $e')),
          ],
        ),
      ),
    );
  }
}
