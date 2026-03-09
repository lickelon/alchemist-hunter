import 'package:alchemist_hunter/features/town/application/game_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DungeonScreen extends ConsumerWidget {
  const DungeonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> stages = ref.watch(stageListProvider);
    final game = ref.watch(gameControllerProvider);

    return ListView.builder(
      itemCount: stages.length,
      itemBuilder: (BuildContext context, int index) {
        final String stage = stages[index];
        final bool unlocked = index == 0 || game.progress.unlockFlags.contains(stage);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.shield),
            title: Text(stage),
            subtitle: Text(
              unlocked
                  ? 'Auto battle / Gold: ${game.gold} / Essence: ${game.essence}'
                  : 'Locked: requires stage/material unlock',
            ),
            trailing: FilledButton(
              onPressed: unlocked
                  ? () {
                      ref.read(gameControllerProvider.notifier).runAutoBattle(stage);
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
