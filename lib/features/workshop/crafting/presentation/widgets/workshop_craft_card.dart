import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
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
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafting_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/workshop_display_labels.dart';
import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_shared_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          TabBar(
            tabs: <Widget>[
              Tab(text: '실험'),
              Tab(text: '레시피북'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _WorkshopBrewExperimentTab(),
                _WorkshopBrewRecipeBookTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkshopBrewExperimentTab extends ConsumerStatefulWidget {
  const _WorkshopBrewExperimentTab();

  @override
  ConsumerState<_WorkshopBrewExperimentTab> createState() =>
      _WorkshopBrewExperimentTabState();
}

class _WorkshopBrewExperimentTabState
    extends ConsumerState<_WorkshopBrewExperimentTab> {
  static const double _defaultPrimaryRatio = 0.55;

  final List<String> _selectedTraitIds = <String>[];
  double _primaryRatio = _defaultPrimaryRatio;

  @override
  Widget build(BuildContext context) {
    final Map<String, double> inventory = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.workshop.extractedTraitInventory,
      ),
    );
    final List<TraitUnit> traits = ref.watch(traitsProvider);
    final int queueLength = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.workshop.queue.length,
      ),
    );
    final int queueCapacity = ref.watch(workshopQueueCapacityProvider);
    final bool queueFull = queueLength >= queueCapacity;
    final Map<String, TraitUnit> traitMap = <String, TraitUnit>{
      for (final TraitUnit trait in traits) trait.id: trait,
    };
    final List<MapEntry<String, double>> ownedTraits = inventory.entries
        .where((MapEntry<String, double> entry) => entry.value > 0)
        .toList(growable: false);

    _syncSelectionWithInventory(inventory);

    if (ownedTraits.isEmpty) {
      return const AppEmptyState('보유 원소가 없습니다');
    }

    final Map<String, double> inputTraits = <String, double>{
      if (_selectedTraitIds.length == 2) ...<String, double>{
        _selectedTraitIds[0]: _primaryRatio,
        _selectedTraitIds[1]: 1 - _primaryRatio,
      },
    };
    final preview = ref
        .watch(potionCraftingServiceProvider)
        .previewBrew(
          inputTraits: inputTraits,
          recipeRules: ref.watch(potionCatalogRepositoryProvider).recipeRules(),
          discoveredPotionIds: ref.watch(
            sessionControllerProvider.select(
              (SessionState state) =>
                  state.workshop.discoveredPotionRecipes.keys.toSet(),
            ),
          ),
        );
    final bool canSubmit =
        _selectedTraitIds.length == 2 &&
        preview.predictedPotionId != null &&
        !queueFull;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: <Widget>[
        ResourceIconGrid(
          items: ownedTraits
              .map((MapEntry<String, double> entry) {
                final TraitUnit? trait = traitMap[entry.key];
                final String amountLabel = workshopTraitAmountLabel(
                  entry.value,
                );
                final bool selected = _selectedTraitIds.contains(entry.key);
                return ResourceIconGridItem(
                  key: ValueKey<String>('brew_experiment_trait_${entry.key}'),
                  assetPath: CatalogIconAssetPaths.element(entry.key),
                  badgeLabel: amountLabel,
                  semanticLabel: '${trait?.name ?? entry.key} 원소 $amountLabel',
                  tooltipMessage: '${trait?.name ?? entry.key} 원소 $amountLabel',
                  selected: selected,
                  onTap: () {
                    setState(() {
                      _toggleTrait(entry.key, entry.value);
                    });
                  },
                );
              })
              .toList(growable: false),
        ),
        if (_selectedTraitIds.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          if (_selectedTraitIds.length == 2)
            _BrewRatioSlider(
              primaryName:
                  traitMap[_selectedTraitIds[0]]?.name ?? _selectedTraitIds[0],
              secondaryName:
                  traitMap[_selectedTraitIds[1]]?.name ?? _selectedTraitIds[1],
              value: _primaryRatio,
              onChanged: (double nextValue) {
                setState(() {
                  _primaryRatio = nextValue;
                });
              },
            )
          else
            const Text('원소를 하나 더 선택하세요'),
        ],
        const SizedBox(height: AppSpacing.lg),
        _BrewPreviewPanel(
          selectedCount: _selectedTraitIds.length,
          hintLabel: preview.hintLabel,
          alreadyDiscovered: preview.alreadyDiscovered,
          queueFull: queueFull,
        ),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            key: const ValueKey<String>('brew_experiment_submit_button'),
            onPressed: canSubmit
                ? () {
                    final WorkshopCraftSubmitResult result = ref
                        .read(workshopCraftQueueControllerProvider)
                        .enqueueBrew(inputTraits);
                    if (result == WorkshopCraftSubmitResult.success) {
                      setState(() {
                        _selectedTraitIds.clear();
                        _primaryRatio = _defaultPrimaryRatio;
                      });
                    }
                    final String message = switch (result) {
                      WorkshopCraftSubmitResult.success => '양조 실험을 등록했습니다',
                      WorkshopCraftSubmitResult.queueFull => '작업실 큐가 가득 찼습니다',
                      WorkshopCraftSubmitResult.elementMissing => '원소 부족',
                      WorkshopCraftSubmitResult.resourceMissing => '재료 부족',
                      WorkshopCraftSubmitResult.failed => '조합을 판정할 수 없습니다',
                    };
                    AppToast.show(context, message);
                  }
                : null,
            child: const Text('시험 양조'),
          ),
        ),
      ],
    );
  }

  void _syncSelectionWithInventory(Map<String, double> inventory) {
    _selectedTraitIds.removeWhere(
      (String traitId) => (inventory[traitId] ?? 0) < 1,
    );
  }

  void _toggleTrait(String traitId, double ownedAmount) {
    if (_selectedTraitIds.contains(traitId)) {
      _selectedTraitIds.remove(traitId);
      _primaryRatio = _defaultPrimaryRatio;
      return;
    }
    if (_selectedTraitIds.length >= 2) {
      _selectedTraitIds.removeAt(0);
    }
    _selectedTraitIds.add(traitId);
    _primaryRatio = _defaultPrimaryRatio;
  }
}

