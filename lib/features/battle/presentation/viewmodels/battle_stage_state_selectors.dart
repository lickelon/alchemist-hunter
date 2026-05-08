import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_progression_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<List<String>> unlockedStageListProvider = Provider<List<String>>(
  (Ref ref) {
    return ref.watch(stageCatalogProvider);
  },
);

final Provider<int> battleGoldProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select((SessionState state) => state.player.gold),
  );
});

final Provider<int> battleEssenceProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.player.essence,
    ),
  );
});

final Provider<ProgressState> battleProgressProvider = Provider<ProgressState>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.battle.progress,
    ),
  );
});

final battleStageUnlockedProvider = Provider.family<bool, String>((
  Ref ref,
  String stageId,
) {
  final ProgressState progress = ref.watch(battleProgressProvider);
  final BattleStageDefinition stage = ref
      .watch(battleCatalogRepositoryProvider)
      .stageDefinition(stageId);
  return const BattleProgressionService().isStageUnlocked(
    progress: progress,
    stage: stage,
  );
});

final battleStageLockReasonProvider = Provider.family<String, String>((
  Ref ref,
  String stageId,
) {
  final BattleStageDefinition stage = ref
      .watch(battleCatalogRepositoryProvider)
      .stageDefinition(stageId);
  return const BattleProgressionService().lockReason(stage);
});

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

final battleStageCurrentBattleProvider =
    Provider.family<BattlePlaybackState?, String>((Ref ref, String stageId) {
      return ref
          .watch(battleStageExpeditionStateProvider(stageId))
          .currentBattle;
    });

final battleStageRecentLogsProvider =
    Provider.family<List<BattleLogEntry>, String>((Ref ref, String stageId) {
      return ref.watch(battleStageExpeditionStateProvider(stageId)).recentLogs;
    });

final battleStageCurrentActionLogsProvider =
    Provider.family<List<BattleActionLog>, String>((Ref ref, String stageId) {
      final BattleExpeditionState expedition = ref.watch(
        battleStageExpeditionStateProvider(stageId),
      );
      final BattlePlaybackState? currentBattle = expedition.currentBattle;
      if (currentBattle == null) {
        return const <BattleActionLog>[];
      }
      return currentBattle.revealedActions(elapsed: expedition.phaseProgress);
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

final battleStageStatusLabelProvider = Provider.family<String, String>((
  Ref ref,
  String stageId,
) {
  final BattleExpeditionState expedition = ref.watch(
    battleStageExpeditionStateProvider(stageId),
  );
  final BattleStageDefinition stage = ref
      .watch(battleCatalogRepositoryProvider)
      .stageDefinition(stageId);
  final BattlePlaybackState? currentBattle = expedition.currentBattle;
  return switch (expedition.status) {
    BattleExpeditionStatus.idle => '대기',
    BattleExpeditionStatus.searching =>
      '적 탐색 중 / ${expedition.phaseProgress.inSeconds}초 / ${stage.searchDuration.inSeconds}초',
    BattleExpeditionStatus.battling => '전투 진행 중',
    BattleExpeditionStatus.paused =>
      currentBattle == null ? '정지 / 적 탐색 보류' : '정지 / 전투 보류',
  };
});

final battleStagePendingClaimLabelProvider = Provider.family<String, String>((
  Ref ref,
  String stageId,
) {
  final BattleExpeditionState expedition = ref.watch(
    battleStageExpeditionStateProvider(stageId),
  );
  final BattlePendingClaim claim = expedition.pendingClaim;
  final int materialKinds = claim.materials.length;
  if (claim.isEmpty) {
    return '수령 대기 보상 없음';
  }
  return '골드 ${battleSignedValueLabel(claim.gold)} / 에센스 ${battleSignedValueLabel(claim.essence)} / 재료 $materialKinds종 / 경험치 ${claim.characterXp.values.fold<int>(0, (int total, int value) => total + value)}';
});

final battleStageLastResultLabelProvider = Provider.family<String, String>((
  Ref ref,
  String stageId,
) {
  final List<BattleLogEntry> logs = ref.watch(
    battleStageRecentLogsProvider(stageId),
  );
  if (logs.isEmpty) {
    return '최근 결과 없음';
  }
  final BattleLogEntry log = logs.first;
  return '최근 결과 ${log.success ? '성공' : '실패'} / 골드 ${battleSignedValueLabel(log.gold)} / 재료 ${log.materials.length}종${log.usedLoadoutFallback ? ' / 포션 미적용' : ''}';
});
