import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
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

    return AppBottomSheet(
      child: AppSheetLayout(
        title: '${battleStageDisplayName(stageId)} 전투 기록',
        header: Text(logs.isEmpty ? '최근 기록 없음' : '최근 ${logs.length}회'),
        body: logs.isEmpty
            ? const Center(child: Text('전투 기록이 없습니다.'))
            : ListView.separated(
                itemCount: logs.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (BuildContext context, int index) {
                  final BattleLogEntry log = logs[index];
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
                            color: log.success
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(log.success ? '성공' : '실패'),
                          const Spacer(),
                          Text(
                            _formatClock(log.resolvedAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '골드 ${battleSignedValueLabel(log.gold)} / 에센스 ${battleSignedValueLabel(log.essence)} / 재료 ${log.materials.length}종 / ${log.turns}턴',
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      children: <Widget>[
                        if (log.materials.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '획득 재료: ${_formatMaterials(log.materials, materialCatalog)}',
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
                        if (log.actions.isNotEmpty)
                          const SizedBox(height: AppSpacing.sm),
                        ...log.actions.map((BattleActionLog action) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formatAction(action),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatClock(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _formatMaterials(
    Map<String, int> materials,
    MaterialCatalogRepository materialCatalog,
  ) {
    return materials.entries
        .map((MapEntry<String, int> entry) {
          final String materialName =
              materialCatalog.materialName(entry.key) ?? entry.key;
          return '$materialName x${entry.value}';
        })
        .join(', ');
  }

  String _formatAction(BattleActionLog action) {
    if (action.type == BattleActionType.regen) {
      return 'T${action.turn} ${action.actorName} 재생 +${action.healing} / HP ${action.actorHpAfter}';
    }
    if (action.type == BattleActionType.lifesteal) {
      return 'T${action.turn} ${action.actorName} 흡혈 +${action.healing} / HP ${action.actorHpAfter}';
    }
    if (!action.hit) {
      return 'T${action.turn} ${action.actorName} -> ${action.targetName} 빗나감';
    }
    final String schoolLabel = switch (action.school) {
      DamageSchool.magical => '마법',
      DamageSchool.physical => '물리',
      DamageSchool.any => '공격',
    };
    final String criticalLabel = action.critical ? ' / 치명타' : '';
    return 'T${action.turn} ${action.actorName} -> ${action.targetName} $schoolLabel ${action.damage}$criticalLabel / 대상 HP ${action.targetHpAfter ?? 0}';
  }
}
