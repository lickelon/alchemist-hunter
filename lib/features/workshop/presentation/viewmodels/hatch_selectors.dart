import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';

class HomunculusHatchRecipeView {
  const HomunculusHatchRecipeView({
    required this.id,
    required this.name,
    required this.description,
    required this.resultName,
    required this.roleLabel,
    required this.supportEffectLabel,
    required this.costLabel,
    required this.canHatch,
  });

  final String id;
  final String name;
  final String description;
  final String resultName;
  final String roleLabel;
  final String supportEffectLabel;
  final String costLabel;
  final bool canHatch;
}

final Provider<int> workshopHomunculusCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.characters.homunculi.length,
    ),
  );
});

final Provider<List<HomunculusHatchRecipeView>> homunculusHatchRecipeViewsProvider =
    Provider<List<HomunculusHatchRecipeView>>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final Map<String, MaterialEntity> materialMap = <String, MaterialEntity>{
        for (final MaterialEntity material in ref.watch(materialsProvider))
          material.id: material,
      };
      final Map<String, TraitUnit> traitMap = <String, TraitUnit>{
        for (final TraitUnit trait in ref.watch(traitsProvider)) trait.id: trait,
      };

      return ref.watch(homunculusHatchRecipesProvider).map((
        HomunculusHatchRecipe recipe,
      ) {
        final bool enoughEssence = state.player.essence >= recipe.essenceCost;
        final bool enoughDust = state.player.arcaneDust >= recipe.arcaneDustCost;
        final bool enoughMaterials = recipe.materialCosts.entries.every(
          (MapEntry<String, int> entry) =>
              (state.player.materialInventory[entry.key] ?? 0) >= entry.value,
        );
        final bool enoughTraits = recipe.traitCosts.entries.every(
          (MapEntry<String, double> entry) =>
              (state.workshop.extractedTraitInventory[entry.key] ?? 0) >=
              entry.value,
        );

        final String materialCostLabel = recipe.materialCosts.entries
            .map(
              (MapEntry<String, int> entry) =>
                  '${materialMap[entry.key]?.name ?? entry.key} x${entry.value}',
            )
            .join(', ');
        final String traitCostLabel = recipe.traitCosts.entries
            .map(
              (MapEntry<String, double> entry) =>
                  '${traitMap[entry.key]?.name ?? entry.key} ${entry.value.toStringAsFixed(1)}',
            )
            .join(', ');

        return HomunculusHatchRecipeView(
          id: recipe.id,
          name: recipe.name,
          description: recipe.description,
          resultName: recipe.resultName,
          roleLabel: recipe.roleLabel,
          supportEffectLabel: recipe.supportEffectLabel,
          costLabel:
              'Essence ${recipe.essenceCost} / ArcaneDust ${recipe.arcaneDustCost}${materialCostLabel.isEmpty ? "" : " / $materialCostLabel"}${traitCostLabel.isEmpty ? "" : " / $traitCostLabel"}',
          canHatch: enoughEssence && enoughDust && enoughMaterials && enoughTraits,
        );
      }).toList(growable: false);
    });
