import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';

const double _kDepthIndent = 20.0;
const int _kMaxDepth = 6;

class TownSkillTreeSheet extends ConsumerWidget {
  const TownSkillTreeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int townInsight = ref.watch(townInsightProvider);
    final int gold = ref.watch(townGoldProvider);
    final List<TownSkillNodeView> nodes = ref.watch(townSkillNodeViewsProvider);

    return AppBottomSheet(
      child: AppSheetLayout(
        title: '마을 스킬트리',
        header: Text('마을 통찰 $townInsight / 골드 $gold'),
        body: ListView(
          children: nodes.map((TownSkillNodeView node) {
            final int clampedDepth = node.depth.clamp(0, _kMaxDepth);
            return Padding(
              padding: EdgeInsets.only(
                left: clampedDepth * _kDepthIndent,
                bottom: AppSpacing.md,
              ),
              child: Card(
                child: ListTile(
                  dense: true,
                  title: Text(
                    '${node.depth == 0 ? "●" : "↳"} ${node.name} (${node.levelLabel})',
                  ),
                  subtitle: Text(
                    '${node.description}\n현재 효과 ${node.currentEffectLabel}\n다음 효과 ${node.nextEffectLabel}\n${node.prerequisiteLabel}\n비용 ${node.costLabel}\n${node.statusLabel}',
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
      ),
    );
  }
}
