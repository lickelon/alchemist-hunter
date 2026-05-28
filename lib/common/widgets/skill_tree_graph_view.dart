import 'package:alchemist_hunter/common/themes/app_tree_layout.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_connector_painter.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_layout.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_node.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_node_card.dart';
import 'package:flutter/material.dart';

export 'skill_tree_graph_node.dart';

class SkillTreeGraphView extends StatelessWidget {
  const SkillTreeGraphView({
    super.key,
    required this.nodes,
    required this.onNodeTap,
  });

  final List<SkillTreeGraphNode> nodes;
  final ValueChanged<SkillTreeGraphNode> onNodeTap;

  @override
  Widget build(BuildContext context) {
    final SkillTreeGraphLayout layout = SkillTreeGraphLayout.build(nodes);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InteractiveViewer(
      constrained: false,
      minScale: 0.7,
      maxScale: 1.4,
      boundaryMargin: const EdgeInsets.all(AppTreeLayout.graphPadding),
      child: SizedBox(
        width: layout.size.width,
        height: layout.size.height,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(
                painter: SkillTreeConnectorPainter(
                  nodes: nodes,
                  centers: layout.centers,
                  activeColor: colorScheme.primary,
                  inactiveColor: colorScheme.outlineVariant,
                ),
              ),
            ),
            ...nodes.map((SkillTreeGraphNode node) {
              final Offset position = layout.positions[node.id] ?? Offset.zero;
              return Positioned(
                left: position.dx,
                top: position.dy,
                width: AppTreeLayout.graphNodeWidth,
                height: AppTreeLayout.graphNodeHeight,
                child: SkillTreeNodeCard(
                  node: node,
                  onTap: () {
                    onNodeTap(node);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
