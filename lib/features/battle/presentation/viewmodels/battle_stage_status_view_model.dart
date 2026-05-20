import 'package:alchemist_hunter/features/battle/domain/models.dart';

class BattleStagePhaseProgress {
  const BattleStagePhaseProgress({required this.value});

  final double value;
}

BattleStagePhaseProgress buildBattleStagePhaseProgress({
  required BattleExpeditionState expedition,
  required BattleStageDefinition stage,
  required Duration battleActionInterval,
}) {
  switch (expedition.status) {
    case BattleExpeditionStatus.idle:
      return const BattleStagePhaseProgress(value: 0);
    case BattleExpeditionStatus.searching:
      return BattleStagePhaseProgress(
        value: stage.searchDuration.inMilliseconds == 0
            ? 0
            : expedition.phaseProgress.inMilliseconds /
                  stage.searchDuration.inMilliseconds,
      );
    case BattleExpeditionStatus.battling:
      final Duration lifecycleElapsed = _currentLifecycleElapsed(
        expedition.phaseProgress,
        battleActionInterval,
      );
      return BattleStagePhaseProgress(
        value: battleActionInterval.inMilliseconds == 0
            ? 0
            : lifecycleElapsed.inMilliseconds /
                  battleActionInterval.inMilliseconds,
      );
    case BattleExpeditionStatus.recovering:
      return BattleStagePhaseProgress(
        value: stage.recoveryDuration.inMilliseconds == 0
            ? 0
            : expedition.phaseProgress.inMilliseconds /
                  stage.recoveryDuration.inMilliseconds,
      );
  }
}

List<String> battleStageTimelineLines({
  required BattleExpeditionState expedition,
  required List<BattleActionLog> currentActions,
}) {
  if (currentActions.isNotEmpty) {
    return currentActions
        .map(battleActionTimelineLabel)
        .toList(growable: false);
  }
  return switch (expedition.status) {
    BattleExpeditionStatus.searching => const <String>['적을 탐색 중입니다.'],
    BattleExpeditionStatus.battling => const <String>['첫 행동 대기 중'],
    BattleExpeditionStatus.recovering => const <String>['파티 복구 중입니다.'],
    BattleExpeditionStatus.idle => const <String>['진행 중인 전투가 없습니다.'],
  };
}

String battleStagePhaseLabel(BattleExpeditionStatus status) {
  return switch (status) {
    BattleExpeditionStatus.idle => '대기',
    BattleExpeditionStatus.searching => '탐색',
    BattleExpeditionStatus.battling => '전투',
    BattleExpeditionStatus.recovering => '복구',
  };
}

Duration _currentLifecycleElapsed(
  Duration phaseProgress,
  Duration battleActionInterval,
) {
  final int lifecycleMicros = battleActionInterval.inMicroseconds;
  if (lifecycleMicros == 0) {
    return Duration.zero;
  }
  final int remainder = phaseProgress.inMicroseconds % lifecycleMicros;
  return Duration(microseconds: remainder);
}

String battleActionTimelineLabel(BattleActionLog action) {
  if (action.type == BattleActionType.regen) {
    return '${action.actorName} 재생 +${action.healing}';
  }
  if (action.type == BattleActionType.skillUse) {
    return '${action.actorName} ${action.skillName ?? '스킬'} 사용';
  }
  if (action.type == BattleActionType.lifesteal) {
    return '${action.actorName} 흡혈 +${action.healing}';
  }
  if (action.type == BattleActionType.heal) {
    return '${action.actorName} -> ${action.targetName ?? '대상'} 회복 +${action.healing}';
  }
  if (action.type == BattleActionType.modifier) {
    return '${action.actorName} 효과 부여';
  }
  if (action.type == BattleActionType.status) {
    final String valueLabel = action.damage > 0 ? ' ${action.damage} 피해' : '';
    return '${action.actorName} 상태효과$valueLabel';
  }
  if (action.type == BattleActionType.shield) {
    return '${action.actorName} 보호막 +${action.healing}';
  }
  if (action.type == BattleActionType.passive) {
    return '${action.actorName} 패시브 발동';
  }
  if (!action.hit) {
    return '${action.actorName} -> ${action.targetName ?? '대상'} 빗나감';
  }
  final String criticalLabel = action.critical ? ' / 치명타' : '';
  final String mpLabel = action.mpSpent > 0 ? ' / 마나 -${action.mpSpent}' : '';
  return '${action.actorName} -> ${action.targetName ?? '대상'} ${action.damage} 피해$criticalLabel$mpLabel';
}
