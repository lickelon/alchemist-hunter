part of 'workshop_craft_queue_controller.dart';

mixin _WorkshopCraftQueueEnqueueController
    on _WorkshopCraftQueueControllerSupport {
  WorkshopCraftSubmitResult enqueuePotion(String potionId, int repeatCount) {
    final SessionState current = _session.snapshot();
    if (current.workshop.queue.length >= queueCapacity(current)) {
      _session.appendLog('작업실 큐 가득 참 / $potionId x$repeatCount');
      return WorkshopCraftSubmitResult.queueFull;
    }
    final SessionState nextState = _craftEnqueueUseCase.enqueuePotion(
      state: current,
      potionId: potionId,
      repeatCount: repeatCount,
      now: _session.now(),
      craftingService: _craftingService,
      potionCatalogRepository: _potionCatalogRepository,
      workshopSkillTreeRepository: _workshopSkillTreeRepository,
      workshopSkillTreeService: _workshopSkillTreeService,
      workshopSupportService: _workshopSupportService,
    );
    if (identical(nextState, current)) {
      final PotionBlueprint? blueprint = _potionCatalogRepository
          .findPotionById(potionId);
      if (blueprint != null &&
          repeatCount > 0 &&
          !_craftingService.canCraftRepeatCount(
            blueprint: blueprint,
            extractedInventory: current.workshop.extractedTraitInventory,
            repeatCount: repeatCount,
          )) {
        _session.appendLog('원소 부족 / 제조 $potionId x$repeatCount');
        return WorkshopCraftSubmitResult.elementMissing;
      }
      _session.appendLog('제조 등록 실패 / $potionId x$repeatCount');
      return WorkshopCraftSubmitResult.failed;
    }
    applyState(nextState, logMessage: '제조 등록 / $potionId x$repeatCount');
    return WorkshopCraftSubmitResult.success;
  }

  WorkshopCraftSubmitResult enqueueMaterialRecipe(
    String recipeId, {
    int repeatCount = 1,
  }) {
    final SessionState current = _session.snapshot();
    if (current.workshop.queue.length >= queueCapacity(current)) {
      _session.appendLog('작업실 큐 가득 참 / $recipeId x$repeatCount');
      return WorkshopCraftSubmitResult.queueFull;
    }
    final SessionState nextState = _craftEnqueueUseCase.enqueueMaterialRecipe(
      state: current,
      recipeId: recipeId,
      repeatCount: repeatCount,
      now: _session.now(),
      craftRecipeRepository: _craftRecipeRepository,
      workshopSkillTreeRepository: _workshopSkillTreeRepository,
      workshopSkillTreeService: _workshopSkillTreeService,
      workshopSupportService: _workshopSupportService,
    );
    if (identical(nextState, current)) {
      _session.appendLog('제작 재료 부족 / $recipeId x$repeatCount');
      return WorkshopCraftSubmitResult.resourceMissing;
    }
    applyState(nextState, logMessage: '제작 등록 / $recipeId x$repeatCount');
    return WorkshopCraftSubmitResult.success;
  }

  WorkshopCraftSubmitResult enqueueBrew(
    Map<String, double> inputTraits, {
    int repeatCount = 1,
  }) {
    final SessionState current = _session.snapshot();
    if (current.workshop.queue.length >= queueCapacity(current)) {
      _session.appendLog('작업실 큐 가득 참 / 양조 실험 x$repeatCount');
      return WorkshopCraftSubmitResult.queueFull;
    }
    final SessionState nextState = _craftEnqueueUseCase.enqueueBrew(
      state: current,
      inputTraits: inputTraits,
      repeatCount: repeatCount,
      now: _session.now(),
      craftingService: _craftingService,
      potionCatalogRepository: _potionCatalogRepository,
      workshopSkillTreeRepository: _workshopSkillTreeRepository,
      workshopSkillTreeService: _workshopSkillTreeService,
      workshopSupportService: _workshopSupportService,
    );
    if (identical(nextState, current)) {
      final bool enoughTraits = hasEnoughTraits(
        inputTraits,
        current.workshop.extractedTraitInventory,
        repeatCount,
      );
      _session.appendLog(
        enoughTraits ? '양조 등록 실패' : '원소 부족 / 양조 x$repeatCount',
      );
      return enoughTraits
          ? WorkshopCraftSubmitResult.failed
          : WorkshopCraftSubmitResult.elementMissing;
    }
    final CraftQueueJob job = nextState.workshop.queue.last;
    applyState(
      nextState,
      logMessage: '양조 등록 / ${job.potionId ?? 'unknown'} x$repeatCount',
    );
    return WorkshopCraftSubmitResult.success;
  }
}
