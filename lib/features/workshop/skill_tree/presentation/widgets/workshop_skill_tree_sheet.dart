import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/dashboard/presentation/viewmodels/workshop_shared_selectors.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/presentation/viewmodels/workshop_skill_tree_controller.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/presentation/viewmodels/workshop_skill_tree_selectors.dart';

const double _kDepthIndent = 20.0;
const int _kMaxDepth = 6;

class WorkshopSkillTreeSheet extends ConsumerWidget {
  const WorkshopSkillTreeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int arcaneDust = ref.watch(workshopArcaneDustProvider);
    final List<WorkshopSkillNodeView> nodes = ref.watch(
      workshopSkillNodeViewsProvider,
    );

    return AppBottomSheet(
      child: AppSheetLayout(
        title: '작업실 스킬트리',
        header: Text('ArcaneDust $arcaneDust'),
        body: ListView(
          children: nodes.map((WorkshopSkillNodeView node) {
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
                                .read(workshopSkillTreeControllerProvider)
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
