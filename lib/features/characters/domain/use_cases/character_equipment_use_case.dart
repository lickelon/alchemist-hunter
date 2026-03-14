import 'package:alchemist_hunter/core/session/state/session_state.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

class CharacterEquipmentUseCase {
  const CharacterEquipmentUseCase();

  SessionState equip({
    required SessionState state,
    required CharacterType type,
    required String characterId,
    required String equipmentId,
  }) {
    final List<CharacterProgress> source = _sourceList(state, type);
    final int characterIndex = source.indexWhere(
      (CharacterProgress character) => character.id == characterId,
    );
    if (characterIndex < 0) {
      return state;
    }

    final List<EquipmentInstance> inventory = <EquipmentInstance>[
      ...state.town.equipmentInventory,
    ];
    final int inventoryIndex = inventory.indexWhere(
      (EquipmentInstance item) => item.id == equipmentId,
    );
    if (inventoryIndex < 0) {
      return state;
    }

    final CharacterProgress current = source[characterIndex];
    final EquipmentInstance nextItem = inventory.removeAt(inventoryIndex);
    final EquipmentInstance? previous = current.equipment.itemForSlot(
      nextItem.slot,
    );
    if (previous != null) {
      inventory.insert(0, previous);
    }

    final CharacterProgress updated = current.copyWith(
      equipment: current.equipment.equip(nextItem),
    );
    return _applyCharacterUpdate(
      state: state,
      type: type,
      source: source,
      characterIndex: characterIndex,
      updated: updated,
      inventory: inventory,
    );
  }

  SessionState unequip({
    required SessionState state,
    required CharacterType type,
    required String characterId,
    required EquipmentSlot slot,
  }) {
    final List<CharacterProgress> source = _sourceList(state, type);
    final int characterIndex = source.indexWhere(
      (CharacterProgress character) => character.id == characterId,
    );
    if (characterIndex < 0) {
      return state;
    }

    final CharacterProgress current = source[characterIndex];
    final EquipmentInstance? equipped = current.equipment.itemForSlot(slot);
    if (equipped == null) {
      return state;
    }

    final List<EquipmentInstance> inventory = <EquipmentInstance>[
      equipped,
      ...state.town.equipmentInventory,
    ];
    final CharacterProgress updated = current.copyWith(
      equipment: current.equipment.clearSlot(slot),
    );
    return _applyCharacterUpdate(
      state: state,
      type: type,
      source: source,
      characterIndex: characterIndex,
      updated: updated,
      inventory: inventory,
    );
  }

  List<CharacterProgress> _sourceList(SessionState state, CharacterType type) {
    return type == CharacterType.mercenary
        ? state.characters.mercenaries
        : state.characters.homunculi;
  }

  SessionState _applyCharacterUpdate({
    required SessionState state,
    required CharacterType type,
    required List<CharacterProgress> source,
    required int characterIndex,
    required CharacterProgress updated,
    required List<EquipmentInstance> inventory,
  }) {
    final List<CharacterProgress> nextCharacters = <CharacterProgress>[
      ...source,
    ];
    nextCharacters[characterIndex] = updated;

    return state.copyWith(
      town: state.town.copyWith(equipmentInventory: inventory),
      characters: type == CharacterType.mercenary
          ? state.characters.copyWith(mercenaries: nextCharacters)
          : state.characters.copyWith(homunculi: nextCharacters),
    );
  }
}
