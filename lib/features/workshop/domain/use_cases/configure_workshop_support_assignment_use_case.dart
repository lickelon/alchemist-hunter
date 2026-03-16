import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';

class ConfigureWorkshopSupportAssignmentUseCase {
  const ConfigureWorkshopSupportAssignmentUseCase({
    this.maxAssignedCount = WorkshopSupportService.maxAssignedCount,
  });

  final int maxAssignedCount;

  SessionState toggleHomunculus({
    required SessionState state,
    required String slotId,
    required String characterId,
  }) {
    if (!_homunculusExists(state.characters, characterId)) {
      return state;
    }

    final Map<String, String> currentAssignments =
        <String, String>{...state.workshop.supportAssignmentsByFunction};
    if (currentAssignments[slotId] == characterId) {
      currentAssignments.remove(slotId);
      return state.copyWith(
        workshop: state.workshop.copyWith(
          supportAssignmentsByFunction: currentAssignments,
        ),
      );
    }

    if (currentAssignments.containsKey(slotId)) {
      return state;
    }
    if (currentAssignments.values.contains(characterId)) {
      return state;
    }
    if (currentAssignments.length >= maxAssignedCount) {
      return state;
    }
    final bool assignedToBattle = state.battle.stageAssignments.values.any((
      List<String> assignedIds,
    ) {
      return assignedIds.contains(characterId);
    });
    if (assignedToBattle) {
      return state;
    }

    currentAssignments[slotId] = characterId;

    return state.copyWith(
      workshop: state.workshop.copyWith(
        supportAssignmentsByFunction: currentAssignments,
      ),
    );
  }

  bool _homunculusExists(CharactersState state, String characterId) {
    return state.homunculi.any(
      (CharacterProgress character) => character.id == characterId,
    );
  }
}
