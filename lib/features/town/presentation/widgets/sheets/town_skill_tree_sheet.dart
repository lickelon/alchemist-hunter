import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';

/// 스킬 트리 depth 당 들여쓰기 크기 (pt).
const double _kDepthIndent = 20.0;

/// depth 무한 증가로 인한 가로 overflow 방지용 상한.
const int _kMaxDepth = 6;

class TownSkillTreeSheet extends ConsumerWidget {
  const TownSkillTreeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int townInsight = ref.watch(townInsightProvider);
    final int gold = ref.watch(townGoldProvider);
    final List<TownSkillNodeView> nodes = ref.watch(townSkillNodeViewsProvider);

    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '마을 스킬트리',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('TownInsight $townInsight / Gold $gold'),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView(
              children: nodes.map((TownSkillNodeView node) {
                final int clampedDepth = node.depth.clamp(0, _kMaxDepth);
                return Padding(
                  padding: EdgeInsets.only(
                    left: clampedDepth * _kDepthIndent,
                    bottom: AppSpacing.md,
                  ),
                  child: Card(
                    margin: EdgeInsets.zero,
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
        ],
      ),
    );
  }
}
