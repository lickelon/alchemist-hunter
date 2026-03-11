import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/application/services/craft_queue_service.dart';
import 'package:alchemist_hunter/features/workshop/application/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/data/dummy_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class WorkshopDomain {
  const WorkshopDomain();

  SessionState enqueuePotion({
    required SessionState state,
    required String potionId,
    required int repeatCount,
    required DateTime now,
    required CraftQueueService queueService,
    required PotionCraftingService craftingService,
  }) {
    final PotionBlueprint blueprint = _findBlueprint(potionId);
    final bool canCraft = craftingService.canCraftRepeatCount(
      blueprint: blueprint,
      inventory: state.player.materialInventory,
      materials: DummyData.materials,
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
      final PotionBlueprint activeBlueprint = _findBlueprint(
        activeJob.potionId,
      );
      final bool canPrepare =
          craftingService.prepareCraftFromInventory(
            blueprint: activeBlueprint,
            inventory: state.player.materialInventory,
            materials: DummyData.materials,
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
    final Map<String, int> inventory = <String, int>{
      ...state.player.materialInventory,
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

      final PotionBlueprint blueprint = _findBlueprint(job.potionId);
      for (int index = 0; index < producedDelta; index++) {
        final ({
          Map<String, int> nextInventory,
          Map<String, double> extractedTraits,
        })?
        prepared = craftingService.prepareCraftFromInventory(
          blueprint: blueprint,
          inventory: inventory,
          materials: DummyData.materials,
        );
        if (prepared == null) {
          resolvedQueue = _markCraftBlocked(resolvedQueue, job.id);
          break;
        }
        inventory
          ..clear()
          ..addAll(prepared.nextInventory);
        final CraftedPotion crafted = craftingService.craftPotion(
          requestedBlueprint: blueprint,
          extractedTraits: prepared.extractedTraits,
          recipeRules: DummyData.potionRecipeRules,
          branchRules: DummyData.potionRecipeBranchRules,
          qualityRule: DummyData.potionQualityRule,
        );
        final String stackKey =
            '${crafted.typePotionId}|${crafted.qualityGrade.name}';
        stacks[stackKey] = (stacks[stackKey] ?? 0) + 1;
        details.putIfAbsent(stackKey, () => crafted);
      }
    }

    return state.copyWith(
      player: state.player.copyWith(materialInventory: inventory),
      workshop: state.workshop.copyWith(
        queue: resolvedQueue,
        craftedPotionStacks: stacks,
        craftedPotionDetails: details,
      ),
    );
  }

  SessionState sellCraftedPotion({
    required SessionState state,
    required String stackKey,
    required int quantity,
  }) {
    final int owned = state.workshop.craftedPotionStacks[stackKey] ?? 0;
    if (quantity < 1 || owned < quantity) {
      return state;
    }

    final CraftedPotion? sample = state.workshop.craftedPotionDetails[stackKey];
    if (sample == null) {
      return state;
    }

    final PotionBlueprint blueprint = _findBlueprint(sample.typePotionId);
    final double multiplier = switch (sample.qualityGrade) {
      PotionQualityGrade.s => 1.6,
      PotionQualityGrade.a => 1.3,
      PotionQualityGrade.b => 1.0,
      PotionQualityGrade.c => 0.8,
    };
    final int earned = (blueprint.baseValue * multiplier * quantity).round();

    final Map<String, int> stacks = <String, int>{
      ...state.workshop.craftedPotionStacks,
    };
    final Map<String, CraftedPotion> details = <String, CraftedPotion>{
      ...state.workshop.craftedPotionDetails,
    };
    final int nextQuantity = owned - quantity;

    if (nextQuantity <= 0) {
      stacks.remove(stackKey);
      details.remove(stackKey);
    } else {
      stacks[stackKey] = nextQuantity;
    }

    return state.copyWith(
      player: state.player.copyWith(gold: state.player.gold + earned),
      workshop: state.workshop.copyWith(
        craftedPotionStacks: stacks,
        craftedPotionDetails: details,
      ),
    );
  }

  SessionState resumeBlockedJob({
    required SessionState state,
    required String jobId,
    required CraftQueueService queueService,
    required PotionCraftingService craftingService,
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

    final int remainingCount = blockedJob.repeatCount - blockedJob.currentRepeat;
    final PotionBlueprint blueprint = _findBlueprint(blockedJob.potionId);
    final bool canCraft = craftingService.canCraftRepeatCount(
      blueprint: blueprint,
      inventory: state.player.materialInventory,
      materials: DummyData.materials,
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

  PotionBlueprint _findBlueprint(String potionId) {
    return DummyData.potions.firstWhere(
      (PotionBlueprint potion) => potion.id == potionId,
      orElse: () => DummyData.potions.first,
    );
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
}
