part of 'workshop_craft_enqueue_use_case.dart';

mixin _WorkshopBrewEnqueueMixin on _CraftEnqueueSupportMixin {
  SessionState enqueueBrew({
    required SessionState state,
    required Map<String, double> inputTraits,
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

    final Map<String, double> costs = positiveTraitCosts(inputTraits);
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

    final Map<String, double> reservedTraits = scaledTraitCosts(
      costs,
      repeatCount,
    );
    if (!hasEnoughTraits(
      inventory: state.workshop.extractedTraitInventory,
      costs: reservedTraits,
    )) {
      return state;
    }

    final CraftedPotion craftedPotion = craftingService.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: costs,
      recipeRules: potionCatalogRepository.recipeRules(),
      qualityRule: potionCatalogRepository.qualityRule(),
    );
    final Duration duration = Duration(seconds: 15 * repeatCount);
    final bool activeJobExists = hasActiveJob(state.workshop.queue);
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.microsecondsSinceEpoch}_brew_${craftedPotion.typePotionId}',
      type: WorkshopJobType.craft,
      status: activeJobExists
          ? QueueJobStatus.queued
          : QueueJobStatus.processing,
      queuedAt: now,
      startedAt: activeJobExists ? null : now,
      duration: duration,
      eta: duration,
      title: blueprint.name,
      potionId: craftedPotion.typePotionId,
      repeatCount: repeatCount,
      reservedTraits: reservedTraits,
      completedPotionStackKey: potionStackKey(craftedPotion),
      completedPotion: craftedPotion,
    );

    return state.copyWith(
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
