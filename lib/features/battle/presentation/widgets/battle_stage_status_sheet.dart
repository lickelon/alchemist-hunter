import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_runtime_selectors.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_status_label_selectors.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_status_view_model.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_status_actions.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_status_layout.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_status_progress_body.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_status_timeline_body.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_status_timeline_buffer.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_status_unit_board.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_status_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleStageStatusSheet extends ConsumerStatefulWidget {
  const BattleStageStatusSheet({super.key, required this.stageId});

  final String stageId;

  @override
  ConsumerState<BattleStageStatusSheet> createState() =>
      _BattleStageStatusSheetState();
}

class _BattleStageStatusSheetState
    extends ConsumerState<BattleStageStatusSheet> {
  final BattleStageStatusTimelineBuffer _timelineBuffer =
      BattleStageStatusTimelineBuffer();

  @override
  void dispose() {
    _timelineBuffer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BattleCatalogRepository battleCatalog = ref.watch(
      battleCatalogRepositoryProvider,
    );
    final BattleStageDefinition stage = battleCatalog.stageDefinition(
      widget.stageId,
    );
    final BattleExpeditionState expedition = ref.watch(
      battleStageExpeditionStateProvider(widget.stageId),
    );
    final BattleRunState? runState = expedition.runState;
    final BattleEncounterRuntimeState? currentEncounter =
        runState?.currentEncounter;
    ref.listen<List<BattleActionLog>>(
      battleStageCurrentActionLogsProvider(widget.stageId),
      (_, List<BattleActionLog> next) {
        _timelineBuffer.appendActions(
          encounter: ref
              .read(battleStageExpeditionStateProvider(widget.stageId))
              .runState
              ?.currentEncounter,
          actions: next,
          onChanged: () {
            setState(() {});
          },
        );
      },
    );
    final List<BattleLogEntry> recentLogs = ref.watch(
      battleStageRecentLogsProvider(widget.stageId),
    );
    final String statusLabel = ref.watch(
      battleStageStatusLabelProvider(widget.stageId),
    );
    final BattleStagePhaseProgress progress = buildBattleStagePhaseProgress(
      expedition: expedition,
      stage: stage,
      battleActionInterval: battleActionInterval,
    );
    final List<String> timelineLines = _timelineBuffer.lines.isEmpty
        ? battleStageTimelineLines(
            expedition: expedition,
            currentActions: const <BattleActionLog>[],
          )
        : _timelineBuffer.lines;

    return AppSheetLayout(
      title: '${battleStageDisplayName(stage.id, fallback: stage.name)} 전투 현황',
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double unitBoardHeight =
              (constraints.maxHeight -
                      BattleStageStatusLayout.compactLayoutReserveHeight)
                  .clamp(
                    BattleStageStatusLayout.unitBoardMinHeight,
                    BattleStageStatusLayout.unitBoardCardHeight,
                  );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BattleStatusCard(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: SizedBox(
                  height: unitBoardHeight,
                  child: BattleStageStatusUnitBoard(
                    allies: runState?.allies ?? const <BattleRunUnitState>[],
                    enemies:
                        currentEncounter?.enemies ??
                        const <BattleRunUnitState>[],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              BattleStatusCard(
                child: SizedBox(
                  height: BattleStageStatusLayout.progressCardHeight,
                  child: BattleStageStatusProgressBody(
                    statusLabel: statusLabel,
                    progress: progress,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              BattleStageStatusActions(
                stageId: widget.stageId,
                hasRecentLogs: recentLogs.isNotEmpty,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: BattleStatusCard(
                  child: BattleStageStatusTimelineBody(
                    controller: _timelineBuffer.scrollController,
                    lines: timelineLines,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
