import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/alchemy_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';

class WorkshopExtractionUseCase {
  const WorkshopExtractionUseCase();

  SessionState extractMaterial({
    required SessionState state,
    required String materialId,
    required String profileId,
    required DateTime now,
    required int queueCapacity,
    required AlchemyService alchemyService,
    required MaterialCatalogRepository materialCatalogRepository,
    required ExtractionProfileRepository extractionProfileRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
    int quantity = 1,
    List<String>? selectedTraits,
  }) {
    final int owned = state.player.materialInventory[materialId] ?? 0;
    if (state.workshop.queue.length >= queueCapacity ||
        owned <= 0 ||
        quantity <= 0 ||
        owned < quantity) {
      return state;
    }

    final MaterialEntity? material = materialCatalogRepository.findMaterialById(
      materialId,
    );
    final ExtractionProfile? profile = extractionProfileRepository
        .findProfileById(profileId);
    if (material == null || profile == null) {
      return state;
    }
    if (profile.mode == ExtractionMode.selective &&
        (selectedTraits == null || selectedTraits.isEmpty)) {
      return state;
    }

    final Map<String, double> extractedTraits = alchemyService
        .extractTraitInventory(
          material: material,
          profile: profile,
          selectedTraits: selectedTraits,
        );
    if (extractedTraits.isEmpty) {
      return state;
    }

    final double yieldMultiplier =
        1 +
        workshopSkillTreeService.extractionYieldBonusRate(
          state,
          workshopSkillTreeRepository.nodes(),
        ) +
        workshopSupportService.extractionYieldBonusRate(state);
    final Map<String, double> completedTraits = <String, double>{};
    extractedTraits.forEach((String traitId, double amount) {
      completedTraits[traitId] = amount * quantity * yieldMultiplier;
    });

    final Map<String, int> materials = <String, int>{
      ...state.player.materialInventory,
    };
    final int nextCount = owned - quantity;
    if (nextCount <= 0) {
      materials.remove(materialId);
    } else {
      materials[materialId] = nextCount;
    }

    final bool hasActiveJob = state.workshop.queue.any(
      (CraftQueueJob job) => job.status != QueueJobStatus.completed,
    );
    final Duration duration = Duration(
      milliseconds: profile.timeCost.inMilliseconds * quantity,
    );
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.microsecondsSinceEpoch}_extract_${material.id}',
      type: WorkshopJobType.extraction,
      status: hasActiveJob ? QueueJobStatus.queued : QueueJobStatus.processing,
      queuedAt: now,
      startedAt: hasActiveJob ? null : now,
      duration: duration,
      eta: duration,
      title: material.name,
      materialId: materialId,
      profileId: profileId,
      quantity: quantity,
      selectedTraits: selectedTraits ?? const <String>[],
      reservedMaterials: <String, int>{materialId: quantity},
      completedExtractedTraits: completedTraits,
      completedArcaneDust: quantity,
    );

    return state.copyWith(
      player: state.player.copyWith(materialInventory: materials),
      workshop: state.workshop.copyWith(
        queue: <CraftQueueJob>[...state.workshop.queue, job],
      ),
    );
  }
}
