import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_assignment_sheet.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_claim_sheet.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_status_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DungeonScreen extends ConsumerWidget {
  const DungeonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> stages = ref.watch(unlockedStageListProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: stages.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final String stage = stages[index];
        final bool unlocked = ref.watch(battleStageUnlockedProvider(stage));
        final String lockReason = ref.watch(
          battleStageLockReasonProvider(stage),
        );
        final String stageLabel = battleStageDisplayName(stage);
        final int assignedCount = ref
            .watch(battleStageAssignmentProvider(stage))
            .length;
        final int partyPower = ref.watch(battleStagePartyPowerProvider(stage));
        final BattleExpeditionState expedition = ref.watch(
          battleStageExpeditionStateProvider(stage),
        );
        final String statusLabel = ref.watch(
          battleStageStatusLabelProvider(stage),
        );
        final String pendingLabel = ref.watch(
          battleStagePendingClaimLabelProvider(stage),
        );
        final List<BattleLogEntry> recentLogs = ref.watch(
          battleStageRecentLogsProvider(stage),
        );
        final bool canStart =
            unlocked && assignedCount > 0 && !expedition.isActive;
        final bool canStop = expedition.isActive;
        final bool canClaim = unlocked && !expedition.pendingClaim.isEmpty;
        final String summary =
            '편성 $assignedCount명 / 전투력 $partyPower / $statusLabel';
        final String recentLine = recentLogs.isEmpty
            ? '최근 전투 기록 없음'
            : '최근 전투 ${recentLogs.first.success ? '성공' : '실패'} / ${recentLogs.first.turns}턴';

        return Card(
          child: InkWell(
            onTap: () => _showStatusSheet(context, stage),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.shield),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          stageLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    unlocked
                        ? '$summary\n$pendingLabel\n$recentLine'
                        : '$summary\n$lockReason',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: <Widget>[
                      FilledButton.tonal(
                        onPressed: unlocked
                            ? () => _showAssignmentSheet(context, stage)
                            : null,
                        child: const Text('편성'),
                      ),
                      FilledButton(
                        onPressed: !unlocked
                            ? null
                            : canStop
                            ? () {
                                ref
                                    .read(battleControllerProvider)
                                    .stopExpedition(stage);
                              }
                            : canStart
                            ? () {
                                ref
                                    .read(battleControllerProvider)
                                    .startExpedition(stage);
                              }
                            : null,
                        child: Text(
                          !unlocked
                              ? '잠김'
                              : canStop
                              ? '정지'
                              : expedition.status ==
                                    BattleExpeditionStatus.paused
                              ? '재개'
                              : '원정 시작',
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: canClaim
                            ? () => _showClaimSheet(context, stage)
                            : null,
                        child: const Text('수령'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAssignmentSheet(BuildContext context, String stageId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BattleAssignmentSheet(stageId: stageId);
      },
    );
  }

  void _showStatusSheet(BuildContext context, String stageId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BattleStageStatusSheet(stageId: stageId);
      },
    );
  }

  void _showClaimSheet(BuildContext context, String stageId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BattleClaimSheet(stageId: stageId);
      },
    );
  }
}
