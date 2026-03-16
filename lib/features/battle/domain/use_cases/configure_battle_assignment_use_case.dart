import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';

class ConfigureBattleAssignmentUseCase {
  const ConfigureBattleAssignmentUseCase({this.maxPartySize = 3});

  final int maxPartySize;

  SessionState toggleCharacter({
    required SessionState state,
    required String stageId,
    required String characterId,
  }) {
    if (!_characterExists(state.characters, characterId)) {
      return state;
    }

    final List<String> currentAssignment = List<String>.from(
      state.battle.stageAssignments[stageId] ?? const <String>[],
    );
    final bool assigned = currentAssignment.contains(characterId);
    if (assigned) {
      currentAssignment.remove(characterId);
    } else {
      final bool assignedToOtherStage = state.battle.stageAssignments.entries.any((
        MapEntry<String, List<String>> entry,
      ) {
        return entry.key != stageId && entry.value.contains(characterId);
      });
      if (assignedToOtherStage) {
        return state;
      }
      final bool assignedToWorkshop = state
          .workshop
          .supportAssignmentsByFunction
          .values
          .contains(characterId);
      if (assignedToWorkshop) {
        return state;
      }
      if (currentAssignment.length >= maxPartySize) {
        return state;
      }
      currentAssignment.add(characterId);
    }

    final Map<String, List<String>> nextAssignments =
        <String, List<String>>{...state.battle.stageAssignments};
    if (currentAssignment.isEmpty) {
      nextAssignments.remove(stageId);
    } else {
      nextAssignments[stageId] = currentAssignment;
    }

    return state.copyWith(
      battle: state.battle.copyWith(stageAssignments: nextAssignments),
    );
  }

  bool _characterExists(CharactersState state, String characterId) {
    return state.mercenaries.any(
          (CharacterProgress character) => character.id == characterId,
        ) ||
        state.homunculi.any(
          (CharacterProgress character) => character.id == characterId,
        );
  }
}
