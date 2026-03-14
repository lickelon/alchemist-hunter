import 'package:alchemist_hunter/core/session/state/session_state.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/data/catalogs/potion_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/equipment_enchant_service.dart';

class WorkshopEnchantUseCase {
  const WorkshopEnchantUseCase();

  SessionState enchantEquipment({
    required SessionState state,
    required String equipmentId,
    required String potionStackKey,
    required EquipmentEnchantService enchantService,
  }) {
    final int owned = state.workshop.craftedPotionStacks[potionStackKey] ?? 0;
    final CraftedPotion? potion =
        state.workshop.craftedPotionDetails[potionStackKey];
    if (owned <= 0 || potion == null) {
      return state;
    }

    final PotionBlueprint blueprint = potionCatalog.firstWhere(
      (PotionBlueprint entry) => entry.id == potion.typePotionId,
      orElse: () => potionCatalog.first,
    );

    final EquipmentInstance? storedItem = _findStoredItem(
      state.town.equipmentInventory,
      equipmentId,
    );
    if (storedItem != null) {
      final EquipmentEnchant enchant = enchantService.buildEnchant(
        equipment: storedItem,
        potion: potion,
        blueprint: blueprint,
      );
      return _consumePotion(
        state.copyWith(
          town: state.town.copyWith(
            equipmentInventory: state.town.equipmentInventory.map((
              EquipmentInstance item,
            ) {
              if (item.id != equipmentId) {
                return item;
              }
              return item.copyWith(enchant: enchant);
            }).toList(),
          ),
        ),
        potionStackKey,
      );
    }

    final ({
      CharacterType type,
      int index,
      CharacterProgress character,
      EquipmentInstance item,
    })?
    equippedEntry = _findEquippedItem(state.characters, equipmentId);
    if (equippedEntry == null) {
      return state;
    }

    final EquipmentEnchant enchant = enchantService.buildEnchant(
      equipment: equippedEntry.item,
      potion: potion,
      blueprint: blueprint,
    );
    final CharacterProgress updatedCharacter = equippedEntry.character.copyWith(
      equipment: equippedEntry.character.equipment.equip(
        equippedEntry.item.copyWith(enchant: enchant),
      ),
    );

    final List<CharacterProgress> source =
        equippedEntry.type == CharacterType.mercenary
        ? state.characters.mercenaries
        : state.characters.homunculi;
    final List<CharacterProgress> nextList = <CharacterProgress>[...source];
    nextList[equippedEntry.index] = updatedCharacter;

    return _consumePotion(
      state.copyWith(
        characters: equippedEntry.type == CharacterType.mercenary
            ? state.characters.copyWith(mercenaries: nextList)
            : state.characters.copyWith(homunculi: nextList),
      ),
      potionStackKey,
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
