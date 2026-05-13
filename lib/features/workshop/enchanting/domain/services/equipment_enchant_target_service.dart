import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

class EquipmentEnchantTarget {
  const EquipmentEnchantTarget({
    required this.item,
    this.ownerType,
    this.ownerIndex,
    this.ownerCharacter,
  });

  final EquipmentInstance item;
  final CharacterType? ownerType;
  final int? ownerIndex;
  final CharacterProgress? ownerCharacter;

  bool get isStored => ownerType == null;
}

class EquipmentEnchantReservation {
  const EquipmentEnchantReservation({
    required this.town,
    required this.characters,
  });

  final TownState town;
  final CharactersState characters;
}

class EquipmentEnchantTargetService {
  const EquipmentEnchantTargetService();

  EquipmentEnchantTarget? findTarget({
    required TownState town,
    required CharactersState characters,
    required String equipmentId,
  }) {
    final EquipmentInstance? storedItem = _findStoredItem(
      town.equipmentInventory,
      equipmentId,
    );
    if (storedItem != null) {
      return EquipmentEnchantTarget(item: storedItem);
    }
    return _findEquippedItem(characters, equipmentId);
  }

  EquipmentEnchantReservation reserve({
    required TownState town,
    required CharactersState characters,
    required EquipmentEnchantTarget target,
  }) {
    if (target.isStored) {
      return EquipmentEnchantReservation(
        town: town.copyWith(
          equipmentInventory: town.equipmentInventory
              .where((EquipmentInstance item) => item.id != target.item.id)
              .toList(),
        ),
        characters: characters,
      );
    }

    final CharacterProgress character = target.ownerCharacter!;
    final CharacterProgress updatedCharacter = character.copyWith(
      equipment: character.equipment.clearSlot(target.item.slot),
    );
    final List<CharacterProgress> source =
        target.ownerType == CharacterType.mercenary
        ? characters.mercenaries
        : characters.homunculi;
    final List<CharacterProgress> nextList = <CharacterProgress>[...source];
    nextList[target.ownerIndex!] = updatedCharacter;

    return EquipmentEnchantReservation(
      town: town,
      characters: target.ownerType == CharacterType.mercenary
          ? characters.copyWith(mercenaries: nextList)
          : characters.copyWith(homunculi: nextList),
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

  EquipmentEnchantTarget? _findEquippedItem(
    CharactersState state,
    String equipmentId,
  ) {
    for (int index = 0; index < state.mercenaries.length; index++) {
      final CharacterProgress character = state.mercenaries[index];
      for (final EquipmentSlot slot in EquipmentSlot.values) {
        final EquipmentInstance? item = character.equipment.itemForSlot(slot);
        if (item?.id == equipmentId) {
          return EquipmentEnchantTarget(
            item: item!,
            ownerType: CharacterType.mercenary,
            ownerIndex: index,
            ownerCharacter: character,
          );
        }
      }
    }

    for (int index = 0; index < state.homunculi.length; index++) {
      final CharacterProgress character = state.homunculi[index];
      for (final EquipmentSlot slot in EquipmentSlot.values) {
        final EquipmentInstance? item = character.equipment.itemForSlot(slot);
        if (item?.id == equipmentId) {
          return EquipmentEnchantTarget(
            item: item!,
            ownerType: CharacterType.homunculus,
            ownerIndex: index,
            ownerCharacter: character,
          );
        }
      }
    }
    return null;
  }
}
