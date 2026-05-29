import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_controller.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/craft_queue_option_selectors.dart';
import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_shared_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workshop_enqueue_options_dialog.dart';

class WorkshopCraftCard extends StatelessWidget {
  const WorkshopCraftCard({
    super.key,
    required this.brewCraftableCount,
    required this.materialCraftableCount,
  });

  final int brewCraftableCount;
  final int materialCraftableCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '연금술',
      summary: brewCraftableCount == 0 && materialCraftableCount == 0
          ? '즉시 등록 가능한 항목 없음'
          : '양조 $brewCraftableCount종 / 제작 $materialCraftableCount종',
      icon: Icons.local_drink_outlined,
      onTap: () => _showCraftSheet(context),
    );
  }

  void _showCraftSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const WorkshopCraftSheet();
      },
    );
  }
}

class WorkshopCraftSheet extends ConsumerWidget {
  const WorkshopCraftSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int queueLength = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.workshop.queue.length,
      ),
    );
    final int queueCapacity = ref.watch(workshopQueueCapacityProvider);
    final bool queueFull = queueLength >= queueCapacity;

    return DefaultTabController(
      length: 2,
      child: AppSheetLayout(
        title: '제작',
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (queueFull) ...<Widget>[
              Text('작업실 큐 가득 참 ($queueLength/$queueCapacity)'),
              const SizedBox(height: 12),
            ],
            const TabBar(
              tabs: <Widget>[
                Tab(text: '양조'),
                Tab(text: '제작'),
              ],
            ),
          ],
        ),
        body: const TabBarView(
          children: <Widget>[_WorkshopBrewTab(), _WorkshopMaterialCraftTab()],
        ),
      ),
    );
  }
}

class _WorkshopBrewTab extends ConsumerWidget {
  const _WorkshopBrewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PotionQueueOptionView> options = ref.watch(
      workshopPotionQueueOptionViewsProvider,
    );
    final int queueLength = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.workshop.queue.length,
      ),
    );
    final int queueCapacity = ref.watch(workshopQueueCapacityProvider);
    final bool queueFull = queueLength >= queueCapacity;

    if (options.isEmpty) {
      return const AppEmptyState('등록 가능한 포션이 없습니다');
    }
    return ResourceIconGrid(
      items: options
          .map((PotionQueueOptionView option) {
            final String badgeLabel = option.unlocked
                ? 'x${option.maxCraftableCount}'
                : '-';
            return ResourceIconGridItem(
              key: ValueKey<String>('brew_recipe_${option.potionId}'),
              assetPath: CatalogIconAssetPaths.potion(option.potionId),
              badgeLabel: badgeLabel,
              semanticLabel: '${option.title} $badgeLabel',
              tooltipMessage:
                  '${option.title}\n${option.unlocked ? option.materialHint : option.lockReason}',
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return _WorkshopBrewDetailDialog(
                      option: option,
                      queueFull: queueFull,
                    );
                  },
                );
              },
            );
          })
          .toList(growable: false),
    );
  }
}

class _WorkshopBrewDetailDialog extends StatelessWidget {
  const _WorkshopBrewDetailDialog({
    required this.option,
    required this.queueFull,
  });

  final PotionQueueOptionView option;
  final bool queueFull;

  @override
  Widget build(BuildContext context) {
    final bool canRegister =
        option.unlocked && option.craftableNow && !queueFull;
    return AppDialogLayout(
      title: option.title,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CatalogAssetIcon(
                assetPath: CatalogIconAssetPaths.potion(option.potionId),
                size: 48,
                padding: 6,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                option.unlocked
                    ? '최대 ${option.maxCraftableCount}회'
                    : option.lockReason,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(option.unlocked ? option.materialHint : option.lockReason),
        ],
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
                  final NavigatorState navigator = Navigator.of(context);
                  final BuildContext rootContext = navigator.context;
                  navigator.pop();
                  showDialog<void>(
                    context: rootContext,
                    builder: (BuildContext context) {
                      return WorkshopEnqueueOptionsDialog(
                        potionId: option.potionId,
                        title: option.title,
                        maxCraftableCount: option.maxCraftableCount,
                      );
                    },
                  );
                }
              : null,
          child: const Text('등록'),
        ),
      ],
    );
  }
}

