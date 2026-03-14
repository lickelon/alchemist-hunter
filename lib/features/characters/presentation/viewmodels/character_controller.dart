import 'package:alchemist_hunter/features/characters/domain/use_cases/character_progression_use_case.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterController {
  CharacterController(
    this._session, {
    CharacterProgressionUseCase characterDomain = const CharacterProgressionUseCase(),
  }) : _characterDomain = characterDomain;

  final SessionController _session;
  final CharacterProgressionUseCase _characterDomain;

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
          ? 'Character not found'
          : !currentCharacter.canRankUp
          ? 'Rank up condition not met'
          : 'Rank up ${currentCharacter.name} -> Rank ${currentCharacter.rank + 1}',
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
          ? 'Character not found'
          : !currentCharacter.canTierUp
          ? 'Tier up condition not met'
          : (current.player.materialInventory[requiredMaterial] ?? 0) < 1
          ? 'Tier material missing: $requiredMaterial'
          : 'Tier up ${currentCharacter.name} -> Tier ${currentCharacter.tierIndex + 1}',
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

  void _apply(SessionState nextState, {required String logMessage}) {
    _session.applyState(nextState);
    _session.appendLog(logMessage);
  }
}

final Provider<CharacterController> characterControllerProvider =
    Provider<CharacterController>((Ref ref) {
      return CharacterController(ref.read(sessionControllerProvider.notifier));
    });
