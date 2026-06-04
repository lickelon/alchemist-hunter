import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_view.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_node_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_resource_selectors.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/presentation/viewmodels/workshop_skill_tree_controller.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/presentation/viewmodels/workshop_skill_tree_selectors.dart';

class WorkshopSkillTreeSheet extends ConsumerWidget {
  const WorkshopSkillTreeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int arcaneDust = ref.watch(workshopArcaneDustProvider);
    final List<WorkshopSkillNodeView> nodes = ref.watch(
      workshopSkillNodeViewsProvider,
    );

    return AppSheetLayout(
      title: '작업실 스킬트리',
      header: AppBadge(label: '신비 $arcaneDust'),
      body: SkillTreeGraphView(
        nodes: nodes
            .map((WorkshopSkillNodeView node) => node.toGraphNode())
            .toList(growable: false),
        onNodeTap: (SkillTreeGraphNode node) {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return SkillTreeNodeDetailDialog(
                node: node,
                onUpgrade: () {
                  ref
                      .read(workshopSkillTreeControllerProvider)
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
