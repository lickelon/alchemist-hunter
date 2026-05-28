import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_view.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_node_detail_dialog.dart';
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
      body: SkillTreeGraphView(
        nodes: nodes
            .map((TownSkillNodeView node) => node.toGraphNode())
            .toList(growable: false),
        onNodeTap: (SkillTreeGraphNode node) {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return SkillTreeNodeDetailDialog(
                node: node,
                onUpgrade: () {
                  ref
                      .read(townSkillTreeControllerProvider)
                      .upgradeNode(node.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
