import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_craft_queue_use_case.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

enum WorkshopCraftSubmitResult {
  success,
  queueFull,
  failed,
}

class WorkshopCraftQueueController {
  WorkshopCraftQueueController(
    this._session,
    this._craftingService, {
    WorkshopCraftQueueUseCase craftQueueDomain =
        const WorkshopCraftQueueUseCase(),
    required PotionCatalogRepository potionCatalogRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
  }) : _craftQueueDomain = craftQueueDomain,
       _potionCatalogRepository = potionCatalogRepository,
       _workshopSkillTreeRepository = workshopSkillTreeRepository,
       _workshopSkillTreeService = workshopSkillTreeService,
       _workshopSupportService = workshopSupportService;

  final SessionController _session;
  final PotionCraftingService _craftingService;
  final WorkshopCraftQueueUseCase _craftQueueDomain;
  final PotionCatalogRepository _potionCatalogRepository;
  final WorkshopSkillTreeRepository _workshopSkillTreeRepository;
  final WorkshopSkillTreeService _workshopSkillTreeService;
  final WorkshopSupportService _workshopSupportService;

  WorkshopCraftSubmitResult enqueuePotion(String potionId, int repeatCount) {
    final SessionState current = _session.snapshot();
    final int queueCapacity = _workshopSkillTreeService.craftQueueCapacity(
          current,
          _workshopSkillTreeRepository.nodes(),
        ) +
        _workshopSupportService.craftQueueCapacityBonus(current);
    if (current.workshop.queue.length >= queueCapacity) {
      _session.appendLog('작업실 큐 가득 참 / $potionId x$repeatCount');
      return WorkshopCraftSubmitResult.queueFull;
    }
    final SessionState nextState = _craftQueueDomain.enqueuePotion(
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
      _session.appendLog('제조 등록 실패 / $potionId x$repeatCount');
      return WorkshopCraftSubmitResult.failed;
    }
    _apply(
      nextState,
      logMessage: '제조 등록 / $potionId x$repeatCount',
    );
    return WorkshopCraftSubmitResult.success;
  }

  void claimPending() {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _craftQueueDomain.claimPending(state: current);
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? '수령 가능한 작업실 보상 없음'
          : '작업실 보상 수령',
    );
  }

  void claimJob(String jobId) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _craftQueueDomain.claimJob(
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
}

final Provider<WorkshopCraftQueueController>
workshopCraftQueueControllerProvider = Provider<WorkshopCraftQueueController>((
  Ref ref,
) {
  return WorkshopCraftQueueController(
    ref.read(sessionControllerProvider.notifier),
    ref.read(potionCraftingServiceProvider),
    potionCatalogRepository: ref.read(potionCatalogRepositoryProvider),
    workshopSkillTreeRepository: ref.read(workshopSkillTreeRepositoryProvider),
    workshopSkillTreeService: ref.read(workshopSkillTreeServiceProvider),
    workshopSupportService: ref.read(workshopSupportServiceProvider),
  );
});
