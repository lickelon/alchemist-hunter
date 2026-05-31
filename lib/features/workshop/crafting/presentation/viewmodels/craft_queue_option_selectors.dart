import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_shared_selectors.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafting_service_providers.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';

class PotionQueueOptionView {
  const PotionQueueOptionView({
    required this.potionId,
    required this.title,
    required this.unlocked,
    required this.lockReason,
    required this.craftableNow,
    required this.maxCraftableCount,
    required this.materialHint,
    required this.queueFull,
  });

  final String potionId;
  final String title;
  final bool unlocked;
  final String lockReason;
  final bool craftableNow;
  final int maxCraftableCount;
  final String materialHint;
  final bool queueFull;
}

class WorkshopCraftMenuSummaryView {
  const WorkshopCraftMenuSummaryView({
    required this.craftableCount,
    required this.unlockedCount,
    required this.materialCraftableCount,
    required this.description,
  });

  final int craftableCount;
  final int unlockedCount;
  final int materialCraftableCount;
  final String description;
}

class DiscoveredPotionRecipeView {
  const DiscoveredPotionRecipeView({
    required this.potionId,
    required this.title,
    required this.qualityLabel,
    required this.traitHint,
    required this.traits,
    required this.maxCraftableCount,
    required this.craftableNow,
    required this.queueFull,
  });

  final String potionId;
  final String title;
  final String qualityLabel;
  final String traitHint;
  final Map<String, double> traits;
  final int maxCraftableCount;
  final bool craftableNow;
  final bool queueFull;
}

class WorkshopMaterialCraftRecipeView {
  const WorkshopMaterialCraftRecipeView({
    required this.recipeId,
    required this.title,
    required this.costHint,
    required this.resultMaterialId,
    required this.resultQuantity,
    required this.durationLabel,
    required this.materialCosts,
    required this.maxCraftableCount,
    required this.craftableNow,
    required this.queueFull,
  });

  final String recipeId;
  final String title;
  final String costHint;
  final String resultMaterialId;
  final int resultQuantity;
  final String durationLabel;
  final List<WorkshopMaterialCraftCostView> materialCosts;
  final int maxCraftableCount;
  final bool craftableNow;
  final bool queueFull;
}

class WorkshopMaterialCraftCostView {
  const WorkshopMaterialCraftCostView({
    required this.materialId,
    required this.name,
    required this.requiredQuantity,
    required this.ownedQuantity,
  });

  final String materialId;
  final String name;
  final int requiredQuantity;
  final int ownedQuantity;
}

final Provider<List<PotionQueueOptionView>>
workshopPotionQueueOptionViewsProvider = Provider<List<PotionQueueOptionView>>((
  Ref ref,
) {
  final List<PotionBlueprint> catalog = ref.watch(potionsProvider);
  final Set<String> unlockFlags = ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.battle.progress.unlockFlags,
    ),
  );
  final Map<String, double> extractedInventory = ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.extractedTraitInventory,
    ),
  );
  final int queueLength = ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.queue.length,
    ),
  );
  final int queueCapacity = ref.watch(workshopQueueCapacityProvider);
  final PotionCraftingService craftingService = ref.watch(
    potionCraftingServiceProvider,
  );
  final bool queueFull = queueLength >= queueCapacity;

  bool isUnlocked(PotionBlueprint potion) {
    final int index = catalog.indexWhere(
      (PotionBlueprint entry) => entry.id == potion.id,
    );
    if (index < 10) {
      return true;
    }
    if (index < 13) {
      return unlockFlags.contains('potion_special_1');
    }
    return unlockFlags.contains('potion_special_2');
  }

  String lockReason(PotionBlueprint potion) {
    final int index = catalog.indexWhere(
      (PotionBlueprint entry) => entry.id == potion.id,
    );
    if (index < 10) {
      return '';
    }
    if (index < 13) {
      return '3단계 클리어 필요';
    }
    return '5단계 클리어 필요';
  }

  int potionOrder(String id) {
    final String numericSuffix = id.split('_').last;
    return int.tryParse(numericSuffix) ?? 999999;
  }

  final List<PotionQueueOptionView> views = catalog.map((
    PotionBlueprint potion,
  ) {
    final bool unlocked = isUnlocked(potion);
    final int maxCraftableCount = craftingService.maxCraftableRepeatCount(
      blueprint: potion,
      extractedInventory: extractedInventory,
    );
    final bool craftableNow = maxCraftableCount > 0;
    return PotionQueueOptionView(
      potionId: potion.id,
      title: potion.name,
      unlocked: unlocked,
      lockReason: unlocked ? '' : lockReason(potion),
      craftableNow: unlocked && craftableNow,
      maxCraftableCount: unlocked ? maxCraftableCount : 0,
      materialHint: !unlocked
          ? lockReason(potion)
          : (craftableNow ? '최대 $maxCraftableCount회 제작 가능' : '원소 부족'),
      queueFull: queueFull,
    );
  }).toList();

  views.sort((PotionQueueOptionView left, PotionQueueOptionView right) {
    if (left.unlocked == right.unlocked) {
      return potionOrder(left.potionId).compareTo(potionOrder(right.potionId));
    }
    return left.unlocked ? -1 : 1;
  });
  return views;
});

