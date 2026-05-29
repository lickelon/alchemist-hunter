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
    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (BuildContext context, int index) {
        final PotionQueueOptionView option = options[index];
        return ListTile(
          dense: true,
          leading: CatalogAssetIcon(
            assetPath: CatalogIconAssetPaths.potion(option.potionId),
            size: 36,
            padding: 5,
          ),
          title: Text(option.title),
          subtitle: Text(
            option.unlocked ? option.materialHint : '잠김: ${option.lockReason}',
          ),
          trailing: FilledButton.tonal(
            onPressed: option.unlocked && option.craftableNow && !queueFull
                ? () {
                    showDialog<void>(
                      context: context,
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
        );
      },
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

class _WorkshopMaterialCraftDetailDialog extends ConsumerWidget {
  const _WorkshopMaterialCraftDetailDialog({required this.recipe});

  final WorkshopMaterialCraftRecipeView recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppDialogLayout(
      title: recipe.title,
      body: Column(
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
              Text('결과 x${recipe.resultQuantity}'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('소요 시간 ${recipe.durationLabel}'),
          const SizedBox(height: AppSpacing.sm),
          Text(recipe.costHint),
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
          onPressed: recipe.craftableNow
              ? () {
                  final WorkshopCraftSubmitResult result = ref
                      .read(workshopCraftQueueControllerProvider)
                      .enqueueMaterialRecipe(recipe.recipeId);
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
