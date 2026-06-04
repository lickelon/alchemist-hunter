import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/common/themes/app_dialog_heights.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_progress_selectors.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_stage_runtime_selectors.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_result_list.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleResultSheet extends ConsumerWidget {
  const BattleResultSheet({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BattleLogEntry> logs = ref.watch(
      battleStageRecentLogsProvider(stageId),
    );
    final MaterialCatalogRepository materialCatalog = ref.watch(
      materialCatalogRepositoryProvider,
    );
    final String stageName = ref.watch(battleStageDisplayNameProvider(stageId));

    return AppSheetLayout(
      title: '$stageName 전투 기록',
      header: AppBadge(label: logs.isEmpty ? '기록 없음' : '기록 ${logs.length}건'),
      body: logs.isEmpty
          ? const AppEmptyState('전투 기록이 없습니다.')
          : BattleResultList(logs: logs, materialCatalog: materialCatalog),
    );
  }
}

class BattleResultDialog extends ConsumerWidget {
  const BattleResultDialog({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BattleLogEntry> logs = ref.watch(
      battleStageRecentLogsProvider(stageId),
    );
    final MaterialCatalogRepository materialCatalog = ref.watch(
      materialCatalogRepositoryProvider,
    );
    final String stageName = ref.watch(battleStageDisplayNameProvider(stageId));

    return AppDialogLayout(
      title: '$stageName 전투 기록',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppBadge(label: logs.isEmpty ? '기록 없음' : '기록 ${logs.length}건'),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.maxFinite,
            height: MediaQuery.sizeOf(context).height * AppDialogHeights.medium,
            child: logs.isEmpty
                ? const AppEmptyState('전투 기록이 없습니다.')
                : BattleResultList(
                    logs: logs,
                    materialCatalog: materialCatalog,
                  ),
          ),
        ],
      ),
    );
  }
}
