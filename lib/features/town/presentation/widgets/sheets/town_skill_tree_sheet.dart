import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';

class TownSkillTreeSheet extends ConsumerWidget {
  const TownSkillTreeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int townInsight = ref.watch(townInsightProvider);
    final int gold = ref.watch(townGoldProvider);
    final List<TownSkillNodeView> nodes = ref.watch(townSkillNodeViewsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '마을 스킬트리',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('TownInsight $townInsight / Gold $gold'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: nodes.map((TownSkillNodeView node) {
                    return ListTile(
                      dense: true,
                      title: Text('${node.name} (${node.levelLabel})'),
                      subtitle: Text(
                        '${node.description}\n${node.effectLabel}\n비용 ${node.costLabel}\n${node.statusLabel}',
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: node.upgradeable
                            ? () {
                                ref
                                    .read(townSkillTreeControllerProvider)
                                    .upgradeNode(node.id);
                              }
                            : null,
                        child: const Text('강화'),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
