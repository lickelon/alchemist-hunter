import 'package:alchemist_hunter/common/themes/app_tree_layout.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_node.dart';
import 'package:flutter/material.dart';

class SkillTreeGraphLayout {
  const SkillTreeGraphLayout({
    required this.positions,
    required this.centers,
    required this.size,
  });

  final Map<String, Offset> positions;
  final Map<String, Offset> centers;
  final Size size;

  static SkillTreeGraphLayout build(List<SkillTreeGraphNode> nodes) {
    final Map<String, int> depths = _depthsFor(nodes);
    final Map<int, List<SkillTreeGraphNode>> columns =
        <int, List<SkillTreeGraphNode>>{};
    for (final SkillTreeGraphNode node in nodes) {
      columns.putIfAbsent(depths[node.id] ?? 0, () => <SkillTreeGraphNode>[]);
      columns[depths[node.id] ?? 0]!.add(node);
    }

    final Map<String, Offset> positions = <String, Offset>{};
    int maxDepth = 0;
    int maxRows = 1;
    for (final MapEntry<int, List<SkillTreeGraphNode>> entry
        in columns.entries) {
      maxDepth = entry.key > maxDepth ? entry.key : maxDepth;
      maxRows = entry.value.length > maxRows ? entry.value.length : maxRows;
      for (int index = 0; index < entry.value.length; index += 1) {
        positions[entry.value[index].id] = Offset(
          AppTreeLayout.graphPadding +
              entry.key *
                  (AppTreeLayout.graphNodeWidth + AppTreeLayout.graphColumnGap),
          AppTreeLayout.graphPadding +
              index *
                  (AppTreeLayout.graphNodeHeight + AppTreeLayout.graphRowGap),
        );
      }
    }

    final Map<String, Offset> centers = <String, Offset>{
      for (final MapEntry<String, Offset> entry in positions.entries)
        entry.key:
            entry.value +
            const Offset(
              AppTreeLayout.graphNodeWidth / 2,
              AppTreeLayout.graphNodeHeight / 2,
            ),
    };

    return SkillTreeGraphLayout(
      positions: positions,
      centers: centers,
      size: Size(
        AppTreeLayout.graphPadding * 2 +
            (maxDepth + 1) * AppTreeLayout.graphNodeWidth +
            maxDepth * AppTreeLayout.graphColumnGap,
        AppTreeLayout.graphPadding * 2 +
            maxRows * AppTreeLayout.graphNodeHeight +
            (maxRows - 1) * AppTreeLayout.graphRowGap,
      ),
    );
  }

  static Map<String, int> _depthsFor(List<SkillTreeGraphNode> nodes) {
    final Map<String, SkillTreeGraphNode> nodeMap =
        <String, SkillTreeGraphNode>{
          for (final SkillTreeGraphNode node in nodes) node.id: node,
        };
    final Map<String, int> cache = <String, int>{};

    int depthFor(SkillTreeGraphNode node) {
      final int? cached = cache[node.id];
      if (cached != null) {
        return cached;
      }
      if (node.parentIds.isEmpty) {
        cache[node.id] = 0;
        return 0;
      }
      int maxParentDepth = 0;
      for (final String parentId in node.parentIds) {
        final SkillTreeGraphNode? parent = nodeMap[parentId];
        if (parent == null) {
          continue;
        }
        final int parentDepth = depthFor(parent) + 1;
        maxParentDepth = parentDepth > maxParentDepth
            ? parentDepth
            : maxParentDepth;
      }
      cache[node.id] = maxParentDepth;
      return maxParentDepth;
    }

    for (final SkillTreeGraphNode node in nodes) {
      depthFor(node);
    }
    return cache;
  }
}
