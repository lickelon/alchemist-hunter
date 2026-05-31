import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_discovery_service.dart';
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
    required int repeatCount,
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
    if (repeatCount <= 0 || state.workshop.queue.length >= queueCapacity) {
      return state;
    }

    final WorkshopCraftRecipe? recipe = craftRecipeRepository.findRecipeById(
      recipeId,
    );
    if (recipe == null || recipe.resultMaterials.isEmpty) {
      return state;
    }
    if (state.player.essence < recipe.essenceCost * repeatCount ||
        state.player.arcaneDust < recipe.arcaneDustCost * repeatCount) {
      return state;
    }

    final Map<String, int> materials = <String, int>{
      ...state.player.materialInventory,
    };
    for (final MapEntry<String, int> cost in recipe.materialCosts.entries) {
      if ((materials[cost.key] ?? 0) < cost.value * repeatCount) {
        return state;
      }
    }

    final Map<String, double> traits = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    for (final MapEntry<String, double> cost in recipe.traitCosts.entries) {
      if ((traits[cost.key] ?? 0) < cost.value * repeatCount) {
        return state;
      }
    }

    for (final MapEntry<String, int> cost in recipe.materialCosts.entries) {
      final int nextValue =
          (materials[cost.key] ?? 0) - cost.value * repeatCount;
      if (nextValue <= 0) {
        materials.remove(cost.key);
      } else {
        materials[cost.key] = nextValue;
      }
    }
    for (final MapEntry<String, double> cost in recipe.traitCosts.entries) {
      final double nextValue =
          (traits[cost.key] ?? 0) - cost.value * repeatCount;
      if (nextValue <= 0.0001) {
        traits.remove(cost.key);
      } else {
        traits[cost.key] = nextValue;
      }
    }

    final Map<String, int> reservedMaterials = <String, int>{
      for (final MapEntry<String, int> entry in recipe.materialCosts.entries)
        entry.key: entry.value * repeatCount,
    };
    final Map<String, double> reservedTraits = <String, double>{
      for (final MapEntry<String, double> entry in recipe.traitCosts.entries)
        entry.key: entry.value * repeatCount,
    };
    final Map<String, int> completedMaterials = <String, int>{
      for (final MapEntry<String, int> entry in recipe.resultMaterials.entries)
        entry.key: entry.value * repeatCount,
    };
    final Duration duration = recipe.duration * repeatCount;
    final bool hasActiveJob = _hasActiveJob(state.workshop.queue);
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.microsecondsSinceEpoch}_craft_${recipe.id}',
      type: WorkshopJobType.craft,
      status: hasActiveJob ? QueueJobStatus.queued : QueueJobStatus.processing,
      queuedAt: now,
      startedAt: hasActiveJob ? null : now,
      duration: duration,
      eta: duration,
      title: recipe.name,
      repeatCount: repeatCount,
      recipeId: recipe.id,
      reservedMaterials: reservedMaterials,
      reservedTraits: reservedTraits,
      completedMaterials: completedMaterials,
    );

    return state.copyWith(
      player: state.player.copyWith(
        essence: state.player.essence - recipe.essenceCost * repeatCount,
        arcaneDust:
            state.player.arcaneDust - recipe.arcaneDustCost * repeatCount,
        materialInventory: materials,
      ),
      workshop: state.workshop.copyWith(
        extractedTraitInventory: traits,
        queue: <CraftQueueJob>[...state.workshop.queue, job],
      ),
    );
  }

  SessionState enqueueBrew({
    required SessionState state,
    required Map<String, double> inputTraits,
    required int repeatCount,
    required DateTime now,
    required PotionCraftingService craftingService,
    required PotionDiscoveryService discoveryService,
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

    final Map<String, double> costs = _positiveTraitCosts(inputTraits);
    if (costs.isEmpty) {
      return state;
    }
    final double totalCost = costs.values.fold(
      0,
      (double previous, double amount) => previous + amount,
    );
    if ((totalCost - 1).abs() > 0.0001) {
      return state;
    }

    final String? potionId = craftingService.resolvePotionTypeFromTraits(
      inputTraits: costs,
      recipeRules: potionCatalogRepository.recipeRules(),
      branchRules: potionCatalogRepository.recipeBranchRules(),
    );
    if (potionId == null) {
      return state;
    }

    final PotionBlueprint? blueprint = potionCatalogRepository.findPotionById(
      potionId,
    );
    if (blueprint == null) {
      return state;
    }

    final Map<String, double> traits = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    for (final MapEntry<String, double> cost in costs.entries) {
      if ((traits[cost.key] ?? 0) < cost.value * repeatCount) {
        return state;
      }
    }
    for (final MapEntry<String, double> cost in costs.entries) {
      final double nextValue =
          (traits[cost.key] ?? 0) - cost.value * repeatCount;
      if (nextValue <= 0.0001) {
        traits.remove(cost.key);
      } else {
        traits[cost.key] = nextValue;
      }
    }

    final CraftedPotion craftedPotion = craftingService.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: costs,
      recipeRules: potionCatalogRepository.recipeRules(),
      branchRules: potionCatalogRepository.recipeBranchRules(),
      qualityRule: potionCatalogRepository.qualityRule(),
    );
    final String stackKey =
        '${craftedPotion.typePotionId}|${craftedPotion.qualityGrade.name}';
    final Map<String, double> reservedTraits = <String, double>{
      for (final MapEntry<String, double> entry in costs.entries)
        entry.key: entry.value * repeatCount,
    };
    final Duration duration = Duration(seconds: 15 * repeatCount);
    final bool hasActiveJob = _hasActiveJob(state.workshop.queue);
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.microsecondsSinceEpoch}_brew_${craftedPotion.typePotionId}',
      type: WorkshopJobType.craft,
      status: hasActiveJob ? QueueJobStatus.queued : QueueJobStatus.processing,
      queuedAt: now,
      startedAt: hasActiveJob ? null : now,
      duration: duration,
      eta: duration,
      title: blueprint.name,
      potionId: craftedPotion.typePotionId,
      repeatCount: repeatCount,
      reservedTraits: reservedTraits,
      completedPotionStackKey: stackKey,
      completedPotion: craftedPotion,
    );
    final WorkshopState discoveredWorkshop = discoveryService.recordDiscovery(
      workshop: state.workshop.copyWith(extractedTraitInventory: traits),
      potionId: craftedPotion.typePotionId,
      discoveredTraits: craftedPotion.traits,
      grade: craftedPotion.qualityGrade,
    );

    return state.copyWith(
      workshop: discoveredWorkshop.copyWith(
        queue: <CraftQueueJob>[...state.workshop.queue, job],
      ),
    );
  }

  bool _hasActiveJob(List<CraftQueueJob> jobs) {
    return jobs.any(
      (CraftQueueJob job) => job.status != QueueJobStatus.completed,
    );
  }

  Map<String, double> _positiveTraitCosts(Map<String, double> traits) {
    return <String, double>{
      for (final MapEntry<String, double> entry in traits.entries)
        if (entry.value > 0) entry.key: entry.value,
    };
  }
}
