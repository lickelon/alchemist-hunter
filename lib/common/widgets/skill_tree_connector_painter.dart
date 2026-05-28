import 'package:alchemist_hunter/common/themes/app_tree_layout.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_node.dart';
import 'package:flutter/material.dart';

class SkillTreeConnectorPainter extends CustomPainter {
  const SkillTreeConnectorPainter({
    required this.nodes,
    required this.centers,
    required this.activeColor,
    required this.inactiveColor,
  });

  final List<SkillTreeGraphNode> nodes;
  final Map<String, Offset> centers;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Map<String, SkillTreeGraphNode> nodeMap =
        <String, SkillTreeGraphNode>{
          for (final SkillTreeGraphNode node in nodes) node.id: node,
        };
    for (final SkillTreeGraphNode node in nodes) {
      final Offset? childCenter = centers[node.id];
      if (childCenter == null) {
        continue;
      }
      for (final String parentId in node.parentIds) {
        final Offset? parentCenter = centers[parentId];
        final SkillTreeGraphNode? parent = nodeMap[parentId];
        if (parentCenter == null || parent == null) {
          continue;
        }
        final bool active =
            parent.state != SkillTreeNodeState.locked &&
            node.state != SkillTreeNodeState.locked;
        final Paint paint = Paint()
          ..color = active ? activeColor : inactiveColor
          ..strokeWidth = active ? 2.5 : 1.5
          ..style = PaintingStyle.stroke;
        final double middleX = (parentCenter.dx + childCenter.dx) / 2;
        final Path path = Path()
          ..moveTo(
            parentCenter.dx + AppTreeLayout.graphNodeWidth / 2,
            parentCenter.dy,
          )
          ..lineTo(middleX, parentCenter.dy)
          ..lineTo(middleX, childCenter.dy)
          ..lineTo(
            childCenter.dx - AppTreeLayout.graphNodeWidth / 2,
            childCenter.dy,
          );
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SkillTreeConnectorPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.centers != centers ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
