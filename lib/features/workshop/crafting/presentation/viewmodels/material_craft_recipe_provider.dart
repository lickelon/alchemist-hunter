import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/material_craft_recipe_view_models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_resource_selectors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<List<WorkshopMaterialCraftRecipeView>>
workshopMaterialCraftRecipeViewsProvider =
    Provider<List<WorkshopMaterialCraftRecipeView>>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final List<WorkshopCraftRecipe> recipes = ref.watch(
        workshopCraftRecipesProvider,
      );
      final List<MaterialEntity> materials = ref.watch(materialsProvider);
      final List<TraitUnit> traits = ref.watch(traitsProvider);
      final int queueLength = state.workshop.queue.length;
      final int queueCapacity = ref.watch(workshopQueueCapacityProvider);
      final bool queueFull = queueLength >= queueCapacity;
      final Map<String, String> materialNames = <String, String>{
        for (final MaterialEntity material in materials)
          material.id: material.name,
      };
      final Map<String, String> traitNames = <String, String>{
        for (final TraitUnit trait in traits) trait.id: trait.name,
      };

      return recipes
          .map((WorkshopCraftRecipe recipe) {
            final int maxCraftableCount = materialRecipeMaxCraftableCount(
              recipe,
              state,
            );
            final MapEntry<String, int> result =
                recipe.resultMaterials.entries.first;
            return WorkshopMaterialCraftRecipeView(
              recipeId: recipe.id,
              title: recipe.name,
              costHint: materialCraftRecipeCostHint(
                recipe,
                materialNames: materialNames,
                traitNames: traitNames,
              ),
              extraCostHint: materialCraftRecipeExtraCostHint(
                recipe,
                traitNames: traitNames,
              ),
              resultMaterialId: result.key,
              resultQuantity: result.value,
              durationLabel: materialCraftDurationLabel(recipe.duration),
              duration: recipe.duration,
              materialCosts: recipe.materialCosts.entries
                  .map(
                    (MapEntry<String, int> cost) =>
                        WorkshopMaterialCraftCostView(
                          materialId: cost.key,
                          name: materialNames[cost.key] ?? cost.key,
                          requiredQuantity: cost.value,
                          ownedQuantity:
                              state.player.materialInventory[cost.key] ?? 0,
                        ),
                  )
                  .toList(growable: false),
              maxCraftableCount: maxCraftableCount,
              craftableNow: maxCraftableCount > 0 && !queueFull,
              queueFull: queueFull,
            );
          })
          .toList(growable: false);
    });

int materialRecipeMaxCraftableCount(
  WorkshopCraftRecipe recipe,
  SessionState state,
) {
  int maxCount = 999999;
  for (final MapEntry<String, int> cost in recipe.materialCosts.entries) {
    if (cost.value <= 0) {
      continue;
    }
    maxCount = _minInt(
      maxCount,
      (state.player.materialInventory[cost.key] ?? 0) ~/ cost.value,
    );
  }
  for (final MapEntry<String, double> cost in recipe.traitCosts.entries) {
    if (cost.value <= 0) {
      continue;
    }
    maxCount = _minInt(
      maxCount,
      ((state.workshop.extractedTraitInventory[cost.key] ?? 0) / cost.value)
          .floor(),
    );
  }
  if (recipe.essenceCost > 0) {
    maxCount = _minInt(maxCount, state.player.essence ~/ recipe.essenceCost);
  }
  if (recipe.arcaneDustCost > 0) {
    maxCount = _minInt(
      maxCount,
      state.player.arcaneDust ~/ recipe.arcaneDustCost,
    );
  }
  return maxCount == 999999 ? 0 : maxCount;
}

String materialCraftRecipeExtraCostHint(
  WorkshopCraftRecipe recipe, {
  required Map<String, String> traitNames,
}) {
  final List<String> parts = <String>[];
  if (recipe.essenceCost > 0) {
    parts.add('정수 ${recipe.essenceCost}');
  }
  if (recipe.arcaneDustCost > 0) {
    parts.add('신비 ${recipe.arcaneDustCost}');
  }
  recipe.traitCosts.forEach((String traitId, double amount) {
    parts.add(
      '${traitNames[traitId] ?? traitId} 원소 ${amount.toStringAsFixed(1)}',
    );
  });
  return parts.join(' / ');
}

String materialCraftRecipeCostHint(
  WorkshopCraftRecipe recipe, {
  required Map<String, String> materialNames,
  required Map<String, String> traitNames,
}) {
  final List<String> parts = <String>[];
  if (recipe.essenceCost > 0) {
    parts.add('정수 ${recipe.essenceCost}');
  }
  if (recipe.arcaneDustCost > 0) {
    parts.add('신비 ${recipe.arcaneDustCost}');
  }
  recipe.materialCosts.forEach((String materialId, int quantity) {
    parts.add('${materialNames[materialId] ?? materialId} x$quantity');
  });
  recipe.traitCosts.forEach((String traitId, double amount) {
    parts.add(
      '${traitNames[traitId] ?? traitId} 원소 ${amount.toStringAsFixed(1)}',
    );
  });
  return parts.join(' / ');
}

int _minInt(int left, int right) {
  return left < right ? left : right;
}
