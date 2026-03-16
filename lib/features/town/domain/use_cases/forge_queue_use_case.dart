import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';

class ForgeQueueUseCase {
  const ForgeQueueUseCase();

  SessionState enqueueCraft({
    required SessionState state,
    required EquipmentBlueprint blueprint,
    required DateTime now,
    required TownSkillTreeRepository townSkillTreeRepository,
    required TownSkillTreeService townSkillTreeService,
  }) {
    final Map<String, int> effectiveMaterialCosts = townSkillTreeService
        .adjustedMaterialCosts(
          baseCosts: blueprint.materialCosts,
          efficiencyRate: townSkillTreeService.equipmentCraftEfficiencyRate(
            state,
            townSkillTreeRepository.nodes(),
          ),
        );
    final Map<String, int> inventory = <String, int>{
      ...state.player.materialInventory,
    };
    final EquipmentInstance resultEquipment = EquipmentInstance(
      id: 'equip_${now.microsecondsSinceEpoch}_${blueprint.id}',
      blueprintId: blueprint.id,
      name: blueprint.name,
      slot: blueprint.slot,
      attack: blueprint.attack,
      defense: blueprint.defense,
      health: blueprint.health,
      createdAt: now,
    );

    for (final MapEntry<String, int> entry in effectiveMaterialCosts.entries) {
      if ((inventory[entry.key] ?? 0) < entry.value) {
        return state;
      }
    }

    for (final MapEntry<String, int> entry in effectiveMaterialCosts.entries) {
      final int nextValue = (inventory[entry.key] ?? 0) - entry.value;
      if (nextValue <= 0) {
        inventory.remove(entry.key);
      } else {
        inventory[entry.key] = nextValue;
      }
    }

    final bool hasActiveJob = state.town.forgeQueue.any(
      (TownForgeJob job) => job.status != TownForgeJobStatus.completed,
    );
    final TownForgeJob job = TownForgeJob(
      id: 'forge_${now.microsecondsSinceEpoch}_${blueprint.id}',
      blueprintId: blueprint.id,
      name: blueprint.name,
      status: hasActiveJob
          ? TownForgeJobStatus.queued
          : TownForgeJobStatus.processing,
      queuedAt: now,
      startedAt: hasActiveJob ? null : now,
      remaining: blueprint.craftDuration,
      duration: blueprint.craftDuration,
      reservedMaterials: effectiveMaterialCosts,
      resultEquipment: resultEquipment,
    );

    return state.copyWith(
      player: state.player.copyWith(materialInventory: inventory),
      town: state.town.copyWith(
        forgeQueue: <TownForgeJob>[...state.town.forgeQueue, job],
      ),
    );
  }

  SessionState claimCompleted({
    required SessionState state,
    required String jobId,
  }) {
    final TownForgeJob? job = state.town.forgeQueue
        .where((TownForgeJob candidate) => candidate.id == jobId)
        .firstOrNull;
    if (job == null ||
        job.status != TownForgeJobStatus.completed ||
        job.resultEquipment == null) {
      return state;
    }

    return state.copyWith(
      town: state.town.copyWith(
        equipmentInventory: <EquipmentInstance>[
          job.resultEquipment!,
          ...state.town.equipmentInventory,
        ],
        forgeQueue: state.town.forgeQueue
            .where((TownForgeJob candidate) => candidate.id != jobId)
            .toList(),
        equipmentCraftCount: state.town.equipmentCraftCount + 1,
      ),
    );
  }
}
