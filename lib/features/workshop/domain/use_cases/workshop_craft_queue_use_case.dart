import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';

class WorkshopCraftQueueUseCase {
  const WorkshopCraftQueueUseCase();

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
    final int queueCapacity = workshopSkillTreeService.craftQueueCapacity(
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

  SessionState claimPending({required SessionState state}) {
    final WorkshopPendingClaim pending = state.workshop.pendingClaim;
    if (pending.isEmpty) {
      return state;
    }

    final Map<String, double> extractedTraits = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    pending.extractedTraits.forEach((String key, double value) {
      extractedTraits[key] = (extractedTraits[key] ?? 0) + value;
    });

    final Map<String, int> potionStacks = <String, int>{
      ...state.workshop.craftedPotionStacks,
    };
    pending.potionStacks.forEach((String key, int value) {
      potionStacks[key] = (potionStacks[key] ?? 0) + value;
    });
    final Map<String, CraftedPotion> potionDetails = <String, CraftedPotion>{
      ...state.workshop.craftedPotionDetails,
      ...pending.potionDetails,
    };

    List<EquipmentInstance> townInventory = <EquipmentInstance>[
      ...state.town.equipmentInventory,
    ];
    List<CharacterProgress> mercenaries = <CharacterProgress>[
      ...state.characters.mercenaries,
    ];
    List<CharacterProgress> homunculi = <CharacterProgress>[
      ...state.characters.homunculi,
      ...pending.homunculi,
    ];

    for (final WorkshopEquipmentClaim claim in pending.equipmentClaims) {
      final CharacterType? ownerType = claim.ownerType;
      final String? ownerCharacterId = claim.ownerCharacterId;
      if (ownerType == null || ownerCharacterId == null) {
        townInventory = <EquipmentInstance>[claim.equipment, ...townInventory];
        continue;
      }

      if (ownerType == CharacterType.mercenary) {
        final ({List<CharacterProgress> characters, bool equipped})
        result = _applyEquipmentClaimToList(
          characters: mercenaries,
          ownerCharacterId: ownerCharacterId,
          equipment: claim.equipment,
        );
        mercenaries = result.characters;
        if (!result.equipped) {
          townInventory = <EquipmentInstance>[claim.equipment, ...townInventory];
        }
        continue;
      }

      final ({List<CharacterProgress> characters, bool equipped})
      result = _applyEquipmentClaimToList(
        characters: homunculi,
        ownerCharacterId: ownerCharacterId,
        equipment: claim.equipment,
      );
      homunculi = result.characters;
      if (!result.equipped) {
        townInventory = <EquipmentInstance>[claim.equipment, ...townInventory];
      }
    }

    return state.copyWith(
      player: state.player.copyWith(
        arcaneDust: state.player.arcaneDust + pending.arcaneDust,
      ),
      town: state.town.copyWith(equipmentInventory: townInventory),
      workshop: state.workshop.copyWith(
        pendingClaim: const WorkshopPendingClaim(),
        extractedTraitInventory: extractedTraits,
        craftedPotionStacks: potionStacks,
        craftedPotionDetails: potionDetails,
        extractionCount:
            state.workshop.extractionCount + pending.extractionCount,
        potionCraftCount:
            state.workshop.potionCraftCount + pending.potionCraftCount,
        enchantCount: state.workshop.enchantCount + pending.enchantCount,
      ),
      characters: state.characters.copyWith(
        mercenaries: mercenaries,
        homunculi: homunculi,
      ),
    );
  }

  bool _hasActiveJob(List<CraftQueueJob> jobs) {
    return jobs.any((CraftQueueJob job) => job.status != QueueJobStatus.completed);
  }

  ({List<CharacterProgress> characters, bool equipped}) _applyEquipmentClaimToList({
    required List<CharacterProgress> characters,
    required String ownerCharacterId,
    required EquipmentInstance equipment,
  }) {
    final List<CharacterProgress> nextCharacters = <CharacterProgress>[
      ...characters,
    ];
    for (int index = 0; index < nextCharacters.length; index++) {
      final CharacterProgress character = nextCharacters[index];
      if (character.id != ownerCharacterId) {
        continue;
      }
      final EquipmentInstance? current = character.equipment.itemForSlot(
        equipment.slot,
      );
      if (current != null) {
        return (characters: nextCharacters, equipped: false);
      }
      nextCharacters[index] = character.copyWith(
        equipment: character.equipment.equip(equipment),
      );
      return (characters: nextCharacters, equipped: true);
    }
    return (characters: nextCharacters, equipped: false);
  }
}
