import 'package:alchemist_hunter/features/battle/domain/models.dart';

class BattleStagePhaseProgress {
  const BattleStagePhaseProgress({required this.value, required this.label});

  final double value;
  final String label;
}

BattleStagePhaseProgress buildBattleStagePhaseProgress({
  required BattleExpeditionState expedition,
  required BattleStageDefinition stage,
  required Duration battleActionInterval,
}) {
  switch (expedition.status) {
    case BattleExpeditionStatus.idle:
      return const BattleStagePhaseProgress(value: 0, label: '원정 시작 전');
    case BattleExpeditionStatus.searching:
      return BattleStagePhaseProgress(
        value: stage.searchDuration.inMilliseconds == 0
            ? 0
            : expedition.phaseProgress.inMilliseconds /
                  stage.searchDuration.inMilliseconds,
        label:
            '다음 적 탐색까지 ${formatBattleStageRemaining(stage.searchDuration, expedition.phaseProgress)}',
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
        label:
            '다음 행동까지 ${formatBattleStageRemaining(battleActionInterval, lifecycleElapsed)}',
      );
    case BattleExpeditionStatus.recovering:
      return BattleStagePhaseProgress(
        value: stage.recoveryDuration.inMilliseconds == 0
            ? 0
            : expedition.phaseProgress.inMilliseconds /
                  stage.recoveryDuration.inMilliseconds,
        label:
            '복구 완료까지 ${formatBattleStageRemaining(stage.recoveryDuration, expedition.phaseProgress)}',
      );
    case BattleExpeditionStatus.paused:
      final BattleExpeditionStatus pausedStatus =
          expedition.pausedStatus ?? BattleExpeditionStatus.searching;
      if (pausedStatus == BattleExpeditionStatus.battling) {
        final Duration lifecycleElapsed = _currentLifecycleElapsed(
          expedition.phaseProgress,
          battleActionInterval,
        );
        return BattleStagePhaseProgress(
          value: battleActionInterval.inMilliseconds == 0
              ? 0
              : lifecycleElapsed.inMilliseconds /
                    battleActionInterval.inMilliseconds,
          label: '전투 일시정지',
        );
      }
      if (pausedStatus == BattleExpeditionStatus.recovering) {
        return BattleStagePhaseProgress(
          value: stage.recoveryDuration.inMilliseconds == 0
              ? 0
              : expedition.phaseProgress.inMilliseconds /
                    stage.recoveryDuration.inMilliseconds,
          label: '복구 일시정지',
        );
      }
      return BattleStagePhaseProgress(
        value: stage.searchDuration.inMilliseconds == 0
            ? 0
            : expedition.phaseProgress.inMilliseconds /
                  stage.searchDuration.inMilliseconds,
        label: '탐색 일시정지',
      );
  }
}

List<String> battleStageTimelineLines({
  required BattleExpeditionState expedition,
  required List<BattleActionLog> currentActions,
}) {
  if (currentActions.isNotEmpty) {
    return currentActions
        .skip(currentActions.length > 6 ? currentActions.length - 6 : 0)
        .map(_formatBattleAction)
        .toList(growable: false);
  }
  return switch (expedition.status) {
    BattleExpeditionStatus.searching => const <String>['적을 탐색 중입니다.'],
    BattleExpeditionStatus.battling => const <String>['첫 행동 대기 중'],
    BattleExpeditionStatus.recovering => const <String>['파티 복구 중입니다.'],
    BattleExpeditionStatus.paused => const <String>['진행이 일시정지되었습니다.'],
    BattleExpeditionStatus.idle => const <String>['진행 중인 전투가 없습니다.'],
  };
}

String battleStagePhaseLabel(BattleExpeditionStatus status) {
  return switch (status) {
    BattleExpeditionStatus.idle => '대기',
    BattleExpeditionStatus.searching => '탐색',
    BattleExpeditionStatus.battling => '전투',
    BattleExpeditionStatus.recovering => '복구',
    BattleExpeditionStatus.paused => '정지',
  };
}

String formatBattleStageRemaining(Duration total, Duration progress) {
  final Duration remaining = total - progress;
  if (remaining <= Duration.zero) {
    return '0.0초';
  }
  final double seconds = remaining.inMilliseconds / 1000;
  return '${seconds.toStringAsFixed(1)}초';
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

String _formatBattleAction(BattleActionLog action) {
  if (action.type == BattleActionType.regen) {
    return '${action.actorName} 재생 +${action.healing}';
  }
  if (action.type == BattleActionType.mpRegen) {
    return '${action.actorName} MP 회복 +${action.healing}';
  }
  if (action.type == BattleActionType.lifesteal) {
    return '${action.actorName} 흡혈 +${action.healing}';
  }
  if (action.type == BattleActionType.heal) {
    return '${action.actorName} 회복 +${action.healing}';
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
  final String skillLabel = action.type == BattleActionType.skill
      ? ' ${action.skillName ?? '스킬'}'
      : '';
  if (!action.hit) {
    return '${action.actorName}$skillLabel -> ${action.targetName ?? '대상'} 빗나감';
  }
  final String criticalLabel = action.critical ? ' / 치명타' : '';
  final String mpLabel = action.mpSpent > 0 ? ' / MP -${action.mpSpent}' : '';
  return '${action.actorName}$skillLabel -> ${action.targetName ?? '대상'} ${action.damage} 피해$criticalLabel$mpLabel';
}
