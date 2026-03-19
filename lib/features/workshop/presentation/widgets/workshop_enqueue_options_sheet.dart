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

    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Builder(
          builder: (BuildContext sheetContext) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
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
                              final WorkshopCraftSubmitResult result = controller
                                  .enqueuePotion(potionId, quantityView.quantity);
                              if (result == WorkshopCraftSubmitResult.success) {
                                Navigator.of(sheetContext).pop();
                                return;
                              }
                              final String message =
                                  result == WorkshopCraftSubmitResult.queueFull
                                  ? '작업실 큐가 가득 찼습니다'
                                  : '제조 등록에 실패했습니다';
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
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
          },
        ),
      ),
    );
  }
}
