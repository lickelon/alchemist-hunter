import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/services/character_id_factory.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';

class WorkshopHatchUseCase {
  const WorkshopHatchUseCase();

  SessionState hatchHomunculus({
    required SessionState state,
    required HomunculusHatchRecipe recipe,
    required DateTime now,
    int queueCapacity = 99,
    required WorkshopSupportService workshopSupportService,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    if (state.workshop.queue.length >= queueCapacity) {
      return state;
    }

    final int arcaneDustCost =
        (recipe.arcaneDustCost -
                workshopSupportService.hatchArcaneDustDiscount(state))
            .clamp(0, recipe.arcaneDustCost)
            .toInt();
    if (state.player.essence < recipe.essenceCost ||
        state.player.arcaneDust < arcaneDustCost) {
      return state;
    }

    final Map<String, int> materialInventory = <String, int>{
      ...state.player.materialInventory,
    };
    for (final MapEntry<String, int> entry in recipe.materialCosts.entries) {
      if ((materialInventory[entry.key] ?? 0) < entry.value) {
        return state;
      }
    }

    final Map<String, double> traitInventory = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    for (final MapEntry<String, double> entry in recipe.traitCosts.entries) {
      if ((traitInventory[entry.key] ?? 0) < entry.value) {
        return state;
      }
    }

    for (final MapEntry<String, int> entry in recipe.materialCosts.entries) {
      final int nextValue = (materialInventory[entry.key] ?? 0) - entry.value;
      if (nextValue <= 0) {
        materialInventory.remove(entry.key);
      } else {
        materialInventory[entry.key] = nextValue;
      }
    }

    for (final MapEntry<String, double> entry in recipe.traitCosts.entries) {
      final double nextValue = (traitInventory[entry.key] ?? 0) - entry.value;
      if (nextValue <= 0) {
        traitInventory.remove(entry.key);
      } else {
        traitInventory[entry.key] = nextValue;
      }
    }

    final String jobName = homunculusHatchJobName(
      recipe.combatJobId,
      battleCatalogRepository,
    );
    final String displayName = homunculusHatchDisplayName(
      recipe,
      battleCatalogRepository,
    );
    final int characterCount =
        state.characters.mercenaries.length + state.characters.homunculi.length;
    final String characterId = createOpaqueCharacterId(
      now: now,
      seed: characterCount + state.workshop.queue.length,
      reservedIds: collectCharacterIds(
        state.characters,
        pendingCharacters: state.workshop.queue.map(
          (job) => job.completedHomunculus,
        ),
      ),
    );
    final CharacterProgress homunculus = CharacterProgress(
      id: characterId,
      name: jobName,
      type: CharacterType.homunculus,
      combatJobId: recipe.combatJobId,
      level: 1,
      rank: 1,
      xp: 0,
      homunculusTier: HomunculusTier.nigredo,
    );

    final bool hasActiveJob = state.workshop.queue.any(
      (CraftQueueJob job) => job.status != QueueJobStatus.completed,
    );
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${now.microsecondsSinceEpoch}_hatch_${recipe.id}',
      type: WorkshopJobType.hatch,
      status: hasActiveJob ? QueueJobStatus.queued : QueueJobStatus.processing,
      queuedAt: now,
      startedAt: hasActiveJob ? null : now,
      duration: recipe.duration,
      eta: recipe.duration,
      title: displayName,
      recipeId: recipe.id,
      reservedMaterials: recipe.materialCosts,
      reservedTraits: recipe.traitCosts,
      completedHomunculus: homunculus,
    );

    return state.copyWith(
      player: state.player.copyWith(
        essence: state.player.essence - recipe.essenceCost,
        arcaneDust: state.player.arcaneDust - arcaneDustCost,
        materialInventory: materialInventory,
      ),
      workshop: state.workshop.copyWith(
        extractedTraitInventory: traitInventory,
        queue: <CraftQueueJob>[...state.workshop.queue, job],
      ),
    );
  }
}

String homunculusHatchDisplayName(
  HomunculusHatchRecipe recipe,
  BattleCatalogRepository battleCatalogRepository,
) {
  return 'Nigredo ${homunculusHatchJobName(recipe.combatJobId, battleCatalogRepository)}';
}

String homunculusHatchJobName(
  String combatJobId,
  BattleCatalogRepository battleCatalogRepository,
) {
  final BattleCombatJobDefinition job = battleCatalogRepository
      .combatJobDefinition(combatJobId);
  return switch (job.discipline) {
    CombatDiscipline.warrior => '전사',
    CombatDiscipline.mage => '마법사',
    CombatDiscipline.rogue => '도적',
    CombatDiscipline.archer => '궁수',
  };
}
