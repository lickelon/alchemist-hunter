import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_node.dart';
import 'package:flutter/material.dart';

class SkillTreeNodeCard extends StatelessWidget {
  const SkillTreeNodeCard({super.key, required this.node, required this.onTap});

  final SkillTreeGraphNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color borderColor = skillTreeNodeStateColor(theme, node.state);
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
                    AppBadge(label: skillTreeNodeStateBadgeLabel(node.state)),
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

Color skillTreeNodeStateColor(ThemeData theme, SkillTreeNodeState state) {
  return switch (state) {
    SkillTreeNodeState.maxed => theme.colorScheme.primary,
    SkillTreeNodeState.upgradable => theme.colorScheme.tertiary,
    SkillTreeNodeState.locked => theme.colorScheme.outlineVariant,
    SkillTreeNodeState.insufficient => theme.colorScheme.error,
  };
}

String skillTreeNodeStateBadgeLabel(SkillTreeNodeState state) {
  return switch (state) {
    SkillTreeNodeState.maxed => '최대',
    SkillTreeNodeState.upgradable => '가능',
    SkillTreeNodeState.locked => '잠금',
    SkillTreeNodeState.insufficient => '부족',
  };
}
