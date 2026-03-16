import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

class WorkshopSkillTreeSheet extends ConsumerWidget {
  const WorkshopSkillTreeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int arcaneDust = ref.watch(workshopArcaneDustProvider);
    final List<WorkshopSkillNodeView> nodes = ref.watch(
      workshopSkillNodeViewsProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '작업실 스킬트리',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('ArcaneDust $arcaneDust'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: nodes.map((WorkshopSkillNodeView node) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: node.depth * 20,
                        bottom: 8,
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          dense: true,
                          title: Text(
                            '${node.depth == 0 ? "●" : "↳"} ${node.name} (${node.levelLabel})',
                          ),
                          subtitle: Text(
                            '${node.description}\n현재 효과 ${node.currentEffectLabel}\n다음 효과 ${node.nextEffectLabel}\n${node.prerequisiteLabel}\n비용 ${node.costLabel}\n${node.statusLabel}',
                          ),
                          trailing: FilledButton.tonal(
                            onPressed: node.upgradeable
                                ? () {
                                    ref
                                        .read(workshopSkillTreeControllerProvider)
                                        .upgradeNode(node.id);
                                  }
                                : null,
                            child: const Text('강화'),
                          ),
                        ),
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
