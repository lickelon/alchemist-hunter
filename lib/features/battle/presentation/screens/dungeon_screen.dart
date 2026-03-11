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
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.shield),
            title: Text(stage),
            subtitle: Text(
              unlocked
                  ? 'Auto battle / Gold: $gold / Essence: $essence'
                  : 'Locked: requires stage/material unlock',
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
}
