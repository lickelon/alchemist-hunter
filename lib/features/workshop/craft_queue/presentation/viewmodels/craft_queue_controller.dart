import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/use_cases/workshop_craft_enqueue_use_case.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/domain/use_cases/workshop_queue_claim_use_case.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_discovery_service.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafting_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/presentation/viewmodels/workshop_skill_tree_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_service_providers.dart';

enum WorkshopCraftSubmitResult {
  success,
  queueFull,
  elementMissing,
  resourceMissing,
  failed,
}

class WorkshopCraftQueueController {
  WorkshopCraftQueueController(
    this._session,
    this._craftingService, {
    WorkshopCraftEnqueueUseCase craftEnqueueUseCase =
        const WorkshopCraftEnqueueUseCase(),
    WorkshopQueueClaimUseCase queueClaimUseCase =
        const WorkshopQueueClaimUseCase(),
    required PotionCatalogRepository potionCatalogRepository,
    required WorkshopCraftRecipeRepository craftRecipeRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
    required PotionDiscoveryService discoveryService,
  }) : _craftEnqueueUseCase = craftEnqueueUseCase,
       _queueClaimUseCase = queueClaimUseCase,
       _potionCatalogRepository = potionCatalogRepository,
       _craftRecipeRepository = craftRecipeRepository,
       _workshopSkillTreeRepository = workshopSkillTreeRepository,
       _workshopSkillTreeService = workshopSkillTreeService,
       _workshopSupportService = workshopSupportService,
       _discoveryService = discoveryService;

  final SessionController _session;
  final PotionCraftingService _craftingService;
  final WorkshopCraftEnqueueUseCase _craftEnqueueUseCase;
  final WorkshopQueueClaimUseCase _queueClaimUseCase;
  final PotionCatalogRepository _potionCatalogRepository;
  final WorkshopCraftRecipeRepository _craftRecipeRepository;
  final WorkshopSkillTreeRepository _workshopSkillTreeRepository;
  final WorkshopSkillTreeService _workshopSkillTreeService;
  final WorkshopSupportService _workshopSupportService;
  final PotionDiscoveryService _discoveryService;

  WorkshopCraftSubmitResult enqueuePotion(String potionId, int repeatCount) {
    final SessionState current = _session.snapshot();
    final int queueCapacity =
        _workshopSkillTreeService.craftQueueCapacity(
          current,
          _workshopSkillTreeRepository.nodes(),
        ) +
        _workshopSupportService.craftQueueCapacityBonus(current);
    if (current.workshop.queue.length >= queueCapacity) {
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
    _apply(nextState, logMessage: '제조 등록 / $potionId x$repeatCount');
    return WorkshopCraftSubmitResult.success;
  }

  WorkshopCraftSubmitResult enqueueMaterialRecipe(
    String recipeId, {
    int repeatCount = 1,
  }) {
    final SessionState current = _session.snapshot();
    final int queueCapacity =
        _workshopSkillTreeService.craftQueueCapacity(
          current,
          _workshopSkillTreeRepository.nodes(),
        ) +
        _workshopSupportService.craftQueueCapacityBonus(current);
    if (current.workshop.queue.length >= queueCapacity) {
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
    _apply(nextState, logMessage: '제작 등록 / $recipeId x$repeatCount');
    return WorkshopCraftSubmitResult.success;
  }

  WorkshopCraftSubmitResult enqueueBrew(
    Map<String, double> inputTraits, {
    int repeatCount = 1,
  }) {
    final SessionState current = _session.snapshot();
    final int queueCapacity =
        _workshopSkillTreeService.craftQueueCapacity(
          current,
          _workshopSkillTreeRepository.nodes(),
        ) +
        _workshopSupportService.craftQueueCapacityBonus(current);
    if (current.workshop.queue.length >= queueCapacity) {
      _session.appendLog('작업실 큐 가득 참 / 양조 실험 x$repeatCount');
      return WorkshopCraftSubmitResult.queueFull;
    }
    final SessionState nextState = _craftEnqueueUseCase.enqueueBrew(
      state: current,
      inputTraits: inputTraits,
      repeatCount: repeatCount,
      now: _session.now(),
      craftingService: _craftingService,
      discoveryService: _discoveryService,
      potionCatalogRepository: _potionCatalogRepository,
      workshopSkillTreeRepository: _workshopSkillTreeRepository,
      workshopSkillTreeService: _workshopSkillTreeService,
      workshopSupportService: _workshopSupportService,
    );
    if (identical(nextState, current)) {
      final bool hasEnoughTraits = _hasEnoughTraits(
        inputTraits,
        current.workshop.extractedTraitInventory,
        repeatCount,
      );
      _session.appendLog(
        hasEnoughTraits ? '양조 실험 실패 / 조합 불명' : '원소 부족 / 양조 실험 x$repeatCount',
      );
      return hasEnoughTraits
          ? WorkshopCraftSubmitResult.failed
          : WorkshopCraftSubmitResult.elementMissing;
    }
    final CraftQueueJob job = nextState.workshop.queue.last;
    _apply(
      nextState,
      logMessage: '양조 실험 등록 / ${job.potionId ?? 'unknown'} x$repeatCount',
    );
    return WorkshopCraftSubmitResult.success;
  }

  void claimPending() {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _queueClaimUseCase.claimPending(
      state: current,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? '수령 가능한 작업실 보상 없음'
          : '작업실 보상 수령',
    );
  }

  void claimJob(String jobId) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _queueClaimUseCase.claimJob(
      state: current,
      jobId: jobId,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? '수령 가능한 큐 작업 없음 / $jobId'
          : '큐 작업 수령 / $jobId',
    );
  }

  void _apply(SessionState nextState, {String? logMessage}) {
    _session.applyState(nextState);
    if (logMessage != null) {
      _session.appendLog(logMessage);
    }
  }

  bool _hasEnoughTraits(
    Map<String, double> costs,
    Map<String, double> inventory,
    int repeatCount,
  ) {
    if (repeatCount <= 0) {
      return false;
    }
    final Iterable<MapEntry<String, double>> positiveCosts = costs.entries
        .where((MapEntry<String, double> entry) => entry.value > 0);
    if (positiveCosts.isEmpty) {
      return false;
    }
    return positiveCosts.every((MapEntry<String, double> entry) {
      return (inventory[entry.key] ?? 0) + 0.0001 >= entry.value * repeatCount;
    });
  }
}

final Provider<WorkshopCraftQueueController>
workshopCraftQueueControllerProvider = Provider<WorkshopCraftQueueController>((
  Ref ref,
) {
  return WorkshopCraftQueueController(
    ref.read(sessionControllerProvider.notifier),
    ref.read(potionCraftingServiceProvider),
    potionCatalogRepository: ref.read(potionCatalogRepositoryProvider),
    craftRecipeRepository: ref.read(workshopCraftRecipeRepositoryProvider),
    workshopSkillTreeRepository: ref.read(workshopSkillTreeRepositoryProvider),
    workshopSkillTreeService: ref.read(workshopSkillTreeServiceProvider),
    workshopSupportService: ref.read(workshopSupportServiceProvider),
    discoveryService: ref.read(potionDiscoveryServiceProvider),
  );
});
