import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class WorkshopQueueClaimUseCase {
  const WorkshopQueueClaimUseCase();

  SessionState claimPending({required SessionState state}) {
    SessionState nextState = state;
    for (final String jobId
        in state.workshop.queue
            .where(
              (CraftQueueJob job) => job.status == QueueJobStatus.completed,
            )
            .map((CraftQueueJob job) => job.id)
            .toList()) {
      nextState = claimJob(state: nextState, jobId: jobId);
    }
    return nextState;
  }

  SessionState claimJob({required SessionState state, required String jobId}) {
    final int jobIndex = state.workshop.queue.indexWhere(
      (CraftQueueJob job) => job.id == jobId,
    );
    if (jobIndex == -1) {
      return state;
    }
    final CraftQueueJob job = state.workshop.queue[jobIndex];
    if (job.status != QueueJobStatus.completed) {
      return state;
    }

    final List<CraftQueueJob> nextQueue = <CraftQueueJob>[
      ...state.workshop.queue,
    ]..removeAt(jobIndex);

    return switch (job.type) {
      WorkshopJobType.extraction => _claimExtractionJob(
        state: state,
        queue: nextQueue,
        job: job,
      ),
      WorkshopJobType.craft => _claimCraftJob(
        state: state,
        queue: nextQueue,
        job: job,
      ),
      WorkshopJobType.enchant => _claimEnchantJob(
        state: state,
        queue: nextQueue,
        job: job,
      ),
      WorkshopJobType.hatch => _claimHatchJob(
        state: state,
        queue: nextQueue,
        job: job,
      ),
    };
  }

  SessionState _claimExtractionJob({
    required SessionState state,
    required List<CraftQueueJob> queue,
    required CraftQueueJob job,
  }) {
    final Map<String, double> extractedTraits = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    job.completedExtractedTraits.forEach((String key, double value) {
      extractedTraits[key] = (extractedTraits[key] ?? 0) + value;
    });

    return state.copyWith(
      player: state.player.copyWith(
        arcaneDust: state.player.arcaneDust + job.completedArcaneDust,
      ),
      workshop: state.workshop.copyWith(
        queue: queue,
        extractedTraitInventory: extractedTraits,
        extractionCount: state.workshop.extractionCount + job.quantity,
      ),
    );
  }

  SessionState _claimCraftJob({
    required SessionState state,
    required List<CraftQueueJob> queue,
    required CraftQueueJob job,
  }) {
    final String? stackKey = job.completedPotionStackKey;
    final CraftedPotion? detail = job.completedPotion;
    if (stackKey == null || detail == null) {
      return state;
    }

    final Map<String, int> potionStacks = <String, int>{
      ...state.workshop.craftedPotionStacks,
    };
    potionStacks[stackKey] = (potionStacks[stackKey] ?? 0) + job.repeatCount;

    final Map<String, CraftedPotion> potionDetails = <String, CraftedPotion>{
      ...state.workshop.craftedPotionDetails,
    };
    potionDetails[stackKey] = detail;

    return state.copyWith(
      workshop: state.workshop.copyWith(
        queue: queue,
        craftedPotionStacks: potionStacks,
        craftedPotionDetails: potionDetails,
        potionCraftCount: state.workshop.potionCraftCount + job.repeatCount,
      ),
    );
  }

  SessionState _claimEnchantJob({
    required SessionState state,
    required List<CraftQueueJob> queue,
    required CraftQueueJob job,
  }) {
    final EquipmentInstance? equipment = job.completedEquipment;
    if (equipment == null) {
      return state;
    }
    List<EquipmentInstance> townInventory = <EquipmentInstance>[
      ...state.town.equipmentInventory,
    ];
    List<CharacterProgress> mercenaries = <CharacterProgress>[
      ...state.characters.mercenaries,
    ];
    List<CharacterProgress> homunculi = <CharacterProgress>[
      ...state.characters.homunculi,
    ];

    final CharacterType? ownerType = job.equipmentOwnerType;
    final String? ownerCharacterId = job.equipmentOwnerId;
    if (ownerType == null || ownerCharacterId == null) {
      townInventory = <EquipmentInstance>[equipment, ...townInventory];
    } else if (ownerType == CharacterType.mercenary) {
      final ({List<CharacterProgress> characters, bool equipped}) result =
          _applyEquipmentClaimToList(
            characters: mercenaries,
            ownerCharacterId: ownerCharacterId,
            equipment: equipment,
          );
      mercenaries = result.characters;
      if (!result.equipped) {
        townInventory = <EquipmentInstance>[equipment, ...townInventory];
      }
    } else {
      final ({List<CharacterProgress> characters, bool equipped}) result =
          _applyEquipmentClaimToList(
            characters: homunculi,
            ownerCharacterId: ownerCharacterId,
            equipment: equipment,
          );
      homunculi = result.characters;
      if (!result.equipped) {
        townInventory = <EquipmentInstance>[equipment, ...townInventory];
      }
    }

    return state.copyWith(
      town: state.town.copyWith(equipmentInventory: townInventory),
      workshop: state.workshop.copyWith(
        queue: queue,
        enchantCount: state.workshop.enchantCount + 1,
      ),
      characters: state.characters.copyWith(
        mercenaries: mercenaries,
        homunculi: homunculi,
      ),
    );
  }

  SessionState _claimHatchJob({
    required SessionState state,
    required List<CraftQueueJob> queue,
    required CraftQueueJob job,
  }) {
    final CharacterProgress? homunculus = job.completedHomunculus;
    if (homunculus == null) {
      return state;
    }

    return state.copyWith(
      workshop: state.workshop.copyWith(queue: queue),
      characters: state.characters.copyWith(
        homunculi: <CharacterProgress>[
          ...state.characters.homunculi,
          homunculus,
        ],
      ),
    );
  }

  ({List<CharacterProgress> characters, bool equipped})
  _applyEquipmentClaimToList({
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
