import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/craft_queue_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';

class WorkshopCraftQueueUseCase {
  const WorkshopCraftQueueUseCase();

  SessionState enqueuePotion({
    required SessionState state,
    required String potionId,
    required int repeatCount,
    required DateTime now,
    required CraftQueueService queueService,
    required PotionCraftingService craftingService,
    required PotionCatalogRepository potionCatalogRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
  }) {
    final int queueCapacity = workshopSkillTreeService.craftQueueCapacity(
      state,
      workshopSkillTreeRepository.nodes(),
    );
    if (state.workshop.queue.length >= queueCapacity) {
      return state;
    }
    final PotionBlueprint? blueprint = potionCatalogRepository.findPotionById(
      potionId,
    );
    if (blueprint == null) {
      return state;
    }
    final bool canCraft = craftingService.canCraftRepeatCount(
      blueprint: blueprint,
      extractedInventory: state.workshop.extractedTraitInventory,
      repeatCount: repeatCount,
    );
    if (!canCraft) {
      return state;
    }

    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.millisecondsSinceEpoch}',
      potionId: potionId,
      repeatCount: repeatCount,
      retryPolicy: const CraftRetryPolicy(maxRetries: 2),
      status: QueueJobStatus.queued,
      eta: const Duration(seconds: 15),
    );

    return state.copyWith(
      workshop: state.workshop.copyWith(
        queue: queueService.enqueue(state.workshop.queue, job),
      ),
    );
  }

  SessionState tickCraftQueue({
    required SessionState state,
    required CraftQueueService queueService,
    required PotionCraftingService craftingService,
    required PotionCatalogRepository potionCatalogRepository,
  }) {
    CraftQueueJob? activeJob;
    for (final CraftQueueJob job in state.workshop.queue) {
      if (job.status == QueueJobStatus.queued ||
          job.status == QueueJobStatus.processing) {
        activeJob = job;
        break;
      }
    }
    if (activeJob != null) {
      final PotionBlueprint? activeBlueprint = potionCatalogRepository
          .findPotionById(activeJob.potionId);
      if (activeBlueprint == null) {
        return state;
      }
      final bool canPrepare =
          craftingService.prepareCraftFromExtractedInventory(
            blueprint: activeBlueprint,
            extractedInventory: state.workshop.extractedTraitInventory,
          ) !=
          null;
      if (!canPrepare) {
        return state.copyWith(
          workshop: state.workshop.copyWith(
            queue: _markCraftBlocked(state.workshop.queue, activeJob.id),
          ),
        );
      }
    }

    final List<CraftQueueJob> previousQueue = state.workshop.queue;
    final List<CraftQueueJob> nextQueue = queueService.processTick(
      state.workshop.queue,
      const Duration(seconds: 15),
    );

    final Map<String, int> stacks = <String, int>{
      ...state.workshop.craftedPotionStacks,
    };
    final Map<String, CraftedPotion> details = <String, CraftedPotion>{
      ...state.workshop.craftedPotionDetails,
    };
    final Map<String, double> extractedInventory = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };

    List<CraftQueueJob> resolvedQueue = nextQueue;
    for (final CraftQueueJob job in nextQueue) {
      final CraftQueueJob? previousJob = previousQueue
          .where((CraftQueueJob candidate) => candidate.id == job.id)
          .firstOrNull;
      if (previousJob == null) {
        continue;
      }

      final int producedDelta = job.currentRepeat - previousJob.currentRepeat;
      if (producedDelta <= 0) {
        continue;
      }

      final PotionBlueprint? blueprint = potionCatalogRepository.findPotionById(
        job.potionId,
      );
      if (blueprint == null) {
        continue;
      }
      for (int index = 0; index < producedDelta; index++) {
        final ({
          Map<String, double> nextExtractedInventory,
          Map<String, double> extractedTraits,
        })?
        prepared = craftingService.prepareCraftFromExtractedInventory(
          blueprint: blueprint,
          extractedInventory: extractedInventory,
        );
        if (prepared == null) {
          resolvedQueue = _markCraftBlocked(resolvedQueue, job.id);
          break;
        }
        extractedInventory
          ..clear()
          ..addAll(prepared.nextExtractedInventory);
        final CraftedPotion crafted = craftingService.craftPotion(
          requestedBlueprint: blueprint,
          extractedTraits: prepared.extractedTraits,
          recipeRules: potionCatalogRepository.recipeRules(),
          branchRules: potionCatalogRepository.recipeBranchRules(),
          qualityRule: potionCatalogRepository.qualityRule(),
        );
        final String stackKey =
            '${crafted.typePotionId}|${crafted.qualityGrade.name}';
        stacks[stackKey] = (stacks[stackKey] ?? 0) + 1;
        details.putIfAbsent(stackKey, () => crafted);
      }
    }

    return state.copyWith(
      workshop: state.workshop.copyWith(
        extractedTraitInventory: extractedInventory,
        queue: resolvedQueue,
        craftedPotionStacks: stacks,
        craftedPotionDetails: details,
        potionCraftCount:
            state.workshop.potionCraftCount +
            _totalProducedCount(previousQueue, resolvedQueue),
      ),
    );
  }

  SessionState resumeBlockedJob({
    required SessionState state,
    required String jobId,
    required CraftQueueService queueService,
    required PotionCraftingService craftingService,
    required PotionCatalogRepository potionCatalogRepository,
  }) {
    CraftQueueJob? blockedJob;
    for (final CraftQueueJob job in state.workshop.queue) {
      if (job.id == jobId && job.status == QueueJobStatus.blocked) {
        blockedJob = job;
        break;
      }
    }
    if (blockedJob == null) {
      return state;
    }

    final int remainingCount =
        blockedJob.repeatCount - blockedJob.currentRepeat;
    final PotionBlueprint? blueprint = potionCatalogRepository.findPotionById(
      blockedJob.potionId,
    );
    if (blueprint == null) {
      return state;
    }
    final bool canCraft = craftingService.canCraftRepeatCount(
      blueprint: blueprint,
      extractedInventory: state.workshop.extractedTraitInventory,
      repeatCount: remainingCount,
    );
    if (!canCraft) {
      return state;
    }

    return state.copyWith(
      workshop: state.workshop.copyWith(
        queue: queueService.resumeBlocked(state.workshop.queue, jobId),
      ),
    );
  }

  SessionState clearCompletedJobs({required SessionState state}) {
    final List<CraftQueueJob> remaining = state.workshop.queue
        .where((CraftQueueJob job) => job.status != QueueJobStatus.completed)
        .toList();
    if (remaining.length == state.workshop.queue.length) {
      return state;
    }
    return state.copyWith(workshop: state.workshop.copyWith(queue: remaining));
  }

  List<CraftQueueJob> _markCraftBlocked(
    List<CraftQueueJob> jobs,
    String jobId,
  ) {
    return jobs.map((CraftQueueJob job) {
      if (job.id != jobId) {
        return job;
      }
      return job.copyWith(status: QueueJobStatus.blocked, eta: Duration.zero);
    }).toList();
  }

  int _totalProducedCount(
    List<CraftQueueJob> previousQueue,
    List<CraftQueueJob> nextQueue,
  ) {
    int total = 0;
    for (final CraftQueueJob job in nextQueue) {
      final CraftQueueJob? previousJob = previousQueue
          .where((CraftQueueJob candidate) => candidate.id == job.id)
          .firstOrNull;
      if (previousJob == null) {
        continue;
      }
      final int producedDelta = job.currentRepeat - previousJob.currentRepeat;
      if (producedDelta > 0) {
        total += producedDelta;
      }
    }
    return total;
  }
}
