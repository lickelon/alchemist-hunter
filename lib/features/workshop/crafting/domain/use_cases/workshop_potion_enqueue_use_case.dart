part of 'workshop_craft_enqueue_use_case.dart';

mixin _WorkshopPotionEnqueueMixin on _CraftEnqueueSupportMixin {
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

    final CraftedPotion craftedPotion = craftingService.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: blueprint.targetTraits,
      recipeRules: potionCatalogRepository.recipeRules(),
      qualityRule: potionCatalogRepository.qualityRule(),
    );
    final Duration duration = Duration(seconds: 15 * repeatCount);
    final bool activeJobExists = hasActiveJob(state.workshop.queue);
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.microsecondsSinceEpoch}_craft_${blueprint.id}',
      type: WorkshopJobType.craft,
      status: activeJobExists
          ? QueueJobStatus.queued
          : QueueJobStatus.processing,
      queuedAt: now,
      startedAt: activeJobExists ? null : now,
      duration: duration,
      eta: duration,
      title: blueprint.name,
      potionId: potionId,
      repeatCount: repeatCount,
      reservedTraits: requiredTraits,
      completedPotionStackKey: potionStackKey(craftedPotion),
      completedPotion: craftedPotion,
    );

    return state.copyWith(
      workshop: state.workshop.copyWith(
        extractedTraitInventory: consumeTraits(
          inventory: state.workshop.extractedTraitInventory,
          costs: requiredTraits,
        ),
        queue: <CraftQueueJob>[...state.workshop.queue, job],
      ),
    );
  }
}
