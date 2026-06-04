import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_submit_results.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/workshop_craft_queue_controller_provider.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/craft_queue_option_selectors.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/craft_quantity_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopMaterialCraftDetailDialog extends ConsumerStatefulWidget {
  const WorkshopMaterialCraftDetailDialog({super.key, required this.recipe});

  final WorkshopMaterialCraftRecipeView recipe;

  @override
  ConsumerState<WorkshopMaterialCraftDetailDialog> createState() =>
      _WorkshopMaterialCraftDetailDialogState();
}

class _WorkshopMaterialCraftDetailDialogState
    extends ConsumerState<WorkshopMaterialCraftDetailDialog> {
  double _quantityValue = 1;

  @override
  Widget build(BuildContext context) {
    final WorkshopMaterialCraftRecipeView recipe = widget.recipe;
    final int maxQuantity = recipe.maxCraftableCount < 1
        ? 1
        : recipe.maxCraftableCount;
    final double sliderValue = _quantityValue
        .clamp(1.0, maxQuantity.toDouble())
        .toDouble();
    final int selectedQuantity = sliderValue
        .round()
        .clamp(1, maxQuantity)
        .toInt();
    final bool canRegister =
        recipe.craftableNow && recipe.maxCraftableCount >= selectedQuantity;
    final List<ResourceIconGridItem> materialItems = recipe.materialCosts
        .map((WorkshopMaterialCraftCostView cost) {
          final int requiredQuantity = cost.requiredQuantity * selectedQuantity;
          return ResourceIconGridItem(
            assetPath: CatalogIconAssetPaths.material(cost.materialId),
            badgeLabel: '${cost.ownedQuantity}/$requiredQuantity',
            semanticLabel:
                '${cost.name} ${cost.ownedQuantity}/$requiredQuantity',
            tooltipMessage: cost.name,
          );
        })
        .toList(growable: false);
    final List<String> detailLines = <String>[
      '시간 ${recipe.totalDurationLabel(selectedQuantity)}',
      if (recipe.extraCostHint.isNotEmpty) recipe.extraCostHint,
    ];

    return AppDialogLayout(
      title: '제작 등록',
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CatalogAssetIcon(
                  assetPath: CatalogIconAssetPaths.material(
                    recipe.resultMaterialId,
                  ),
                  size: 48,
                  padding: 6,
                  fallbackIcon: Icons.auto_fix_high_outlined,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppBadge(
                        label:
                            '결과 x${recipe.resultQuantity * selectedQuantity}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('수량'),
            const SizedBox(height: AppSpacing.md),
            CraftQuantitySlider(
              selectedQuantity: selectedQuantity,
              value: sliderValue,
              maxQuantity: maxQuantity,
              onChanged: (double value) {
                setState(() {
                  _quantityValue = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('재료'),
            const SizedBox(height: AppSpacing.md),
            ResourceIconGrid(items: materialItems),
            const SizedBox(height: AppSpacing.lg),
            DetailLines(lines: detailLines),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
          label: const Text('닫기'),
        ),
        FilledButton(
          onPressed: canRegister
              ? () {
                  final WorkshopCraftSubmitResult result = ref
                      .read(workshopCraftQueueControllerProvider)
                      .enqueueMaterialRecipe(
                        recipe.recipeId,
                        repeatCount: selectedQuantity,
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
                    WorkshopCraftSubmitResult.failed => '제작 등록에 실패했습니다',
                  };
                  AppToast.show(context, message);
                }
              : null,
          child: const Text('등록'),
        ),
      ],
    );
  }
}
