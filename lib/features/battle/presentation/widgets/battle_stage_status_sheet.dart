import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_result_sheet.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_drop_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleStageStatusSheet extends ConsumerWidget {
  const BattleStageStatusSheet({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BattleCatalogRepository battleCatalog = ref.watch(
      battleCatalogRepositoryProvider,
    );
    final BattleStageDefinition stage = battleCatalog.stageDefinition(stageId);
    final BattleExpeditionState expedition = ref.watch(
      battleStageExpeditionStateProvider(stageId),
    );
    final BattleRunState? runState = expedition.runState;
    final BattleEncounterRuntimeState? currentEncounter =
        runState?.currentEncounter;
    final List<BattleActionLog> currentActions = ref.watch(
      battleStageCurrentActionLogsProvider(stageId),
    );
    final List<BattleLogEntry> recentLogs = ref.watch(
      battleStageRecentLogsProvider(stageId),
    );
    final int assignedCount = ref
        .watch(battleStageAssignmentProvider(stageId))
        .length;
    final int partyPower = ref.watch(battleStagePartyPowerProvider(stageId));
    final String statusLabel = ref.watch(
      battleStageStatusLabelProvider(stageId),
    );
    final String pendingLabel = ref.watch(
      battleStagePendingClaimLabelProvider(stageId),
    );
    final _PhaseProgressView progress = _buildProgress(expedition, stage);

    return AppBottomSheet(
      child: AppSheetLayout(
        title:
            '${battleStageDisplayName(stage.id, fallback: stage.name)} 전투 현황',
        header: Text(
          '권장 전투력 ${stage.recommendedPower} / 가능한 조합 ${stage.encounters.length}종',
        ),
        body: ListView(
          children: <Widget>[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                Chip(label: Text(_phaseLabel(expedition.status))),
                Chip(
                  label: Text(
                    currentEncounter == null
                        ? '교전 대기'
                        : '${currentEncounter.encounterIndex}회 ${currentEncounter.encounterName}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _StatusCard(
              title: '전투 상태판',
              child: Column(
                children: <Widget>[
                  _UnitBoardSection(
                    title: '아군',
                    units: runState?.allies ?? const <BattleRunUnitState>[],
                    emptyLabel: assignedCount == 0 ? '편성 없음' : '전투 시작 전',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _UnitBoardSection(
                    title: '적',
                    units:
                        currentEncounter?.enemies ??
                        const <BattleRunUnitState>[],
                    emptyLabel: currentEncounter == null ? '현재 교전 없음' : '적 없음',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _StatusCard(
              title: '진행',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(statusLabel),
                  const SizedBox(height: AppSpacing.xs),
                  Text(progress.label),
                  const SizedBox(height: AppSpacing.sm),
                  _SmoothProgressBar(value: progress.value.clamp(0, 1)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _StatusCard(
              title: '실시간 타임라인',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _timelineLines(
                          expedition: expedition,
                          currentActions: currentActions,
                        )
                        .map((String line) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: Text(line),
                          );
                        })
                        .toList(growable: false),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _StatusCard(
              title: '런 요약',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    <String>[
                          '편성 $assignedCount명 / 전투력 $partyPower',
                          pendingLabel,
                          '누적 승리 ${runState?.victoryCount ?? 0} / 전멸 ${runState?.wipeCount ?? 0}',
                          '누적 교전 ${runState?.encounterCount ?? 0}회',
                          if (currentEncounter != null)
                            '현재 조합 ${currentEncounter.encounterIndex}회 / ${currentEncounter.encounterName}',
                          if (currentEncounter?.usedLoadoutFallback ?? false)
                            '포션 부족으로 로드아웃 미적용',
                          if (expedition.status ==
                              BattleExpeditionStatus.recovering)
                            '복구 완료까지 ${_formatRemaining(stage.recoveryDuration, expedition.phaseProgress)}',
                        ]
                        .map((String line) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: Text(line),
                          );
                        })
                        .toList(growable: false),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return BattleStageDropSheet(stageId: stageId);
                      },
                    );
                  },
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('적 조합 / 드롭'),
                ),
                FilledButton.tonalIcon(
                  onPressed: recentLogs.isEmpty
                      ? null
                      : () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return BattleResultSheet(stageId: stageId);
                            },
                          );
                        },
                  icon: const Icon(Icons.history),
                  label: const Text('최근 기록'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _PhaseProgressView _buildProgress(
    BattleExpeditionState expedition,
    BattleStageDefinition stage,
  ) {
    switch (expedition.status) {
      case BattleExpeditionStatus.idle:
        return const _PhaseProgressView(value: 0, label: '원정 시작 전');
      case BattleExpeditionStatus.searching:
        return _PhaseProgressView(
          value: stage.searchDuration.inMilliseconds == 0
              ? 0
              : expedition.phaseProgress.inMilliseconds /
                    stage.searchDuration.inMilliseconds,
          label:
              '다음 적 탐색까지 ${_formatRemaining(stage.searchDuration, expedition.phaseProgress)}',
        );
      case BattleExpeditionStatus.battling:
        final Duration lifecycleElapsed = _currentLifecycleElapsed(
          expedition.phaseProgress,
        );
        return _PhaseProgressView(
          value: battleActionInterval.inMilliseconds == 0
              ? 0
              : lifecycleElapsed.inMilliseconds /
                    battleActionInterval.inMilliseconds,
          label:
              '다음 행동까지 ${_formatRemaining(battleActionInterval, lifecycleElapsed)}',
        );
      case BattleExpeditionStatus.recovering:
        return _PhaseProgressView(
          value: stage.recoveryDuration.inMilliseconds == 0
              ? 0
              : expedition.phaseProgress.inMilliseconds /
                    stage.recoveryDuration.inMilliseconds,
          label:
              '복구 완료까지 ${_formatRemaining(stage.recoveryDuration, expedition.phaseProgress)}',
        );
      case BattleExpeditionStatus.paused:
        final BattleExpeditionStatus pausedStatus =
            expedition.pausedStatus ?? BattleExpeditionStatus.searching;
        if (pausedStatus == BattleExpeditionStatus.battling) {
          final Duration lifecycleElapsed = _currentLifecycleElapsed(
            expedition.phaseProgress,
          );
          return _PhaseProgressView(
            value: battleActionInterval.inMilliseconds == 0
                ? 0
                : lifecycleElapsed.inMilliseconds /
                      battleActionInterval.inMilliseconds,
            label: '전투 일시정지',
          );
        }
        if (pausedStatus == BattleExpeditionStatus.recovering) {
          return _PhaseProgressView(
            value: stage.recoveryDuration.inMilliseconds == 0
                ? 0
                : expedition.phaseProgress.inMilliseconds /
                      stage.recoveryDuration.inMilliseconds,
            label: '복구 일시정지',
          );
        }
        return _PhaseProgressView(
          value: stage.searchDuration.inMilliseconds == 0
              ? 0
              : expedition.phaseProgress.inMilliseconds /
                    stage.searchDuration.inMilliseconds,
          label: '탐색 일시정지',
        );
    }
  }

  List<String> _timelineLines({
    required BattleExpeditionState expedition,
    required List<BattleActionLog> currentActions,
  }) {
    if (currentActions.isNotEmpty) {
      return currentActions
          .skip(currentActions.length > 6 ? currentActions.length - 6 : 0)
          .map(_formatAction)
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

  String _phaseLabel(BattleExpeditionStatus status) {
    return switch (status) {
      BattleExpeditionStatus.idle => '대기',
      BattleExpeditionStatus.searching => '탐색',
      BattleExpeditionStatus.battling => '전투',
      BattleExpeditionStatus.recovering => '복구',
      BattleExpeditionStatus.paused => '정지',
    };
  }

  Duration _currentLifecycleElapsed(Duration phaseProgress) {
    final int lifecycleMicros = battleActionInterval.inMicroseconds;
    if (lifecycleMicros == 0) {
      return Duration.zero;
    }
    final int remainder = phaseProgress.inMicroseconds % lifecycleMicros;
    return Duration(microseconds: remainder);
  }

  String _formatRemaining(Duration total, Duration progress) {
    final Duration remaining = total - progress;
    if (remaining <= Duration.zero) {
      return '0.0초';
    }
    final double seconds = remaining.inMilliseconds / 1000;
    return '${seconds.toStringAsFixed(1)}초';
  }

  String _formatAction(BattleActionLog action) {
    if (action.type == BattleActionType.regen) {
      return '${action.actorName} 재생 +${action.healing}';
    }
    if (action.type == BattleActionType.lifesteal) {
      return '${action.actorName} 흡혈 +${action.healing}';
    }
    if (!action.hit) {
      return '${action.actorName} -> ${action.targetName ?? '대상'} 빗나감';
    }
    final String criticalLabel = action.critical ? ' / 치명타' : '';
    return '${action.actorName} -> ${action.targetName ?? '대상'} ${action.damage} 피해$criticalLabel';
  }
}

class _PhaseProgressView {
  const _PhaseProgressView({required this.value, required this.label});

  final double value;
  final String label;
}

class _UnitBoardSection extends StatelessWidget {
  const _UnitBoardSection({
    required this.title,
    required this.units,
    required this.emptyLabel,
  });

  final String title;
  final List<BattleRunUnitState> units;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        if (units.isEmpty)
          Text(emptyLabel)
        else
          ...units.map((BattleRunUnitState unit) {
            final double hpRatio = unit.maxHp == 0
                ? 0
                : unit.currentHp / unit.maxHp;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(unit.name)),
                      if (!unit.isAlive)
                        Text(
                          '사망',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('HP ${unit.currentHp} / ${unit.maxHp}'),
                  const SizedBox(height: AppSpacing.xs),
                  LinearProgressIndicator(
                    value: hpRatio.clamp(0, 1),
                    minHeight: 8,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _SmoothProgressBar extends StatelessWidget {
  const _SmoothProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
      builder: (BuildContext context, double animatedValue, Widget? child) {
        return LinearProgressIndicator(value: animatedValue, minHeight: 8);
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
