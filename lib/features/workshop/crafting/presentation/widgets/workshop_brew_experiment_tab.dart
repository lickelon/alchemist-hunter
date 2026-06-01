import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_submit_results.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/workshop_craft_queue_controller_provider.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/use_cases/workshop_brew_experiment_use_case.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafting_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_brew_experiment_selection.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_brew_experiment_preview_panel.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_brew_experiment_result_dialog.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_brew_experiment_slider.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_brew_experiment_trait_grid.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopBrewExperimentTab extends ConsumerStatefulWidget {
  const WorkshopBrewExperimentTab({super.key});

  @override
  ConsumerState<WorkshopBrewExperimentTab> createState() =>
      _WorkshopBrewExperimentTabState();
}

class _WorkshopBrewExperimentTabState
    extends ConsumerState<WorkshopBrewExperimentTab> {
  final WorkshopBrewExperimentSelection _selection =
      WorkshopBrewExperimentSelection();

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

    _selection.syncWithInventory(inventory);

    if (ownedTraits.isEmpty) {
      return const AppEmptyState('보유 원소가 없습니다');
    }

    final Map<String, double> inputTraits = _selection.inputTraits;
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
    final bool canSubmit = _selection.canSubmit;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: <Widget>[
        WorkshopBrewExperimentTraitGrid(
          ownedTraits: ownedTraits,
          traitMap: traitMap,
          selectedTraitIds: _selection.selectedTraitIds,
          onTraitSelected: (String traitId) {
            setState(() {
              _selection.toggleTrait(traitId);
            });
          },
        ),
        if (_selection.canSubmit) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          WorkshopBrewExperimentSlider(
            primaryName:
                traitMap[_selection.primaryTraitId]?.name ??
                _selection.primaryTraitId!,
            secondaryName:
                traitMap[_selection.secondaryTraitId]?.name ??
                _selection.secondaryTraitId!,
            value: _selection.primaryRatio,
            onChanged: (double nextValue) {
              setState(() {
                _selection.primaryRatio = nextValue;
              });
            },
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        WorkshopBrewExperimentPreviewPanel(
          selectedCount: _selection.selectedCount,
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
                        _selection.reset();
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
        return WorkshopBrewExperimentResultDialog(
          result: result,
          potionId: result.potionId,
          potionName: potionMap[result.potionId]?.name,
        );
      },
    );
  }
}
