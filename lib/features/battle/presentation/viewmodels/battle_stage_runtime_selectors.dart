import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_party_power_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final battleStageAssignmentProvider = Provider.family<List<String>, String>((
  Ref ref,
  String stageId,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) =>
          state.battle.stageAssignments[stageId] ?? const <String>[],
    ),
  );
});

final battleStageExpeditionStateProvider =
    Provider.family<BattleExpeditionState, String>((Ref ref, String stageId) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) =>
              state.battle.stageExpeditions[stageId] ??
              const BattleExpeditionState(
                status: BattleExpeditionStatus.idle,
                lastProgressedAt: null,
                phaseProgress: Duration.zero,
              ),
        ),
      );
    });

final battleStageRunStateProvider = Provider.family<BattleRunState?, String>((
  Ref ref,
  String stageId,
) {
  return ref.watch(battleStageExpeditionStateProvider(stageId)).runState;
});

final battleStageCurrentEncounterProvider =
    Provider.family<BattleEncounterRuntimeState?, String>((
      Ref ref,
      String stageId,
    ) {
      return ref.watch(battleStageRunStateProvider(stageId))?.currentEncounter;
    });

final battleStageRecentLogsProvider =
    Provider.family<List<BattleLogEntry>, String>((Ref ref, String stageId) {
      return ref.watch(battleStageExpeditionStateProvider(stageId)).recentLogs;
    });

final battleStageCurrentActionLogsProvider =
    Provider.family<List<BattleActionLog>, String>((Ref ref, String stageId) {
      return ref
              .watch(battleStageCurrentEncounterProvider(stageId))
              ?.recentActionLogs ??
          const <BattleActionLog>[];
    });

final battleStagePartyPowerProvider = Provider.family<int, String>((
  Ref ref,
  String stageId,
) {
  final List<String> assignedIds = ref.watch(
    battleStageAssignmentProvider(stageId),
  );
  return const BattlePartyPowerService().totalPower(
    ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.characters,
      ),
    ),
    assignedCharacterIds: assignedIds,
  );
});
