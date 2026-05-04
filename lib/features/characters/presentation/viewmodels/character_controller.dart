import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/use_cases/character_equipment_use_case.dart';
import 'package:alchemist_hunter/features/characters/domain/use_cases/character_progression_use_case.dart';
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
    _apply(
      nextState,
      logMessage: currentCharacter == null
          ? '캐릭터를 찾을 수 없음'
          : !currentCharacter.canRankUp
          ? '랭크업 조건 미충족'
          : '${currentCharacter.name} 랭크업 -> 랭크 ${currentCharacter.rank + 1}',
    );
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
        : _tierMaterialKey(currentCharacter);
    _apply(
      nextState,
      logMessage: currentCharacter == null
          ? '캐릭터를 찾을 수 없음'
          : !currentCharacter.canTierUp
          ? '티어업 조건 미충족'
          : (current.player.materialInventory[requiredMaterial] ?? 0) < 1
          ? '승급 재료 부족'
          : '${currentCharacter.name} 티어업 -> 티어 ${currentCharacter.tierIndex + 1}',
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
      logMessage: currentCharacter == null
          ? '캐릭터를 찾을 수 없음'
          : item == null
          ? '장비를 찾을 수 없음'
          : '${currentCharacter.name}에 ${item.name} 장착',
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
      logMessage: currentCharacter == null
          ? '캐릭터를 찾을 수 없음'
          : item == null
          ? '${_slotLabel(slot)} 슬롯에 장착된 장비 없음'
          : '${currentCharacter.name}에서 ${item.name} 해제',
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

  String _tierMaterialKey(CharacterProgress character) {
    final int nextTier = character.tierIndex + 1;
    if (character.type == CharacterType.mercenary) {
      return 'tier_mat_mercenary_$nextTier';
    }
    return 'tier_mat_homunculus_$nextTier';
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

  String _slotLabel(EquipmentSlot slot) {
    return switch (slot) {
      EquipmentSlot.weapon => '무기',
      EquipmentSlot.armor => '방어구',
      EquipmentSlot.accessory => '장신구',
    };
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
