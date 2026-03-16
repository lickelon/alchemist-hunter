import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_assignment_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DungeonScreen extends ConsumerWidget {
  const DungeonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> stages = ref.watch(unlockedStageListProvider);
    final ProgressState progress = ref.watch(battleProgressProvider);
    final int gold = ref.watch(battleGoldProvider);
    final int essence = ref.watch(battleEssenceProvider);

    return ListView.builder(
      itemCount: stages.length,
      itemBuilder: (BuildContext context, int index) {
        final String stage = stages[index];
        final bool unlocked =
            index == 0 || progress.unlockFlags.contains(stage);
        final String stageLabel = stage.replaceFirst('stage_', 'Stage ');
        final int assignedCount = ref.watch(
          battleStageAssignmentProvider(stage),
        ).length;
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
        final bool canStart =
            unlocked &&
            assignedCount > 0 &&
            expedition.status != BattleExpeditionStatus.running;
        final bool canStop = expedition.status == BattleExpeditionStatus.running;
        final bool canClaim = unlocked && !expedition.pendingClaim.isEmpty;
        final String summary =
            '편성 $assignedCount명 / 전투력 $partyPower / $statusLabel / Gold: $gold / Essence: $essence';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: InkWell(
            onTap: () => _showAssignmentSheet(context, stage),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.shield),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stageLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    unlocked
                        ? '$summary\n$pendingLabel${expedition.lastSummary.isEmpty ? "" : "\n최근 ${expedition.lastSummary}"}'
                        : '$summary\n${_lockedReason(stage)}',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton(
                          onPressed: !unlocked
                              ? null
                              : canStop
                              ? () {
                                  ref.read(battleControllerProvider).stopExpedition(stage);
                                }
                              : canStart
                              ? () {
                                  ref.read(battleControllerProvider).startExpedition(stage);
                                }
                              : null,
                          child: Text(
                            !unlocked ? '잠김' : canStop ? '정지' : '원정 시작',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: canClaim
                              ? () {
                                  ref.read(battleControllerProvider).claimStageRewards(stage);
                                }
                              : null,
                          child: const Text('수령'),
                        ),
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

  String _lockedReason(String stageId) {
    return switch (stageId) {
      'stage_2' => '잠금 조건: 특수 재료 Moontear Crystal 1개 이상 획득',
      'stage_3' => '잠금 조건: Stage 2 개방 이후 추가 해금 예정',
      'stage_4' => '잠금 조건: Stage 3 개방 이후 추가 해금 예정',
      'stage_5' => '잠금 조건: Stage 4 개방 이후 추가 해금 예정',
      _ => '잠금 조건: 이전 스테이지 진행 필요',
    };
  }
}
