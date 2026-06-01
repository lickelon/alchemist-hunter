import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_controller.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/use_cases/workshop_brew_experiment_use_case.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafting_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/workshop_display_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopResearchCard extends StatelessWidget {
  const WorkshopResearchCard({super.key, required this.traitTypeCount});

  final int traitTypeCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '연구',
      summary: traitTypeCount == 0
          ? '실험 가능한 원소 없음'
          : '양조 실험 원소 $traitTypeCount종',
      icon: Icons.science_outlined,
      onTap: () {
        showAppBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return const AppSheetLayout(
              title: '연구',
              body: _WorkshopBrewExperimentTab(),
            );
          },
        );
      },
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
    final bool canSubmit = _selectedTraitIds.length == 2;

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
                      _toggleTrait(entry.key);
                    });
                  },
                );
              })
              .toList(growable: false),
        ),
        if (_selectedTraitIds.length == 2) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
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
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _BrewPreviewPanel(
          selectedCount: _selectedTraitIds.length,
          hintLabel: preview.hintLabel,
          alreadyDiscovered: preview.alreadyDiscovered,
        ),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            key: const ValueKey<String>('brew_experiment_submit_button'),
            onPressed: canSubmit
                ? () {
                    final WorkshopBrewExperimentSubmitResult result = ref
                        .read(workshopCraftQueueControllerProvider)
                        .experimentBrew(inputTraits);
                    if (result.status == WorkshopBrewExperimentStatus.success) {
                      setState(() {
                        _selectedTraitIds.clear();
                        _primaryRatio = _defaultPrimaryRatio;
                      });
                    }
                    _showExperimentResult(
                      context,
                      result,
                      ref.read(potionCatalogRepositoryProvider).potions(),
                    );
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
      (String traitId) => (inventory[traitId] ?? 0) <= 0,
    );
  }

  void _toggleTrait(String traitId) {
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

  void _showExperimentResult(
    BuildContext context,
    WorkshopBrewExperimentSubmitResult result,
    List<PotionBlueprint> potions,
  ) {
    final Map<String, PotionBlueprint> potionMap = <String, PotionBlueprint>{
      for (final PotionBlueprint potion in potions) potion.id: potion,
    };
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return _BrewExperimentResultDialog(
          result: result,
          potionId: result.potionId,
          potionName: potionMap[result.potionId]?.name,
        );
      },
    );
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
                '주 ${(value * 100).round()}%',
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
                '부 ${(secondaryValue * 100).round()}%',
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
  });

  final int selectedCount;
  final String hintLabel;
  final bool alreadyDiscovered;

  @override
  Widget build(BuildContext context) {
    final String status = switch (selectedCount) {
      0 => '원소 2종 선택 필요',
      1 => '원소를 하나 더 선택하세요',
      _ => hintLabel,
    };
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

class _BrewExperimentResultDialog extends ConsumerWidget {
  const _BrewExperimentResultDialog({
    required this.result,
    required this.potionId,
    required this.potionName,
  });

  final WorkshopBrewExperimentSubmitResult result;
  final String? potionId;
  final String? potionName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool success = result.status == WorkshopBrewExperimentStatus.success;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String title = switch (result.status) {
      WorkshopBrewExperimentStatus.success => '실험 결과',
      WorkshopBrewExperimentStatus.elementMissing => '원소 부족',
      WorkshopBrewExperimentStatus.unknownReaction => '알 수 없는 반응',
      WorkshopBrewExperimentStatus.failed => '실험 실패',
    };
    final String gradeLabel = result.qualityGrade?.name.toUpperCase() ?? '-';
    final String discoveryLabel = !success
        ? '레시피 기록 없음'
        : result.isNewDiscovery
        ? '레시피 신규 발견'
        : result.discoveryChanged
        ? '레시피 갱신 ${result.previousGrade?.name.toUpperCase()} → $gradeLabel'
        : '기존 기록 유지';
    final String? qualityLabel = result.qualityScore == null
        ? null
        : '$gradeLabel · ${(result.qualityScore! * 100).round()}점';
    final bool canPinRecipe =
        success &&
        !result.isNewDiscovery &&
        result.potionId != null &&
        result.discoveredTraits != null &&
        result.qualityGrade != null;
    final String recipeActionLabel = canPinRecipe
        ? '이 비율로 레시피 고정'
        : discoveryLabel;
    final IconData statusIcon = switch (result.status) {
      WorkshopBrewExperimentStatus.success =>
        result.discoveryChanged
            ? Icons.auto_awesome_outlined
            : Icons.bookmark_added_outlined,
      WorkshopBrewExperimentStatus.elementMissing => Icons.inventory_2_outlined,
      WorkshopBrewExperimentStatus.unknownReaction => Icons.science_outlined,
      WorkshopBrewExperimentStatus.failed => Icons.error_outline,
    };
    final Color statusColor = switch (result.status) {
      WorkshopBrewExperimentStatus.success =>
        result.discoveryChanged ? colorScheme.primary : colorScheme.tertiary,
      WorkshopBrewExperimentStatus.elementMissing => colorScheme.error,
      WorkshopBrewExperimentStatus.unknownReaction => colorScheme.outline,
      WorkshopBrewExperimentStatus.failed => colorScheme.error,
    };

    return AppDialogLayout(
      title: title,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (success && potionId != null)
                CatalogAssetIcon(
                  assetPath: CatalogIconAssetPaths.potion(potionId!),
                  size: 48,
                  padding: 6,
                  fallbackIcon: Icons.local_drink_outlined,
                )
              else
                _ExperimentStatusIcon(icon: statusIcon, color: statusColor),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      success
                          ? potionName ?? '포션 반응'
                          : switch (result.status) {
                              WorkshopBrewExperimentStatus.elementMissing =>
                                '보유 원소가 부족합니다',
                              WorkshopBrewExperimentStatus.unknownReaction =>
                                '조합을 판정할 수 없습니다',
                              WorkshopBrewExperimentStatus.failed =>
                                '실험을 진행할 수 없습니다',
                              WorkshopBrewExperimentStatus.success => '',
                            },
                      style: success
                          ? Theme.of(context).textTheme.titleMedium
                          : Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (success && qualityLabel != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        qualityLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _ExperimentStatusBanner(
            icon: statusIcon,
            color: statusColor,
            label: recipeActionLabel,
            onTap: canPinRecipe
                ? () {
                    ref
                        .read(workshopCraftQueueControllerProvider)
                        .pinBrewExperimentRecipe(
                          potionId: result.potionId!,
                          discoveredTraits: result.discoveredTraits!,
                          grade: result.qualityGrade!,
                        );
                    AppToast.show(context, '레시피 비율을 고정했습니다');
                    Navigator.of(context).pop();
                  }
                : null,
          ),
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
      ],
    );
  }
}

class _ExperimentStatusIcon extends StatelessWidget {
  const _ExperimentStatusIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(width: 56, height: 56, child: Icon(icon, color: color)),
    );
  }
}

class _ExperimentStatusBanner extends StatelessWidget {
  const _ExperimentStatusBanner({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(8);
    return Material(
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label)),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: color.withValues(alpha: 0.72),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
