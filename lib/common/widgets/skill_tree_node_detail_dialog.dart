import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
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
          DetailLines(
            description: node.description,
            lines: <String>[
              '현재 효과 ${node.currentEffectLabel}',
              '다음 효과 ${node.nextEffectLabel}',
              node.prerequisiteLabel,
              '비용 ${node.costLabel}',
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
