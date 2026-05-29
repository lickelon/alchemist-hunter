import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';

class WorkshopCraftEnqueueUseCase {
  const WorkshopCraftEnqueueUseCase();

  SessionState enqueuePotion({
    required SessionState state,
    required String potionId,
    required int repeatCount,
    required DateTime now,
    required PotionCraftingService craftingService,
    required PotionCatalogRepository potionCatalogRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
  }) {
    final int queueCapacity =
        workshopSkillTreeService.craftQueueCapacity(
          state,
          workshopSkillTreeRepository.nodes(),
        ) +
        workshopSupportService.craftQueueCapacityBonus(state);
    if (repeatCount <= 0 || state.workshop.queue.length >= queueCapacity) {
      return state;
    }

    final PotionBlueprint? blueprint = potionCatalogRepository.findPotionById(
      potionId,
    );
    if (blueprint == null) {
      return state;
    }

    final Map<String, double>? requiredTraits = craftingService
        .requiredTraitsForRepeatCount(
          blueprint: blueprint,
          repeatCount: repeatCount,
        );
    if (requiredTraits == null ||
        !craftingService.canCraftRepeatCount(
          blueprint: blueprint,
          extractedInventory: state.workshop.extractedTraitInventory,
          repeatCount: repeatCount,
        )) {
      return state;
    }

    final Map<String, double> nextExtractedInventory = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    requiredTraits.forEach((String key, double value) {
      final double nextValue = (nextExtractedInventory[key] ?? 0) - value;
      if (nextValue <= 0.0001) {
        nextExtractedInventory.remove(key);
      } else {
        nextExtractedInventory[key] = nextValue;
      }
    });

    final CraftedPotion craftedPotion = craftingService.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: blueprint.targetTraits,
      recipeRules: potionCatalogRepository.recipeRules(),
      branchRules: potionCatalogRepository.recipeBranchRules(),
      qualityRule: potionCatalogRepository.qualityRule(),
    );
    final String stackKey =
        '${craftedPotion.typePotionId}|${craftedPotion.qualityGrade.name}';
    final Duration duration = Duration(seconds: 15 * repeatCount);
    final bool hasActiveJob = _hasActiveJob(state.workshop.queue);
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.microsecondsSinceEpoch}_craft_${blueprint.id}',
      type: WorkshopJobType.craft,
      status: hasActiveJob ? QueueJobStatus.queued : QueueJobStatus.processing,
      queuedAt: now,
      startedAt: hasActiveJob ? null : now,
      duration: duration,
      eta: duration,
      title: blueprint.name,
      potionId: potionId,
      repeatCount: repeatCount,
      reservedTraits: requiredTraits,
      completedPotionStackKey: stackKey,
      completedPotion: craftedPotion,
    );

    return state.copyWith(
      workshop: state.workshop.copyWith(
        extractedTraitInventory: nextExtractedInventory,
        queue: <CraftQueueJob>[...state.workshop.queue, job],
      ),
    );
  }

  SessionState enqueueMaterialRecipe({
    required SessionState state,
    required String recipeId,
    required DateTime now,
    required WorkshopCraftRecipeRepository craftRecipeRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
  }) {
    final int queueCapacity =
        workshopSkillTreeService.craftQueueCapacity(
          state,
          workshopSkillTreeRepository.nodes(),
        ) +
        workshopSupportService.craftQueueCapacityBonus(state);
    if (state.workshop.queue.length >= queueCapacity) {
      return state;
    }

    final WorkshopCraftRecipe? recipe = craftRecipeRepository.findRecipeById(
      recipeId,
    );
    if (recipe == null || recipe.resultMaterials.isEmpty) {
      return state;
    }
    if (state.player.essence < recipe.essenceCost ||
        state.player.arcaneDust < recipe.arcaneDustCost) {
      return state;
    }

    final Map<String, int> materials = <String, int>{
      ...state.player.materialInventory,
    };
    for (final MapEntry<String, int> cost in recipe.materialCosts.entries) {
      if ((materials[cost.key] ?? 0) < cost.value) {
        return state;
      }
    }

    final Map<String, double> traits = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    for (final MapEntry<String, double> cost in recipe.traitCosts.entries) {
      if ((traits[cost.key] ?? 0) < cost.value) {
        return state;
      }
    }

    for (final MapEntry<String, int> cost in recipe.materialCosts.entries) {
      final int nextValue = (materials[cost.key] ?? 0) - cost.value;
      if (nextValue <= 0) {
        materials.remove(cost.key);
      } else {
        materials[cost.key] = nextValue;
      }
    }
    for (final MapEntry<String, double> cost in recipe.traitCosts.entries) {
      final double nextValue = (traits[cost.key] ?? 0) - cost.value;
      if (nextValue <= 0.0001) {
        traits.remove(cost.key);
      } else {
        traits[cost.key] = nextValue;
      }
    }

    final bool hasActiveJob = _hasActiveJob(state.workshop.queue);
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.microsecondsSinceEpoch}_craft_${recipe.id}',
      type: WorkshopJobType.craft,
      status: hasActiveJob ? QueueJobStatus.queued : QueueJobStatus.processing,
      queuedAt: now,
      startedAt: hasActiveJob ? null : now,
      duration: recipe.duration,
      eta: recipe.duration,
      title: recipe.name,
      recipeId: recipe.id,
      reservedMaterials: recipe.materialCosts,
      reservedTraits: recipe.traitCosts,
      completedMaterials: recipe.resultMaterials,
    );

    return state.copyWith(
      player: state.player.copyWith(
        essence: state.player.essence - recipe.essenceCost,
        arcaneDust: state.player.arcaneDust - recipe.arcaneDustCost,
        materialInventory: materials,
      ),
      workshop: state.workshop.copyWith(
        extractedTraitInventory: traits,
        queue: <CraftQueueJob>[...state.workshop.queue, job],
      ),
    );
  }

  bool _hasActiveJob(List<CraftQueueJob> jobs) {
    return jobs.any(
      (CraftQueueJob job) => job.status != QueueJobStatus.completed,
    );
  }
}