class _BrewRatioSlider extends StatelessWidget {
  const _BrewRatioSlider({
    required this.primaryName,
    required this.secondaryName,
    required this.value,
    required this.onChanged,
  });

  final String primaryName;
  final String secondaryName;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final double secondaryValue = 1 - value;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(primaryName)),
              Text(
                '메인 ${(value * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(0.55, 0.95).toDouble(),
            min: 0.55,
            max: 0.95,
            divisions: 8,
            onChanged: onChanged,
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text(secondaryName)),
              Text(
                '서브 ${(secondaryValue * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrewPreviewPanel extends StatelessWidget {
  const _BrewPreviewPanel({
    required this.selectedCount,
    required this.hintLabel,
    required this.alreadyDiscovered,
    required this.queueFull,
  });

  final int selectedCount;
  final String hintLabel;
  final bool alreadyDiscovered;
  final bool queueFull;

  @override
  Widget build(BuildContext context) {
    final String status = queueFull
        ? '작업실 큐 가득 참'
        : selectedCount < 2
        ? '원소 2종 선택 필요'
        : hintLabel;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            Icon(
              alreadyDiscovered
                  ? Icons.bookmark_added_outlined
                  : Icons.science_outlined,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(status)),
          ],
        ),
      ),
    );
  }
}

class _WorkshopBrewRecipeBookTab extends ConsumerWidget {
  const _WorkshopBrewRecipeBookTab();

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
              tooltipMessage:
                  '${recipe.title}\n품질 ${recipe.qualityLabel}\n${recipe.traitHint}',
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return _WorkshopDiscoveredBrewDetailDialog(recipe: recipe);
                  },
                );
              },
            );
          })
          .toList(growable: false),
    );
  }
}

class _WorkshopDiscoveredBrewDetailDialog extends ConsumerStatefulWidget {
  const _WorkshopDiscoveredBrewDetailDialog({required this.recipe});

  final DiscoveredPotionRecipeView recipe;

  @override
  ConsumerState<_WorkshopDiscoveredBrewDetailDialog> createState() =>
      _WorkshopDiscoveredBrewDetailDialogState();
}

class _WorkshopDiscoveredBrewDetailDialogState
    extends ConsumerState<_WorkshopDiscoveredBrewDetailDialog> {
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
      title: recipe.title,
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
                Text('품질 ${recipe.qualityLabel}'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('양조 수량'),
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
            Text('필요 원소'),
            const SizedBox(height: AppSpacing.sm),
            Text(recipe.traitHint),
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
