import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_runtime_selectors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final battleStageStatusLabelProvider = Provider.family<String, String>((
  Ref ref,
  String stageId,
) {
  final BattleExpeditionState expedition = ref.watch(
    battleStageExpeditionStateProvider(stageId),
  );
  return switch (expedition.status) {
    BattleExpeditionStatus.idle => '대기',
    BattleExpeditionStatus.searching => '적 탐색 중',
    BattleExpeditionStatus.battling => '전투 진행 중',
    BattleExpeditionStatus.recovering => '복구 중',
  };
});

final battleStagePendingClaimLabelProvider = Provider.family<String, String>((
  Ref ref,
  String stageId,
) {
  final BattlePendingClaim claim = ref.watch(
    battleStageExpeditionStateProvider(
      stageId,
    ).select((BattleExpeditionState expedition) => expedition.pendingClaim),
  );
  if (claim.isEmpty) {
    return '수령 대기 보상 없음';
  }
  return '골드 ${battleSignedValueLabel(claim.gold)} / 정수 ${battleSignedValueLabel(claim.essence)} / 재료 ${claim.materials.length}종';
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
  final String wipeLabel = log.wipedParty ? ' / 전멸' : '';
  final String fallbackLabel = log.usedLoadoutFallback ? ' / 포션 부족' : '';
  return '${log.success ? '성공' : '실패'}$wipeLabel / 골드 ${battleSignedValueLabel(log.gold)} / 정수 ${battleSignedValueLabel(log.essence)} / 재료 ${log.materials.length}종$fallbackLabel';
});
