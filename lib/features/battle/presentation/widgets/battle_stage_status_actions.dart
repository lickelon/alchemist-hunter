import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_result_sheet.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_drop_sheet.dart';
import 'package:flutter/material.dart';

class BattleStageStatusActions extends StatelessWidget {
  const BattleStageStatusActions({
    super.key,
    required this.stageId,
    required this.hasRecentLogs,
  });

  final String stageId;
  final bool hasRecentLogs;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: <Widget>[
        FilledButton.tonalIcon(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return BattleStageDropSheet(stageId: stageId);
              },
            );
          },
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('적 조합 / 드롭'),
        ),
        FilledButton.tonalIcon(
          onPressed: hasRecentLogs
              ? () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return BattleResultSheet(stageId: stageId);
                    },
                  );
                }
              : null,
          icon: const Icon(Icons.history),
          label: const Text('최근 기록'),
        ),
      ],
    );
  }
}
