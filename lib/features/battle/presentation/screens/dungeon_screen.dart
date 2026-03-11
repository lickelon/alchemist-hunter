import 'package:alchemist_hunter/features/battle/application/battle_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
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

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.shield),
            title: Text(stageLabel),
            subtitle: Text(
              unlocked
                  ? 'Auto battle / Gold: $gold / Essence: $essence'
                  : _lockedReason(stage),
            ),
            trailing: FilledButton(
              onPressed: unlocked
                  ? () {
                      ref.read(battleControllerProvider).runAutoBattle(stage);
                    }
                  : null,
              child: Text(unlocked ? 'Run' : 'Locked'),
            ),
          ),
        );
      },
    );
  }

  String _lockedReason(String stageId) {
    return switch (stageId) {
      'stage_2' => '잠금 조건: 특수 재료 m_30 1개 이상 획득',
      'stage_3' => '잠금 조건: Stage 2 개방 이후 추가 해금 예정',
      'stage_4' => '잠금 조건: Stage 3 개방 이후 추가 해금 예정',
      'stage_5' => '잠금 조건: Stage 4 개방 이후 추가 해금 예정',
      _ => '잠금 조건: 이전 스테이지 진행 필요',
    };
  }
}
