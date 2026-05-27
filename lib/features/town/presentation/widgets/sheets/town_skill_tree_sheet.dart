import 'package:alchemist_hunter/common/themes/app_tree_layout.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
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

    return AppSheetLayout(
      title: '마을 스킬트리',
      header: Text('명성 $townInsight / 골드 $gold'),
      body: ListView(
        children: nodes.map((TownSkillNodeView node) {
          final int clampedDepth = node.depth.clamp(0, AppTreeLayout.maxDepth);
          return Padding(
            padding: EdgeInsets.only(
              left: clampedDepth * AppTreeLayout.depthIndent,
              bottom: AppSpacing.md,
            ),
            child: Card(
              child: ListTile(
                dense: true,
                title: Row(
                  children: <Widget>[
                    Text(node.depth == 0 ? '●' : '↳'),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text('${node.name} (${node.levelLabel})')),
                  ],
                ),
                subtitle: DetailLines(
                  description: node.description,
                  lines: <String>[
                    '현재 효과 ${node.currentEffectLabel}',
                    '다음 효과 ${node.nextEffectLabel}',
                    node.prerequisiteLabel,
                    '비용 ${node.costLabel}',
                    node.statusLabel,
                  ],
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
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
