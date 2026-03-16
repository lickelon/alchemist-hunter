import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/configure_workshop_support_assignment_use_case.dart';

class WorkshopSupportController {
  WorkshopSupportController(
    this._session, {
    ConfigureWorkshopSupportAssignmentUseCase configureUseCase =
        const ConfigureWorkshopSupportAssignmentUseCase(),
  }) : _configureUseCase = configureUseCase;

  final SessionController _session;
  final ConfigureWorkshopSupportAssignmentUseCase _configureUseCase;

  void toggleAssignment(String slotId, String characterId) {
    final SessionState current = _session.snapshot();
    final CharacterProgress? character = _findHomunculus(current, characterId);
    if (character == null) {
      _session.appendLog('Homunculus not found');
      return;
    }

    final String? beforeSlot = _assignedSlotId(current, characterId);
    final bool wasAssignedToSlot =
        current.workshop.supportAssignmentsByFunction[slotId] == characterId;
    final bool slotOccupiedByOther =
        current.workshop.supportAssignmentsByFunction.containsKey(slotId) &&
        !wasAssignedToSlot;
    final bool assignedToBattle = current.battle.stageAssignments.values.any((
      List<String> assignedIds,
    ) {
      return assignedIds.contains(characterId);
    });
    final SessionState nextState = _configureUseCase.toggleHomunculus(
      state: current,
      slotId: slotId,
      characterId: characterId,
    );

    _session.applyState(nextState);
    if (identical(nextState, current)) {
      if (slotOccupiedByOther) {
        _session.appendLog('Workshop slot already occupied');
      } else if (assignedToBattle) {
        _session.appendLog('Character assigned to battle');
      } else if (beforeSlot != null && !wasAssignedToSlot) {
        _session.appendLog('Character assigned to another workshop slot');
      } else {
        _session.appendLog('Workshop support slots full');
      }
      return;
    }

    _session.appendLog(
      wasAssignedToSlot
          ? 'Removed ${character.name} from workshop ${_slotLabel(slotId)}'
          : 'Assigned ${character.name} to workshop ${_slotLabel(slotId)}',
    );
  }

  CharacterProgress? _findHomunculus(SessionState state, String characterId) {
    for (final CharacterProgress character in state.characters.homunculi) {
      if (character.id == characterId) {
        return character;
      }
    }
    return null;
  }

  String? _assignedSlotId(SessionState state, String characterId) {
    for (final MapEntry<String, String> entry
        in state.workshop.supportAssignmentsByFunction.entries) {
      if (entry.value == characterId) {
        return entry.key;
      }
    }
    return null;
  }

  String _slotLabel(String slotId) {
    switch (slotId) {
      case WorkshopSupportService.extractionSlot:
        return '추출';
      case WorkshopSupportService.craftingSlot:
        return '제조';
      case WorkshopSupportService.enchantSlot:
        return '인챈트';
      case WorkshopSupportService.hatchSlot:
        return '부화';
    }
    return slotId;
  }
}

final Provider<WorkshopSupportController> workshopSupportControllerProvider =
    Provider<WorkshopSupportController>((Ref ref) {
      return WorkshopSupportController(ref.read(sessionControllerProvider.notifier));
    });
