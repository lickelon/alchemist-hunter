import 'package:alchemist_hunter/features/game/providers/game_providers.dart';
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
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.shield),
            title: Text(stage),
            subtitle: Text('Auto battle / Gold: ${game.gold}'),
            trailing: FilledButton(
              onPressed: () {
                ref.read(gameControllerProvider.notifier).runAutoBattle(stage);
              },
              child: const Text('Run'),
            ),
          ),
        );
      },
    );
  }
}
