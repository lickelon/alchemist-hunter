import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/equipment_enchant_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';

class WorkshopEnchantUseCase {
  const WorkshopEnchantUseCase();

  SessionState enchantEquipment({
    required SessionState state,
    required String equipmentId,
    required String potionStackKey,
    DateTime? now,
    int queueCapacity = 99,
    required EquipmentEnchantService enchantService,
    required PotionCatalogRepository potionCatalogRepository,
    required WorkshopSkillTreeRepository workshopSkillTreeRepository,
    required WorkshopSkillTreeService workshopSkillTreeService,
    required WorkshopSupportService workshopSupportService,
  }) {
    if (state.workshop.queue.length >= queueCapacity) {
      return state;
    }

    final int owned = state.workshop.craftedPotionStacks[potionStackKey] ?? 0;
    final CraftedPotion? potion =
        state.workshop.craftedPotionDetails[potionStackKey];
    if (owned <= 0 || potion == null) {
      return state;
    }

    final PotionBlueprint? blueprint = potionCatalogRepository.findPotionById(
      potion.typePotionId,
    );
    if (blueprint == null) {
      return state;
    }

    final EquipmentInstance? storedItem = _findStoredItem(
      state.town.equipmentInventory,
      equipmentId,
    );
    final ({
      CharacterType type,
      int index,
      CharacterProgress character,
      EquipmentInstance item,
    })?
    equippedEntry = storedItem == null
        ? _findEquippedItem(state.characters, equipmentId)
        : null;
    if (storedItem == null && equippedEntry == null) {
      return state;
    }

    final double potencyBonusRate =
        workshopSkillTreeService.enchantPotencyBonusRate(
          state,
          workshopSkillTreeRepository.nodes(),
        ) +
        workshopSupportService.enchantPotencyBonusRate(state);
    final EquipmentInstance sourceItem = storedItem ?? equippedEntry!.item;
    final EquipmentEnchant enchant = enchantService.buildEnchant(
      equipment: sourceItem,
      potion: potion,
      blueprint: blueprint,
      potencyBonusRate: potencyBonusRate,
    );
    final EquipmentInstance completedEquipment = sourceItem.copyWith(
      enchant: enchant,
    );

    final SessionState reservedState = _consumePotion(
      _reserveEquipment(
        state,
        storedItem: storedItem,
        equippedEntry: equippedEntry,
      ),
      potionStackKey,
    );
    final bool hasActiveJob = reservedState.workshop.queue.any(
      (CraftQueueJob job) => job.status != QueueJobStatus.completed,
    );
    final Duration duration = const Duration(seconds: 20);
    final DateTime queuedAt = now ?? DateTime.now();
    final CraftQueueJob job = CraftQueueJob(
      id: 'job_${queuedAt.microsecondsSinceEpoch}_enchant_$equipmentId',
      type: WorkshopJobType.enchant,
      status: hasActiveJob ? QueueJobStatus.queued : QueueJobStatus.processing,
      queuedAt: queuedAt,
      startedAt: hasActiveJob ? null : queuedAt,
      duration: duration,
      eta: duration,
      title: sourceItem.name,
      potionStackKey: potionStackKey,
      equipmentId: equipmentId,
      equipmentOwnerId: equippedEntry?.character.id,
      equipmentOwnerType: equippedEntry?.type,
      reservedPotion: potion,
      reservedEquipment: sourceItem,
      completedEquipment: completedEquipment,
    );

    return reservedState.copyWith(
      workshop: reservedState.workshop.copyWith(
        queue: <CraftQueueJob>[...reservedState.workshop.queue, job],
      ),
    );
  }

  EquipmentInstance? _findStoredItem(
    List<EquipmentInstance> inventory,
    String equipmentId,
  ) {
    for (final EquipmentInstance item in inventory) {
      if (item.id == equipmentId) {
        return item;
      }
    }
    return null;
  }

  ({
    CharacterType type,
    int index,
    CharacterProgress character,
    EquipmentInstance item,
  })?
  _findEquippedItem(CharactersState state, String equipmentId) {
    for (int index = 0; index < state.mercenaries.length; index++) {
      final CharacterProgress character = state.mercenaries[index];
      for (final EquipmentSlot slot in EquipmentSlot.values) {
        final EquipmentInstance? item = character.equipment.itemForSlot(slot);
        if (item?.id == equipmentId) {
          return (
            type: CharacterType.mercenary,
            index: index,
            character: character,
            item: item!,
          );
        }
      }
    }

    for (int index = 0; index < state.homunculi.length; index++) {
      final CharacterProgress character = state.homunculi[index];
      for (final EquipmentSlot slot in EquipmentSlot.values) {
        final EquipmentInstance? item = character.equipment.itemForSlot(slot);
        if (item?.id == equipmentId) {
          return (
            type: CharacterType.homunculus,
            index: index,
            character: character,
            item: item!,
          );
        }
      }
    }
    return null;
  }

  SessionState _reserveEquipment(
    SessionState state, {
    required EquipmentInstance? storedItem,
    required ({
      CharacterType type,
      int index,
      CharacterProgress character,
      EquipmentInstance item,
    })?
    equippedEntry,
  }) {
    if (storedItem != null) {
      return state.copyWith(
        town: state.town.copyWith(
          equipmentInventory: state.town.equipmentInventory
              .where((EquipmentInstance item) => item.id != storedItem.id)
              .toList(),
        ),
      );
    }
    if (equippedEntry == null) {
      return state;
    }

    final CharacterProgress updatedCharacter = equippedEntry.character.copyWith(
      equipment: equippedEntry.character.equipment.clearSlot(equippedEntry.item.slot),
    );
    final List<CharacterProgress> source =
        equippedEntry.type == CharacterType.mercenary
        ? state.characters.mercenaries
        : state.characters.homunculi;
    final List<CharacterProgress> nextList = <CharacterProgress>[...source];
    nextList[equippedEntry.index] = updatedCharacter;

    return state.copyWith(
      characters: equippedEntry.type == CharacterType.mercenary
          ? state.characters.copyWith(mercenaries: nextList)
          : state.characters.copyWith(homunculi: nextList),
    );
  }

  SessionState _consumePotion(SessionState state, String potionStackKey) {
    final Map<String, int> stacks = <String, int>{
      ...state.workshop.craftedPotionStacks,
    };
    final Map<String, CraftedPotion> details = <String, CraftedPotion>{
      ...state.workshop.craftedPotionDetails,
    };

    final int nextCount = (stacks[potionStackKey] ?? 0) - 1;
    if (nextCount <= 0) {
      stacks.remove(potionStackKey);
      details.remove(potionStackKey);
    } else {
      stacks[potionStackKey] = nextCount;
    }

    return state.copyWith(
      workshop: state.workshop.copyWith(
        craftedPotionStacks: stacks,
        craftedPotionDetails: details,
      ),
    );
  }
}