final Provider<List<DiscoveredPotionRecipeView>>
workshopDiscoveredPotionRecipeViewsProvider =
    Provider<List<DiscoveredPotionRecipeView>>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final List<PotionBlueprint> potions = ref.watch(potionsProvider);
      final List<TraitUnit> traits = ref.watch(traitsProvider);
      final int queueCapacity = ref.watch(workshopQueueCapacityProvider);
      final bool queueFull = state.workshop.queue.length >= queueCapacity;
      final Map<String, PotionBlueprint> potionMap = <String, PotionBlueprint>{
        for (final PotionBlueprint potion in potions) potion.id: potion,
      };
      final Map<String, String> traitNames = <String, String>{
        for (final TraitUnit trait in traits) trait.id: trait.name,
      };

      final List<DiscoveredPotionRecipeView> views = state
          .workshop
          .discoveredPotionRecipes
          .values
          .map((DiscoveredPotionRecipe recipe) {
            final int maxCraftableCount = _traitRecipeMaxCraftableCount(
              requiredTraits: recipe.discoveredTraits,
              extractedInventory: state.workshop.extractedTraitInventory,
            );
            return DiscoveredPotionRecipeView(
              potionId: recipe.potionId,
              title: potionMap[recipe.potionId]?.name ?? recipe.potionId,
              qualityLabel: recipe.bestKnownGrade.name.toUpperCase(),
              traitHint: _traitCostHint(
                recipe.discoveredTraits,
                traitNames: traitNames,
              ),
              traits: recipe.discoveredTraits,
              maxCraftableCount: maxCraftableCount,
              craftableNow: maxCraftableCount > 0 && !queueFull,
              queueFull: queueFull,
            );
          })
          .toList(growable: false);
      views.sort(
        (DiscoveredPotionRecipeView left, DiscoveredPotionRecipeView right) =>
            left.potionId.compareTo(right.potionId),
      );
      return views;
    });

final Provider<WorkshopCraftMenuSummaryView> workshopCraftMenuSummaryProvider =
    Provider<WorkshopCraftMenuSummaryView>((Ref ref) {
      final List<DiscoveredPotionRecipeView> discoveredRecipes = ref.watch(
        workshopDiscoveredPotionRecipeViewsProvider,
      );
      final List<WorkshopMaterialCraftRecipeView> materialRecipes = ref.watch(
        workshopMaterialCraftRecipeViewsProvider,
      );
      final int unlockedCount = discoveredRecipes.length;
      final int craftableCount = discoveredRecipes
          .where((entry) => entry.craftableNow)
          .length;
      final int materialCraftableCount = materialRecipes
          .where((entry) => entry.craftableNow)
          .length;
      final String description = unlockedCount == 0
          ? '양조 가능한 포션 없음'
          : '양조 $craftableCount종 / 제작 $materialCraftableCount종';
      return WorkshopCraftMenuSummaryView(
        craftableCount: craftableCount,
        unlockedCount: unlockedCount,
        materialCraftableCount: materialCraftableCount,
        description: description,
      );
    });

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
            final int maxCraftableCount = _materialRecipeMaxCraftableCount(
              recipe,
              state,
            );
            final MapEntry<String, int> result =
                recipe.resultMaterials.entries.first;
            return WorkshopMaterialCraftRecipeView(
              recipeId: recipe.id,
              title: recipe.name,
              costHint: _craftRecipeCostHint(
                recipe,
                materialNames: materialNames,
                traitNames: traitNames,
              ),
              resultMaterialId: result.key,
              resultQuantity: result.value,
              durationLabel: _durationLabel(recipe.duration),
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

int _materialRecipeMaxCraftableCount(
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

int _minInt(int left, int right) {
  return left < right ? left : right;
}

int _traitRecipeMaxCraftableCount({
  required Map<String, double> requiredTraits,
  required Map<String, double> extractedInventory,
}) {
  if (requiredTraits.isEmpty) {
    return 0;
  }
  final List<int> counts = requiredTraits.entries
      .where((MapEntry<String, double> entry) => entry.value > 0)
      .map(
        (MapEntry<String, double> entry) =>
            ((extractedInventory[entry.key] ?? 0) / entry.value).floor(),
      )
      .toList();
  if (counts.isEmpty) {
    return 0;
  }
  return counts.reduce(_minInt);
}

String _traitCostHint(
  Map<String, double> requiredTraits, {
  required Map<String, String> traitNames,
}) {
  if (requiredTraits.isEmpty) {
    return '필요 원소 없음';
  }
  return requiredTraits.entries
      .map(
        (MapEntry<String, double> entry) =>
            '${traitNames[entry.key] ?? entry.key} 원소 ${entry.value.toStringAsFixed(2)}',
      )
      .join(', ');
}

String _craftRecipeCostHint(
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

String _durationLabel(Duration duration) {
  final int minutes = duration.inMinutes;
  final int seconds = duration.inSeconds.remainder(60);
  if (minutes > 0 && seconds > 0) {
    return '$minutes분 $seconds초';
  }
  if (minutes > 0) {
    return '$minutes분';
  }
  return '$seconds초';
}
