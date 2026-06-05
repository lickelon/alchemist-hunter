import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_slider_field.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_submit_results.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/workshop_craft_queue_controller_provider.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/craft_queue_option_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopBrewRecipeBookTab extends ConsumerWidget {
  const WorkshopBrewRecipeBookTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<DiscoveredPotionRecipeView> recipes = ref.watch(
      workshopDiscoveredPotionRecipeViewsProvider,
    );
    if (recipes.isEmpty) {
      return const AppEmptyState('발견한 포션이 없습니다');
    }
    return ResourceIconGrid(
      items: recipes
          .map((DiscoveredPotionRecipeView recipe) {
            final String badgeLabel = 'x${recipe.maxCraftableCount}';
            return ResourceIconGridItem(
              key: ValueKey<String>('brew_recipe_${recipe.potionId}'),
              assetPath: CatalogIconAssetPaths.potion(recipe.potionId),
              badgeLabel: badgeLabel,
              semanticLabel: '${recipe.title} $badgeLabel',
              tooltipMessage: recipe.title,
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return WorkshopDiscoveredBrewDetailDialog(recipe: recipe);
                  },
                );
              },
            );
          })
          .toList(growable: false),
    );
  }
}

class WorkshopDiscoveredBrewDetailDialog extends ConsumerStatefulWidget {
  const WorkshopDiscoveredBrewDetailDialog({super.key, required this.recipe});

  final DiscoveredPotionRecipeView recipe;

  @override
  ConsumerState<WorkshopDiscoveredBrewDetailDialog> createState() =>
      _WorkshopDiscoveredBrewDetailDialogState();
}

class _WorkshopDiscoveredBrewDetailDialogState
    extends ConsumerState<WorkshopDiscoveredBrewDetailDialog> {
  double _quantityValue = 1;

  @override
  Widget build(BuildContext context) {
    final DiscoveredPotionRecipeView recipe = widget.recipe;
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
      title: '양조 등록',
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CatalogAssetIcon(
                  assetPath: CatalogIconAssetPaths.potion(recipe.potionId),
                  size: 48,
                  padding: 6,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: <Widget>[
                          AppBadge(label: recipe.qualityLabel),
                          AppBadge(label: 'x$selectedQuantity'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('수량'),
            const SizedBox(height: AppSpacing.md),
            AppQuantitySlider(
              selectedQuantity: selectedQuantity,
              value: sliderValue,
              maxQuantity: maxQuantity,
              divided: true,
              onChanged: (double value) {
                setState(() {
                  _quantityValue = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: recipe.ratioBadgeLabels
                  .map((String label) => AppBadge(label: label))
                  .toList(growable: false),
            ),
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
                      .enqueueBrew(
                        recipe.traits,
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
                    WorkshopCraftSubmitResult.failed => '양조 등록에 실패했습니다',
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
