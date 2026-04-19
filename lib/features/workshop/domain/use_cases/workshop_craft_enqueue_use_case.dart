import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';

class WorkshopCraftEnqueueUseCase {
  const WorkshopCraftEnqueueUseCase();

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
    final int queueCapacity =
        workshopSkillTreeService.craftQueueCapacity(
          state,
          workshopSkillTreeRepository.nodes(),
        ) +
        workshopSupportService.craftQueueCapacityBonus(state);
    if (repeatCount <= 0 || state.workshop.queue.length >= queueCapacity) {
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

    final Map<String, double> nextExtractedInventory = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    requiredTraits.forEach((String key, double value) {
      final double nextValue = (nextExtractedInventory[key] ?? 0) - value;
      if (nextValue <= 0.0001) {
        nextExtractedInventory.remove(key);
      } else {
        nextExtractedInventory[key] = nextValue;
      }
    });

    final CraftedPotion craftedPotion = craftingService.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: blueprint.targetTraits,
      recipeRules: potionCatalogRepository.recipeRules(),
      branchRules: potionCatalogRepository.recipeBranchRules(),
      qualityRule: potionCatalogRepository.qualityRule(),
    );
    final String stackKey =
        '${craftedPotion.typePotionId}|${craftedPotion.qualityGrade.name}';
    final Duration duration = Duration(seconds: 15 * repeatCount);
    final bool hasActiveJob = _hasActiveJob(state.workshop.queue);
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.microsecondsSinceEpoch}_craft_${blueprint.id}',
      type: WorkshopJobType.craft,
      status: hasActiveJob ? QueueJobStatus.queued : QueueJobStatus.processing,
      queuedAt: now,
      startedAt: hasActiveJob ? null : now,
      duration: duration,
      eta: duration,
      title: blueprint.name,
      potionId: potionId,
      repeatCount: repeatCount,
      reservedTraits: requiredTraits,
      completedPotionStackKey: stackKey,
      completedPotion: craftedPotion,
    );

    return state.copyWith(
      workshop: state.workshop.copyWith(
        extractedTraitInventory: nextExtractedInventory,
        queue: <CraftQueueJob>[...state.workshop.queue, job],
      ),
    );
  }

  bool _hasActiveJob(List<CraftQueueJob> jobs) {
    return jobs.any(
      (CraftQueueJob job) => job.status != QueueJobStatus.completed,
    );
  }
}
