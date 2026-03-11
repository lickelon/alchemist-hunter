import 'dart:math';

import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/application/services/craft_queue_service.dart';
import 'package:alchemist_hunter/features/workshop/application/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/application/workshop_domain.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<CraftQueueService> craftQueueServiceProvider =
    Provider<CraftQueueService>(
      (Ref ref) => CraftQueueService(random: Random(7)),
    );

final Provider<PotionCraftingService> potionCraftingServiceProvider =
    Provider<PotionCraftingService>(
      (Ref ref) => PotionCraftingService(random: Random(13)),
    );

class WorkshopController {
  WorkshopController(
    this._session,
    this._queueService,
    this._craftingService, {
    WorkshopDomain workshopDomain = const WorkshopDomain(),
  }) : _workshopDomain = workshopDomain;

  final SessionController _session;
  final CraftQueueService _queueService;
  final PotionCraftingService _craftingService;
  final WorkshopDomain _workshopDomain;

  void enqueuePotion(String potionId, int repeatCount) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _workshopDomain.enqueuePotion(
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
    final SessionState nextState = _workshopDomain.tickCraftQueue(
      state: current,
      queueService: _queueService,
      craftingService: _craftingService,
    );
    _apply(nextState, logMessage: _tickLogMessage(current, nextState));
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
        if (job.id == activeJob.id && job.status == QueueJobStatus.failed) {
          return 'Craft blocked for ${activeJob.potionId} / materials missing';
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

final Provider<WorkshopController> workshopControllerProvider =
    Provider<WorkshopController>((Ref ref) {
      return WorkshopController(
        ref.read(sessionControllerProvider.notifier),
        ref.read(craftQueueServiceProvider),
        ref.read(potionCraftingServiceProvider),
      );
    });
