import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/configure_battle_assignment_use_case.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';

class BattleAssignmentController {
  const BattleAssignmentController(
    this._session, {
    ConfigureBattleAssignmentUseCase configureBattleAssignmentUseCase =
        const ConfigureBattleAssignmentUseCase(),
  }) : _configureBattleAssignmentUseCase = configureBattleAssignmentUseCase;

  final SessionController _session;
  final ConfigureBattleAssignmentUseCase _configureBattleAssignmentUseCase;

  void toggleStageAssignment(String stageId, String characterId) {
    final SessionState current = _session.snapshot();
    final List<String> before =
        current.battle.stageAssignments[stageId] ?? const <String>[];
    final CharacterProgress? character = _findCharacter(current, characterId);
    final bool workshopAssigned = current
        .workshop
        .supportAssignmentsByFunction
        .values
        .contains(characterId);
    final bool assignedToOtherStage = current.battle.stageAssignments.entries
        .any((MapEntry<String, List<String>> entry) {
          return entry.key != stageId && entry.value.contains(characterId);
        });
    if (workshopAssigned && !before.contains(characterId)) {
      _session.appendLog('Character assigned to workshop');
      return;
    }
    if (assignedToOtherStage && !before.contains(characterId)) {
      _session.appendLog('Character assigned to another stage');
      return;
    }
    final SessionState nextState = _configureBattleAssignmentUseCase
        .toggleCharacter(
          state: current,
          stageId: stageId,
          characterId: characterId,
        );
    final List<String> after =
        nextState.battle.stageAssignments[stageId] ?? const <String>[];

    if (character == null) {
      _session.appendLog('Character not found');
      return;
    }

    _session.applyState(nextState);
    if (identical(nextState, current)) {
      _session.appendLog('Battle party full for $stageId');
      return;
    }

    final bool added =
        !before.contains(characterId) && after.contains(characterId);
    _session.appendLog(
      added
          ? 'Assigned ${character.name} to $stageId'
          : 'Removed ${character.name} from $stageId',
    );
  }

  CharacterProgress? _findCharacter(SessionState state, String characterId) {
    for (final CharacterProgress character in state.characters.mercenaries) {
      if (character.id == characterId) {
        return character;
      }
    }
    for (final CharacterProgress character in state.characters.homunculi) {
      if (character.id == characterId) {
        return character;
      }
    }
    return null;
  }
}
