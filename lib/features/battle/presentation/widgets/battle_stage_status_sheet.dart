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

const double _unitBoardCardHeight = 220;
const double _progressCardHeight = 44;
const double _timelineCardHeight = 150;
const int _timelineSlotCount = 6;

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
    final String statusLabel = ref.watch(
      battleStageStatusLabelProvider(stageId),
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
        header: Text('권장 전투력 ${stage.recommendedPower}'),
        body: ListView(
          children: <Widget>[
            _BattleStageStatusHeader(
              expedition: expedition,
              currentEncounter: currentEncounter,
            ),
            const SizedBox(height: AppSpacing.lg),
            BattleStatusCard(
              title: '전투 상태판',
              child: SizedBox(
                height: _unitBoardCardHeight,
                child: SingleChildScrollView(
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
                        emptyLabel: currentEncounter == null ? '적 대기' : '적 없음',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BattleStatusCard(
              title: '진행',
              child: SizedBox(
                height: _progressCardHeight,
                child: _BattleStageProgressBody(
                  statusLabel: statusLabel,
                  progress: progress,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BattleStageStatusActions(
              stageId: stageId,
              hasRecentLogs: recentLogs.isNotEmpty,
            ),
            const SizedBox(height: AppSpacing.lg),
            BattleStatusCard(
              title: '실시간 타임라인',
              child: SizedBox(
                height: _timelineCardHeight,
                child: _BattleStageTimelineBody(
                  lines: battleStageTimelineLines(
                    expedition: expedition,
                    currentActions: currentActions,
                  ),
                ),
              ),
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
        Chip(label: Text(currentEncounter == null ? '적 대기' : '적 조우')),
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
        Text(statusLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
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
    final List<String> visibleLines = lines.length > _timelineSlotCount
        ? lines.skip(lines.length - _timelineSlotCount).toList(growable: false)
        : lines;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(_timelineSlotCount, (int index) {
        final String? line = index < visibleLines.length
            ? visibleLines[index]
            : null;
        return SizedBox(
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: line == null
                ? const SizedBox.shrink()
                : Text(line, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        );
      }),
    );
  }
}
