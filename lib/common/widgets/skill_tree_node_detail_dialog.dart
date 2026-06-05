import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/skill_tree_graph_view.dart';
import 'package:flutter/material.dart';

class SkillTreeNodeDetailDialog extends StatelessWidget {
  const SkillTreeNodeDetailDialog({
    super.key,
    required this.node,
    required this.onUpgrade,
  });

  final SkillTreeGraphNode node;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final bool canUpgrade = node.state == SkillTreeNodeState.upgradable;
    return AppDialogLayout(
      title: node.title,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppBadge(label: node.levelLabel),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(label: node.statusLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            node.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              ..._badgeLabels(
                '현재',
                node.currentEffectLabels,
              ).map((String label) => AppBadge(label: label)),
              AppBadge(label: node.prerequisiteLabel),
              ..._badgeLabels(
                '비용',
                node.costLabels,
              ).map((String label) => AppBadge(label: label)),
              ..._badgeLabels(
                '다음',
                node.nextEffectLabels,
              ).map((String label) => AppBadge(label: label)),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
          label: const Text('닫기'),
        ),
        FilledButton.tonal(
          onPressed: canUpgrade
              ? () {
                  onUpgrade();
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('강화'),
        ),
      ],
    );
  }
}

List<String> _badgeLabels(String prefix, List<String> labels) {
  return labels.map((String label) => '$prefix $label').toList(growable: false);
}
