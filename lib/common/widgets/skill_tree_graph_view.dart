import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/themes/app_tree_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:flutter/material.dart';

enum SkillTreeNodeState { maxed, upgradable, locked, insufficient }

class SkillTreeGraphNode {
  const SkillTreeGraphNode({
    required this.id,
    required this.parentIds,
    required this.title,
    required this.description,
    required this.levelLabel,
    required this.costLabel,
    required this.currentEffectLabel,
    required this.nextEffectLabel,
    required this.prerequisiteLabel,
    required this.statusLabel,
    required this.state,
  });

  final String id;
  final List<String> parentIds;
  final String title;
  final String description;
  final String levelLabel;
  final String costLabel;
  final String currentEffectLabel;
  final String nextEffectLabel;
  final String prerequisiteLabel;
  final String statusLabel;
  final SkillTreeNodeState state;
}

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
    final _SkillTreeGraphLayout layout = _SkillTreeGraphLayout.build(nodes);
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
                painter: _SkillTreeConnectorPainter(
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
                child: _SkillTreeNodeCard(
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

class _SkillTreeNodeCard extends StatelessWidget {
  const _SkillTreeNodeCard({required this.node, required this.onTap});

  final SkillTreeGraphNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color borderColor = _stateColor(theme, node.state);
    final Color backgroundColor = node.state == SkillTreeNodeState.locked
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.58)
        : theme.colorScheme.surface;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        child: ColoredBox(
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        node.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.of(context).subsectionTitle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppBadge(label: _stateBadgeLabel(node.state)),
                  ],
                ),
                const Spacer(),
                Text(
                  node.levelLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  node.statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(context).dataEmphasis.copyWith(
                    color: borderColor,
                    fontSize: theme.textTheme.bodySmall?.fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillTreeGraphLayout {
  const _SkillTreeGraphLayout({
    required this.positions,
    required this.centers,
    required this.size,
  });

  final Map<String, Offset> positions;
  final Map<String, Offset> centers;
  final Size size;

  static _SkillTreeGraphLayout build(List<SkillTreeGraphNode> nodes) {
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

    return _SkillTreeGraphLayout(
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

class _SkillTreeConnectorPainter extends CustomPainter {
  const _SkillTreeConnectorPainter({
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
  bool shouldRepaint(covariant _SkillTreeConnectorPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.centers != centers ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}

Color _stateColor(ThemeData theme, SkillTreeNodeState state) {
  return switch (state) {
    SkillTreeNodeState.maxed => theme.colorScheme.primary,
    SkillTreeNodeState.upgradable => theme.colorScheme.tertiary,
    SkillTreeNodeState.locked => theme.colorScheme.outlineVariant,
    SkillTreeNodeState.insufficient => theme.colorScheme.error,
  };
}

String _stateBadgeLabel(SkillTreeNodeState state) {
  return switch (state) {
    SkillTreeNodeState.maxed => '최대',
    SkillTreeNodeState.upgradable => '가능',
    SkillTreeNodeState.locked => '잠금',
    SkillTreeNodeState.insufficient => '부족',
  };
}
