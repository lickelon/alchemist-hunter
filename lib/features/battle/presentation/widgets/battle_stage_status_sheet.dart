import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/battle/battle_catalog.dart';
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
    final List<BattleEnemyDefinition> enemies = battleCatalog
        .enemyDefinitionsForStage(stageId);
    final BattleExpeditionState expedition = ref.watch(
      battleStageExpeditionStateProvider(stageId),
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
    final BattlePlaybackState? currentBattle = ref.watch(
      battleStageCurrentBattleProvider(stageId),
    );
    final List<BattleActionLog> currentActions = ref.watch(
      battleStageCurrentActionLogsProvider(stageId),
    );
    final List<BattleLogEntry> recentLogs = ref.watch(
      battleStageRecentLogsProvider(stageId),
    );
    final String lastResultLabel = ref.watch(
      battleStageLastResultLabelProvider(stageId),
    );
    final _StageProgressView progressView = _progressView(
      expedition: expedition,
      stage: stage,
      assignedCount: assignedCount,
      partyPower: partyPower,
      statusLabel: statusLabel,
      currentBattle: currentBattle,
    );

    return AppBottomSheet(
      child: AppSheetLayout(
        title:
            '${battleStageDisplayName(stage.id, fallback: stage.name)} 전투 현황',
        header: Text('권장 전투력 ${stage.recommendedPower} / 적 ${enemies.length}종'),
        body: ListView(
          children: <Widget>[
            _StageStatusBlock(
              title: '현재 상태',
              lines: progressView.lines,
              footer: _SmoothProgressBar(
                value: progressView.progressValue.clamp(0, 1),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (currentBattle != null) ...<Widget>[
              _StageStatusBlock(
                title: '실시간 전투',
                lines: currentActions.isEmpty
                    ? const <String>['첫 행동 대기 중']
                    : currentActions
                          .skip(
                            currentActions.length > 6
                                ? currentActions.length - 6
                                : 0,
                          )
                          .map(_formatAction)
                          .toList(growable: false),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            _StageStatusBlock(title: '수령 대기', lines: <String>[pendingLabel]),
            const SizedBox(height: AppSpacing.lg),
            _StageStatusBlock(
              title: '최근 결과',
              lines: recentLogs.isEmpty
                  ? const <String>['최근 전투 기록 없음']
                  : <String>[
                      lastResultLabel,
                      ...recentLogs.take(5).map((BattleLogEntry log) {
                        return '${_formatTime(log.resolvedAt)} / ${log.success ? '성공' : '실패'} / 골드 ${battleSignedValueLabel(log.gold)} / 에센스 ${battleSignedValueLabel(log.essence)}';
                      }),
                    ],
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
                  label: const Text('적 구성 / 드롭'),
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
                  label: const Text('최근 결과'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  _StageProgressView _progressView({
    required BattleExpeditionState expedition,
    required BattleStageDefinition stage,
    required int assignedCount,
    required int partyPower,
    required String statusLabel,
    required BattlePlaybackState? currentBattle,
  }) {
    final List<String> baseLines = <String>[
      statusLabel,
      '편성 $assignedCount명 / 전투력 $partyPower',
    ];
    switch (expedition.status) {
      case BattleExpeditionStatus.idle:
        return _StageProgressView(progressValue: 0, lines: baseLines);
      case BattleExpeditionStatus.searching:
        return _StageProgressView(
          progressValue: stage.searchDuration.inMilliseconds == 0
              ? 0
              : expedition.phaseProgress.inMilliseconds /
                    stage.searchDuration.inMilliseconds,
          lines: <String>[
            ...baseLines,
            '다음 적 탐색까지 ${_formatRemaining(stage.searchDuration, expedition.phaseProgress)}',
          ],
        );
      case BattleExpeditionStatus.battling:
        final Duration lifecycleElapsed = _currentLifecycleElapsed(
          expedition.phaseProgress,
        );
        return _StageProgressView(
          progressValue:
              lifecycleElapsed.inMilliseconds /
              battleActionInterval.inMilliseconds,
          lines: <String>[
            ...baseLines,
            '다음 행동까지 ${_formatRemaining(battleActionInterval, lifecycleElapsed)}',
          ],
        );
      case BattleExpeditionStatus.paused:
        if (currentBattle == null) {
          return _StageProgressView(
            progressValue: stage.searchDuration.inMilliseconds == 0
                ? 0
                : expedition.phaseProgress.inMilliseconds /
                      stage.searchDuration.inMilliseconds,
            lines: <String>[
              ...baseLines,
              '다음 적 탐색까지 ${_formatRemaining(stage.searchDuration, expedition.phaseProgress)}',
            ],
          );
        }
        final Duration lifecycleElapsed = _currentLifecycleElapsed(
          expedition.phaseProgress,
        );
        return _StageProgressView(
          progressValue:
              lifecycleElapsed.inMilliseconds /
              battleActionInterval.inMilliseconds,
          lines: baseLines,
        );
    }
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
    final String criticalLabel = action.critical ? ' 치명타' : '';
    return '${action.actorName} -> ${action.targetName ?? '대상'} ${action.damage} 피해$criticalLabel';
  }
}

class _StageProgressView {
  const _StageProgressView({required this.progressValue, required this.lines});

  final double progressValue;
  final List<String> lines;
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

class _StageStatusBlock extends StatelessWidget {
  const _StageStatusBlock({
    required this.title,
    required this.lines,
    this.footer,
  });

  final String title;
  final List<String> lines;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        ...lines.map((String line) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(line),
          );
        }),
        if (footer != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          footer!,
        ],
      ],
    );
  }
}
