import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_status_view_model.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_status_layout.dart';
import 'package:flutter/widgets.dart';

class BattleStageStatusTimelineBuffer {
  final List<String> _lines = <String>[];
  final Set<String> _keys = <String>{};
  final ScrollController scrollController = ScrollController();

  List<String> get lines => _lines;

  void dispose() {
    scrollController.dispose();
  }

  void appendActions({
    required BattleEncounterRuntimeState? encounter,
    required List<BattleActionLog> actions,
    required VoidCallback onChanged,
  }) {
    if (encounter == null || actions.isEmpty) {
      return;
    }

    final bool shouldFollow =
        !scrollController.hasClients ||
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent -
                BattleStageStatusLayout.timelineFollowThreshold;
    bool appended = false;
    for (final BattleActionLog action in actions) {
      final String key = _timelineActionKey(encounter, action);
      if (_keys.add(key)) {
        _lines.add(battleActionTimelineLabel(action));
        appended = true;
      }
    }
    if (!appended) {
      return;
    }
    onChanged();
    if (shouldFollow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) {
          return;
        }
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    }
  }

  String _timelineActionKey(
    BattleEncounterRuntimeState encounter,
    BattleActionLog action,
  ) {
    return <Object?>[
      encounter.encounterId,
      encounter.encounterIndex,
      action.lifecycle,
      action.turn,
      action.type,
      action.actorId,
      action.targetId,
      action.skillId,
      action.statusType?.name,
      action.hit,
      action.critical,
      action.damage,
      action.healing,
      action.mpSpent,
      action.actorHpAfter,
      action.actorMpAfter,
      action.targetHpAfter,
      action.targetShieldAfter,
      action.message,
    ].join('|');
  }
}
