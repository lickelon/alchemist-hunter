import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_result_log_formatters.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';
import 'package:flutter/material.dart';

class BattleResultList extends StatelessWidget {
  const BattleResultList({
    super.key,
    required this.logs,
    required this.materialCatalog,
  });

  final List<BattleLogEntry> logs;
  final MaterialCatalogRepository materialCatalog;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      itemCount: logs.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final BattleLogEntry log = logs[index];
        final List<String> resultLabels = <String>[
          log.success ? '성공' : '실패',
          '골드 ${battleSignedValueLabel(log.gold)}',
          '정수 ${battleSignedValueLabel(log.essence)}',
          '재료 ${log.materials.length}종',
          '행동 ${log.turns}회',
          if (log.usedLoadoutFallback) '포션 부족',
        ];
        return Card(
          child: ExpansionTile(
            initiallyExpanded: index == 0,
            title: Row(
              children: <Widget>[
                Icon(
                  log.success
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 18,
                  color: log.success ? colorScheme.primary : colorScheme.error,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: resultLabels
                        .map((String label) => AppBadge(label: label))
                        .toList(growable: false),
                  ),
                ),
                if (log.wipedParty)
                  Text('전멸', style: TextStyle(color: colorScheme.error)),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  formatBattleResultClock(log.resolvedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: <Widget>[
              if (log.usedLoadoutFallback)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('포션 부족으로 로드아웃이 적용되지 않았습니다.'),
                ),
              if (log.usedLoadoutFallback &&
                  (log.materials.isNotEmpty || log.actions.isNotEmpty))
                const SizedBox(height: AppSpacing.md),
              if (log.materials.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '획득 재료: ${formatBattleResultMaterials(log.materials, materialCatalog)}',
                  ),
                ),
              if (log.materials.isNotEmpty && log.actions.isNotEmpty)
                const SizedBox(height: AppSpacing.md),
              if (log.actions.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '행동 로그 ${log.actions.length}건',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              if (log.actions.isNotEmpty) const SizedBox(height: AppSpacing.sm),
              ...log.actions.map((BattleActionLog action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatBattleResultAction(action),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
