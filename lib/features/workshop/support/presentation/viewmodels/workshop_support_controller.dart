import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/use_cases/configure_workshop_support_assignment_use_case.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_labels.dart';

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
      _session.appendLog('호문쿨루스를 찾을 수 없음');
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
        _session.appendLog('${_slotLabel(slotId)} 슬롯이 이미 사용 중');
      } else if (assignedToBattle) {
        _session.appendLog('전투에 배치된 호문쿨루스는 작업실에 둘 수 없음');
      } else if (beforeSlot != null && !wasAssignedToSlot) {
        _session.appendLog('다른 작업실 슬롯에 이미 배치됨');
      } else {
        _session.appendLog('작업실 보조 슬롯이 가득 참');
      }
      return;
    }

    _session.appendLog(
      wasAssignedToSlot
          ? '${character.name} / 작업실 ${workshopSupportSlotLabel(slotId)} 해제'
          : '${character.name} / 작업실 ${workshopSupportSlotLabel(slotId)} 배치',
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

  String _slotLabel(String slotId) => workshopSupportSlotLabel(slotId);
}

final Provider<WorkshopSupportController> workshopSupportControllerProvider =
    Provider<WorkshopSupportController>((Ref ref) {
      return WorkshopSupportController(
        ref.read(sessionControllerProvider.notifier),
      );
    });
