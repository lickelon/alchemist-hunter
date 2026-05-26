import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_assignment_sheet.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_claim_dialog.dart';
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
        final String stageLabel = ref.watch(
          battleStageDisplayNameProvider(stage),
        );
        final int assignedCount = ref
            .watch(battleStageAssignmentProvider(stage))
            .length;
        final BattleExpeditionState expedition = ref.watch(
          battleStageExpeditionStateProvider(stage),
        );
        final String statusLabel = ref.watch(
          battleStageStatusLabelProvider(stage),
        );
        final bool canStart = assignedCount > 0 && !expedition.isActive;
        final bool canStop = expedition.isActive;
        final bool canClaim = !expedition.pendingClaim.isEmpty;
        final String cardSummary = '편성 $assignedCount명\n상태: $statusLabel';

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
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(cardSummary),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: <Widget>[
                      FilledButton.tonal(
                        onPressed: () => _showAssignmentSheet(context, stage),
                        child: const Text('편성'),
                      ),
                      FilledButton(
                        onPressed: canStop
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
                        child: Text(canStop ? '정지' : '원정 시작'),
                      ),
                      FilledButton.tonal(
                        onPressed: canClaim
                            ? () => _showClaimDialog(context, stage)
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

  void _showClaimDialog(BuildContext context, String stageId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return BattleClaimDialog(stageId: stageId);
      },
    );
  }
}
