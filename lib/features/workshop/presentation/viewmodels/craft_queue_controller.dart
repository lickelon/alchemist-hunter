import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_craft_queue_use_case.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/craft_queue_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

class WorkshopCraftQueueController {
  WorkshopCraftQueueController(
    this._session,
    this._queueService,
    this._craftingService, {
    WorkshopCraftQueueUseCase craftQueueDomain =
        const WorkshopCraftQueueUseCase(),
  }) : _craftQueueDomain = craftQueueDomain;

  final SessionController _session;
  final CraftQueueService _queueService;
  final PotionCraftingService _craftingService;
  final WorkshopCraftQueueUseCase _craftQueueDomain;

  void enqueuePotion(String potionId, int repeatCount) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _craftQueueDomain.enqueuePotion(
      state: current,
      potionId: potionId,
      repeatCount: repeatCount,
      now: _session.now(),
      queueService: _queueService,
      craftingService: _craftingService,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? 'Cannot enqueue $potionId x$repeatCount / materials missing'
          : 'Enqueued $potionId x$repeatCount',
    );
  }

  void tickCraftQueue() {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _craftQueueDomain.tickCraftQueue(
      state: current,
      queueService: _queueService,
      craftingService: _craftingService,
    );
    _apply(nextState, logMessage: _tickLogMessage(current, nextState));
  }

  void resumeBlocked(String jobId) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _craftQueueDomain.resumeBlockedJob(
      state: current,
      jobId: jobId,
      queueService: _queueService,
      craftingService: _craftingService,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? 'Cannot resume $jobId / materials missing'
          : 'Resumed craft job $jobId',
    );
  }

  void clearCompleted() {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _craftQueueDomain.clearCompletedJobs(
      state: current,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? null
          : 'Cleared completed craft jobs',
    );
  }

  String? _tickLogMessage(SessionState current, SessionState nextState) {
    CraftQueueJob? activeJob;
    for (final CraftQueueJob job in current.workshop.queue) {
      if (job.status == QueueJobStatus.queued ||
          job.status == QueueJobStatus.processing) {
        activeJob = job;
        break;
      }
    }
    if (activeJob != null) {
      for (final CraftQueueJob job in nextState.workshop.queue) {
        if (job.id == activeJob.id && job.status == QueueJobStatus.blocked) {
          return 'Craft paused for ${activeJob.potionId} / materials missing';
        }
      }
    }

    final int producedCount =
        _stackTotal(nextState.workshop.craftedPotionStacks) -
        _stackTotal(current.workshop.craftedPotionStacks);
    if (producedCount > 0) {
      return 'Processed queue tick / produced $producedCount';
    }
    return null;
  }

  int _stackTotal(Map<String, int> stacks) {
    return stacks.values.fold<int>(0, (int total, int value) => total + value);
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
    ref.read(craftQueueServiceProvider),
    ref.read(potionCraftingServiceProvider),
  );
});
