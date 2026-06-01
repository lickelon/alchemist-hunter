import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/use_cases/character_equipment_use_case.dart';
import 'package:alchemist_hunter/features/characters/domain/use_cases/character_progression_use_case.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_controller_log_messages.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterController {
  CharacterController(
    this._session, {
    CharacterProgressionUseCase characterDomain =
        const CharacterProgressionUseCase(),
    CharacterEquipmentUseCase characterEquipmentUseCase =
        const CharacterEquipmentUseCase(),
  }) : _characterDomain = characterDomain,
       _characterEquipmentUseCase = characterEquipmentUseCase;

  final SessionController _session;
  final CharacterProgressionUseCase _characterDomain;
  final CharacterEquipmentUseCase _characterEquipmentUseCase;

  void rankUp(CharacterType type, String characterId) {
    final SessionState current = _session.snapshot();
    final CharacterProgress? currentCharacter = _findCharacter(
      current,
      type,
      characterId,
    );
    final SessionState nextState = _characterDomain.rankUp(
      state: current,
      type: type,
      characterId: characterId,
    );
    _apply(nextState, logMessage: characterRankUpLogMessage(currentCharacter));
  }

  void tierUp(CharacterType type, String characterId) {
    final SessionState current = _session.snapshot();
    final CharacterProgress? currentCharacter = _findCharacter(
      current,
      type,
      characterId,
    );
    final SessionState nextState = _characterDomain.tierUp(
      state: current,
      type: type,
      characterId: characterId,
    );
    final String? requiredMaterial = currentCharacter == null
        ? null
        : characterTierMaterialKey(currentCharacter);
    _apply(
      nextState,
      logMessage: characterTierUpLogMessage(
        current: current,
        character: currentCharacter,
        requiredMaterial: requiredMaterial,
      ),
    );
  }

  void equip(CharacterType type, String characterId, String equipmentId) {
    final SessionState current = _session.snapshot();
    final CharacterProgress? currentCharacter = _findCharacter(
      current,
      type,
      characterId,
    );
    final EquipmentInstance? item = _findInventoryItem(current, equipmentId);
    final SessionState nextState = _characterEquipmentUseCase.equip(
      state: current,
      type: type,
      characterId: characterId,
      equipmentId: equipmentId,
    );
    _apply(
      nextState,
      logMessage: characterEquipLogMessage(
        character: currentCharacter,
        item: item,
      ),
    );
  }

  void unequip(CharacterType type, String characterId, EquipmentSlot slot) {
    final SessionState current = _session.snapshot();
    final CharacterProgress? currentCharacter = _findCharacter(
      current,
      type,
      characterId,
    );
    final EquipmentInstance? item = currentCharacter?.equipment.itemForSlot(
      slot,
    );
    final SessionState nextState = _characterEquipmentUseCase.unequip(
      state: current,
      type: type,
      characterId: characterId,
      slot: slot,
    );
    _apply(
      nextState,
      logMessage: characterUnequipLogMessage(
        character: currentCharacter,
        item: item,
        slot: slot,
      ),
    );
  }

  CharacterProgress? _findCharacter(
    SessionState state,
    CharacterType type,
    String characterId,
  ) {
    final List<CharacterProgress> source = type == CharacterType.mercenary
        ? state.characters.mercenaries
        : state.characters.homunculi;
    for (final CharacterProgress character in source) {
      if (character.id == characterId) {
        return character;
      }
    }
    return null;
  }

  EquipmentInstance? _findInventoryItem(
    SessionState state,
    String equipmentId,
  ) {
    for (final EquipmentInstance item in state.town.equipmentInventory) {
      if (item.id == equipmentId) {
        return item;
      }
    }
    return null;
  }

  void _apply(SessionState nextState, {required String logMessage}) {
    _session.applyState(nextState);
    _session.appendLog(logMessage);
  }
}

final Provider<CharacterController> characterControllerProvider =
    Provider<CharacterController>((Ref ref) {
      return CharacterController(ref.read(sessionControllerProvider.notifier));
    });
