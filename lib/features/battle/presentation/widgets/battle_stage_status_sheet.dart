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

const double _unitBoardCardHeight = 360;
const double _unitBoardMinHeight = 220;
const double _compactLayoutReserveHeight = 250;
const double _progressCardHeight = 44;
const double _timelineLineHeight = 24;

class BattleStageStatusSheet extends ConsumerStatefulWidget {
  const BattleStageStatusSheet({super.key, required this.stageId});

  final String stageId;

  @override
  ConsumerState<BattleStageStatusSheet> createState() =>
      _BattleStageStatusSheetState();
}

class _BattleStageStatusSheetState
    extends ConsumerState<BattleStageStatusSheet> {
  final List<String> _timelineLines = <String>[];
  final Set<String> _timelineKeys = <String>{};
  final ScrollController _timelineScrollController = ScrollController();

  @override
  void dispose() {
    _timelineScrollController.dispose();
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
    final List<BattleActionLog> currentActions = ref.watch(
      battleStageCurrentActionLogsProvider(widget.stageId),
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
    _appendTimelineActions(currentEncounter, currentActions);
    final List<String> timelineLines = _timelineLines.isEmpty
        ? battleStageTimelineLines(
            expedition: expedition,
            currentActions: const <BattleActionLog>[],
          )
        : _timelineLines;

    return AppBottomSheet(
      child: AppSheetLayout(
        title:
            '${battleStageDisplayName(stage.id, fallback: stage.name)} 전투 현황',
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double unitBoardHeight =
                (constraints.maxHeight - _compactLayoutReserveHeight).clamp(
                  _unitBoardMinHeight,
                  _unitBoardCardHeight,
                );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                BattleStatusCard(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: SizedBox(
                    height: unitBoardHeight,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          BattleUnitBoardSection(
                            units:
                                runState?.allies ??
                                const <BattleRunUnitState>[],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          BattleUnitBoardSection(
                            units:
                                currentEncounter?.enemies ??
                                const <BattleRunUnitState>[],
                            enemy: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BattleStatusCard(
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
                  stageId: widget.stageId,
                  hasRecentLogs: recentLogs.isNotEmpty,
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: BattleStatusCard(
                    child: _BattleStageTimelineBody(
                      controller: _timelineScrollController,
                      lines: timelineLines,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _appendTimelineActions(
    BattleEncounterRuntimeState? encounter,
    List<BattleActionLog> actions,
  ) {
    if (encounter == null || actions.isEmpty) {
      return;
    }

    final bool shouldFollow =
        !_timelineScrollController.hasClients ||
        _timelineScrollController.position.pixels >=
            _timelineScrollController.position.maxScrollExtent - 12;
    bool appended = false;
    for (final BattleActionLog action in actions) {
      final String key = _timelineActionKey(encounter, action);
      if (_timelineKeys.add(key)) {
        _timelineLines.add(battleActionTimelineLabel(action));
        appended = true;
      }
    }
    if (appended && shouldFollow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_timelineScrollController.hasClients) {
          return;
        }
        _timelineScrollController.jumpTo(
          _timelineScrollController.position.maxScrollExtent,
        );
      });
    }
  }

  String _timelineActionKey(
    BattleEncounterRuntimeState encounter,
    BattleActionLog action,
  ) {
    return <Object?>[
      encounter.encounterId,
      encounter.encounterIndex,
      action.lifecycle,
      action.turn,
      action.type,
      action.actorId,
      action.targetId,
      action.skillId,
      action.hit,
      action.critical,
      action.damage,
      action.healing,
      action.mpSpent,
      action.actorHpAfter,
      action.actorMpAfter,
      action.targetHpAfter,
      action.targetShieldAfter,
      action.message,
    ].join('|');
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
  const _BattleStageTimelineBody({
    required this.controller,
    required this.lines,
  });

  final ScrollController controller;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemExtent: _timelineLineHeight,
      itemCount: lines.length,
      itemBuilder: (BuildContext context, int index) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            lines[index],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
