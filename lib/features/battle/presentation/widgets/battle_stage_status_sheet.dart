import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/battle/battle_catalog.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';
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
    final List<BattleLogEntry> recentLogs = ref.watch(
      battleStageRecentLogsProvider(stageId),
    );
    final String lastResultLabel = ref.watch(
      battleStageLastResultLabelProvider(stageId),
    );
    final double progressValue = stage.cycleDuration.inMilliseconds == 0
        ? 0
        : expedition.cycleProgress.inMilliseconds /
              stage.cycleDuration.inMilliseconds;
    final Duration remaining = stage.cycleDuration - expedition.cycleProgress;

    return AppBottomSheet(
      child: AppSheetLayout(
        title: '${stage.name} 전투 현황',
        header: Text('권장 전투력 ${stage.recommendedPower} / 적 ${enemies.length}종'),
        body: ListView(
          children: <Widget>[
            _StageStatusBlock(
              title: '현재 상태',
              lines: <String>[
                statusLabel,
                '편성 $assignedCount명 / 전투력 $partyPower',
                '사이클 진행 ${expedition.cycleProgress.inSeconds}s / ${stage.cycleDuration.inSeconds}s',
                '다음 판정까지 ${remaining.inSeconds.clamp(0, stage.cycleDuration.inSeconds)}s',
              ],
              footer: LinearProgressIndicator(
                value: progressValue.clamp(0, 1),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _StageStatusBlock(title: '수령 대기', lines: <String>[pendingLabel]),
            const SizedBox(height: AppSpacing.lg),
            _StageStatusBlock(
              title: '최근 결과',
              lines: recentLogs.isEmpty
                  ? const <String>['최근 전투 기록 없음']
                  : <String>[
                      lastResultLabel,
                      ...recentLogs.take(5).map((BattleLogEntry log) {
                        return '${_formatTime(log.resolvedAt)} / ${log.success ? '성공' : '실패'} / Gold ${log.gold >= 0 ? '+' : ''}${log.gold} / Essence +${log.essence}';
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
