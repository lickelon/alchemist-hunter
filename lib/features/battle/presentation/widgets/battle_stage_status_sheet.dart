import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_status_view_model.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_smooth_progress_bar.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_status_actions.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_status_card.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_unit_board_section.dart';
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
    final BattleStagePhaseProgress progress = buildBattleStagePhaseProgress(
      expedition: expedition,
      stage: stage,
      battleActionInterval: battleActionInterval,
    );

    return AppBottomSheet(
      child: AppSheetLayout(
        title:
            '${battleStageDisplayName(stage.id, fallback: stage.name)} 전투 현황',
        header: Text(
          '권장 전투력 ${stage.recommendedPower} / 가능한 조합 ${stage.encounters.length}종',
        ),
        body: ListView(
          children: <Widget>[
            _BattleStageStatusHeader(
              expedition: expedition,
              currentEncounter: currentEncounter,
            ),
            const SizedBox(height: AppSpacing.lg),
            BattleStatusCard(
              title: '전투 상태판',
              child: Column(
                children: <Widget>[
                  BattleUnitBoardSection(
                    title: '아군',
                    units: runState?.allies ?? const <BattleRunUnitState>[],
                    emptyLabel: assignedCount == 0 ? '편성 없음' : '전투 시작 전',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BattleUnitBoardSection(
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
            BattleStatusCard(
              title: '진행',
              child: _BattleStageProgressBody(
                statusLabel: statusLabel,
                progress: progress,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BattleStatusCard(
              title: '실시간 타임라인',
              child: _BattleStageTimelineBody(
                lines: battleStageTimelineLines(
                  expedition: expedition,
                  currentActions: currentActions,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BattleStatusCard(
              title: '런 요약',
              child: _BattleStageSummaryBody(
                stage: stage,
                expedition: expedition,
                runState: runState,
                currentEncounter: currentEncounter,
                assignedCount: assignedCount,
                partyPower: partyPower,
                pendingLabel: pendingLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BattleStageStatusActions(
              stageId: stageId,
              hasRecentLogs: recentLogs.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }
}

class _BattleStageStatusHeader extends StatelessWidget {
  const _BattleStageStatusHeader({
    required this.expedition,
    required this.currentEncounter,
  });

  final BattleExpeditionState expedition;
  final BattleEncounterRuntimeState? currentEncounter;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        Chip(label: Text(battleStagePhaseLabel(expedition.status))),
        Chip(
          label: Text(
            currentEncounter == null
                ? '교전 대기'
                : '${currentEncounter!.encounterIndex}회 ${currentEncounter!.encounterName}',
          ),
        ),
      ],
    );
  }
}

class _BattleStageProgressBody extends StatelessWidget {
  const _BattleStageProgressBody({
    required this.statusLabel,
    required this.progress,
  });

  final String statusLabel;
  final BattleStagePhaseProgress progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(statusLabel),
        const SizedBox(height: AppSpacing.xs),
        Text(progress.label),
        const SizedBox(height: AppSpacing.sm),
        BattleSmoothProgressBar(value: progress.value.clamp(0, 1)),
      ],
    );
  }
}

class _BattleStageTimelineBody extends StatelessWidget {
  const _BattleStageTimelineBody({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map((String line) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(line),
            );
          })
          .toList(growable: false),
    );
  }
}

class _BattleStageSummaryBody extends StatelessWidget {
  const _BattleStageSummaryBody({
    required this.stage,
    required this.expedition,
    required this.runState,
    required this.currentEncounter,
    required this.assignedCount,
    required this.partyPower,
    required this.pendingLabel,
  });

  final BattleStageDefinition stage;
  final BattleExpeditionState expedition;
  final BattleRunState? runState;
  final BattleEncounterRuntimeState? currentEncounter;
  final int assignedCount;
  final int partyPower;
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    final List<String> lines = <String>[
      '편성 $assignedCount명 / 전투력 $partyPower',
      pendingLabel,
      '누적 승리 ${runState?.victoryCount ?? 0} / 전멸 ${runState?.wipeCount ?? 0}',
      '누적 교전 ${runState?.encounterCount ?? 0}회',
      if (currentEncounter != null)
        '현재 조합 ${currentEncounter!.encounterIndex}회 / ${currentEncounter!.encounterName}',
      if (currentEncounter?.usedLoadoutFallback ?? false) '포션 부족으로 로드아웃 미적용',
      if (expedition.status == BattleExpeditionStatus.recovering)
        '복구 완료까지 ${formatBattleStageRemaining(stage.recoveryDuration, expedition.phaseProgress)}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map((String line) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(line),
            );
          })
          .toList(growable: false),
    );
  }
}
