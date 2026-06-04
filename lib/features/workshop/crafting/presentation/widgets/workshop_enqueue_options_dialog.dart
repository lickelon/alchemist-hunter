import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_submit_results.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/workshop_craft_queue_controller.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/workshop_craft_queue_controller_provider.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/craft_queue_quantity_selectors.dart';

class WorkshopEnqueueOptionsDialog extends StatelessWidget {
  const WorkshopEnqueueOptionsDialog({
    super.key,
    required this.potionId,
    required this.title,
    required this.maxCraftableCount,
  });

  final String potionId;
  final String title;
  final int maxCraftableCount;

  @override
  Widget build(BuildContext context) {
    return _WorkshopEnqueueOptionsContent(
      potionId: potionId,
      title: title,
      maxCraftableCount: maxCraftableCount,
    );
  }
}

class _WorkshopEnqueueOptionsContent extends ConsumerWidget {
  const _WorkshopEnqueueOptionsContent({
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
    final Widget quantityList = Column(
      mainAxisSize: MainAxisSize.min,
      children: quantities.map((EnqueueQuantityView quantityView) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(quantityView.label),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: quantityView.requirementLabels
                  .map((String label) => AppBadge(label: label))
                  .toList(),
            ),
          ),
          trailing: FilledButton.tonal(
            onPressed: () {
              final WorkshopCraftSubmitResult result = controller.enqueuePotion(
                potionId,
                quantityView.quantity,
              );
              if (result == WorkshopCraftSubmitResult.success) {
                Navigator.of(context).pop();
                return;
              }
              final String message = switch (result) {
                WorkshopCraftSubmitResult.queueFull => '작업실 큐가 가득 찼습니다',
                WorkshopCraftSubmitResult.elementMissing => '원소 부족',
                WorkshopCraftSubmitResult.resourceMissing => '재료 부족',
                WorkshopCraftSubmitResult.success => '',
                WorkshopCraftSubmitResult.failed => '제조 등록에 실패했습니다',
              };
              AppToast.show(context, message);
            },
            child: const Text('등록'),
          ),
        );
      }).toList(),
    );

    return AppDialogLayout(
      title: title,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('최대 $maxCraftableCount회 제작 가능'),
          const SizedBox(height: AppSpacing.md),
          quantityList,
        ],
      ),
    );
  }
}
