import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_controller.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/craft_queue_quantity_selectors.dart';

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

    return AppBottomSheet(
      child: AppSheetLayout(
        title: title,
        header: Text('최대 $maxCraftableCount회 제작 가능'),
        expandBody: false,
        body: Column(
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
                    Navigator.of(context).pop();
                    return;
                  }
                  final String message = switch (result) {
                    WorkshopCraftSubmitResult.queueFull => '작업실 큐가 가득 찼습니다',
                    WorkshopCraftSubmitResult.elementMissing => '원소 부족',
                    WorkshopCraftSubmitResult.success => '',
                    WorkshopCraftSubmitResult.failed => '제조 등록에 실패했습니다',
                  };
                  AppToast.show(context, message);
                },
                child: const Text('등록'),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
