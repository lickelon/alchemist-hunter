import 'package:alchemist_hunter/common/themes/app_dialog_heights.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_drop_selectors.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_drop_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleStageDropSheet extends ConsumerWidget {
  const BattleStageDropSheet({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BattleStageDropOverviewView overview = ref.watch(
      battleStageDropOverviewProvider(stageId),
    );

    return AppSheetLayout(
      title: '${overview.stageName} 적 정보',
      header: _BattleStageDropHeader(overview: overview),
      body: BattleStageDropList(overview: overview),
    );
  }
}

class BattleStageDropDialog extends ConsumerWidget {
  const BattleStageDropDialog({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BattleStageDropOverviewView overview = ref.watch(
      battleStageDropOverviewProvider(stageId),
    );

    return AppDialogLayout(
      title: '${overview.stageName} 적 정보',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _BattleStageDropHeader(overview: overview),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.maxFinite,
            height: MediaQuery.sizeOf(context).height * AppDialogHeights.medium,
            child: BattleStageDropList(overview: overview),
          ),
        ],
      ),
    );
  }
}

class _BattleStageDropHeader extends StatelessWidget {
  const _BattleStageDropHeader({required this.overview});

  final BattleStageDropOverviewView overview;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        AppBadge(label: '권장 ${overview.recommendedPower}'),
        AppBadge(label: '적 ${overview.enemyCount}종'),
      ],
    );
  }
}
