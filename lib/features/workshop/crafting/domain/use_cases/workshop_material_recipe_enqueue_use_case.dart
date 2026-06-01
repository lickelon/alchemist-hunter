part of 'workshop_craft_enqueue_use_case.dart';

mixin _WorkshopMaterialRecipeEnqueueMixin on _CraftEnqueueSupportMixin {
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
    final int capacity = queueCapacity(
      state: state,
      workshopSkillTreeRepository: workshopSkillTreeRepository,
      workshopSkillTreeService: workshopSkillTreeService,
      workshopSupportService: workshopSupportService,
    );
    if (!canEnqueue(
      state: state,
      repeatCount: repeatCount,
      queueCapacity: capacity,
    )) {
      return state;
    }

    final WorkshopCraftRecipe? recipe = craftRecipeRepository.findRecipeById(
      recipeId,
    );
    if (recipe == null || recipe.resultMaterials.isEmpty) {
      return state;
    }

    final int essenceCost = recipe.essenceCost * repeatCount;
    final int dustCost = recipe.arcaneDustCost * repeatCount;
    if (state.player.essence < essenceCost ||
        state.player.arcaneDust < dustCost) {
      return state;
    }

    final Map<String, int> reservedMaterials = scaledMaterialCosts(
      recipe.materialCosts,
      repeatCount,
    );
    if (!hasEnoughMaterials(
      inventory: state.player.materialInventory,
      costs: reservedMaterials,
    )) {
      return state;
    }

    final Map<String, double> reservedTraits = scaledTraitCosts(
      recipe.traitCosts,
      repeatCount,
    );
    if (!hasEnoughTraits(
      inventory: state.workshop.extractedTraitInventory,
      costs: reservedTraits,
    )) {
      return state;
    }

    final Map<String, int> completedMaterials = scaledMaterialCosts(
      recipe.resultMaterials,
      repeatCount,
    );
    final Duration duration = recipe.duration * repeatCount;
    final bool activeJobExists = hasActiveJob(state.workshop.queue);
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.microsecondsSinceEpoch}_craft_${recipe.id}',
      type: WorkshopJobType.craft,
      status: activeJobExists
          ? QueueJobStatus.queued
          : QueueJobStatus.processing,
      queuedAt: now,
      startedAt: activeJobExists ? null : now,
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
        essence: state.player.essence - essenceCost,
        arcaneDust: state.player.arcaneDust - dustCost,
        materialInventory: consumeMaterials(
          inventory: state.player.materialInventory,
          costs: reservedMaterials,
        ),
      ),
      workshop: state.workshop.copyWith(
        extractedTraitInventory: consumeTraits(
          inventory: state.workshop.extractedTraitInventory,
          costs: reservedTraits,
        ),
        queue: <CraftQueueJob>[...state.workshop.queue, job],
      ),
    );
  }
}