class _WorkshopMaterialCraftTab extends ConsumerWidget {
  const _WorkshopMaterialCraftTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<WorkshopMaterialCraftRecipeView> recipes = ref.watch(
      workshopMaterialCraftRecipeViewsProvider,
    );

    if (recipes.isEmpty) {
      return const AppEmptyState('등록 가능한 제작 항목이 없습니다');
    }
    return ResourceIconGrid(
      items: recipes
          .map((WorkshopMaterialCraftRecipeView recipe) {
            final String quantityLabel = 'x${recipe.resultQuantity}';
            return ResourceIconGridItem(
              key: ValueKey<String>('craft_recipe_${recipe.recipeId}'),
              assetPath: CatalogIconAssetPaths.material(
                recipe.resultMaterialId,
              ),
              badgeLabel: quantityLabel,
              semanticLabel: '${recipe.title} $quantityLabel',
              tooltipMessage:
                  '${recipe.title} $quantityLabel\n${recipe.costHint}\n${recipe.durationLabel}',
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return _WorkshopMaterialCraftDetailDialog(recipe: recipe);
                  },
                );
              },
            );
          })
          .toList(growable: false),
    );
  }
}

class _WorkshopMaterialCraftDetailDialog extends ConsumerStatefulWidget {
  const _WorkshopMaterialCraftDetailDialog({required this.recipe});

  final WorkshopMaterialCraftRecipeView recipe;

  @override
  ConsumerState<_WorkshopMaterialCraftDetailDialog> createState() =>
      _WorkshopMaterialCraftDetailDialogState();
}

class _WorkshopMaterialCraftDetailDialogState
    extends ConsumerState<_WorkshopMaterialCraftDetailDialog> {
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

    return AppDialogLayout(
      title: recipe.title,
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
                Text('결과 x${recipe.resultQuantity * selectedQuantity}'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('제작 수량'),
            const SizedBox(height: AppSpacing.md),
            _CraftQuantitySlider(
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
            Text('필요 재료'),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: recipe.materialCosts
                  .map((WorkshopMaterialCraftCostView cost) {
                    final int requiredQuantity =
                        cost.requiredQuantity * selectedQuantity;
                    final bool enough = cost.ownedQuantity >= requiredQuantity;
                    return _CraftMaterialCostChip(
                      cost: cost,
                      requiredQuantity: requiredQuantity,
                      enough: enough,
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('소요 시간 ${recipe.durationLabel} x$selectedQuantity'),
            const SizedBox(height: AppSpacing.sm),
            Text(recipe.costHint),
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

class _CraftQuantitySlider extends StatelessWidget {
  const _CraftQuantitySlider({
    required this.selectedQuantity,
    required this.value,
    required this.maxQuantity,
    required this.onChanged,
  });

  final int selectedQuantity;
  final double value;
  final int maxQuantity;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool enabled = maxQuantity > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text('선택 $selectedQuantity개')),
            Text(
              '최대 $maxQuantity개',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: maxQuantity.toDouble(),
          divisions: enabled ? maxQuantity - 1 : null,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

class _CraftMaterialCostChip extends StatelessWidget {
  const _CraftMaterialCostChip({
    required this.cost,
    required this.requiredQuantity,
    required this.enough,
  });

  final WorkshopMaterialCraftCostView cost;
  final int requiredQuantity;
  final bool enough;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InputChip(
      avatar: CatalogAssetIcon(
        assetPath: CatalogIconAssetPaths.material(cost.materialId),
        size: 28,
        padding: 3,
        fallbackIcon: Icons.auto_fix_high_outlined,
      ),
      label: Text('${cost.name} ${cost.ownedQuantity}/$requiredQuantity'),
      side: BorderSide(
        color: enough ? colorScheme.outlineVariant : colorScheme.error,
      ),
    );
  }
}
