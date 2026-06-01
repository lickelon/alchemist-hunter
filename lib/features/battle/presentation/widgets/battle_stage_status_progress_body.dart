import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_status_view_model.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_smooth_progress_bar.dart';
import 'package:flutter/material.dart';

class BattleStageStatusProgressBody extends StatelessWidget {
  const BattleStageStatusProgressBody({
    super.key,
    required this.statusLabel,
    required this.progress,
  });

  final String statusLabel;
  final BattleStagePhaseProgress progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(statusLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: AppSpacing.sm),
        BattleSmoothProgressBar(value: progress.value.clamp(0, 1)),
      ],
    );
  }
}
