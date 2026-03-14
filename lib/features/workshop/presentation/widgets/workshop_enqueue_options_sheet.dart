import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

class WorkshopEnqueueOptionsSheet extends ConsumerWidget {
  const WorkshopEnqueueOptionsSheet({
    super.key,
    required this.potionId,
    required this.title,
    required this.maxCraftableCount,
  });

  final String potionId;
  final String title;
  final int maxCraftableCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<EnqueueQuantityView> quantities = ref.watch(
      workshopEnqueueQuantityViewsProvider(potionId),
    );
    final WorkshopCraftQueueController controller = ref.read(
      workshopCraftQueueControllerProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('최대 $maxCraftableCount회 제작 가능'),
            const SizedBox(height: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: quantities.map((EnqueueQuantityView quantityView) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(quantityView.label),
                  subtitle: Text(quantityView.requirementText),
                  trailing: FilledButton.tonal(
                    onPressed: () {
                      controller.enqueuePotion(potionId, quantityView.quantity);
                      Navigator.of(context).pop();
                    },
                    child: const Text('등록'),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
