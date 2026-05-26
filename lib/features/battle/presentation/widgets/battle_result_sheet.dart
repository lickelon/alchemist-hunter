import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
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
      header: Text(logs.isEmpty ? '기록 없음' : '기록 ${logs.length}건'),
      body: logs.isEmpty
          ? const Center(child: Text('전투 기록이 없습니다.'))
          : _BattleResultList(logs: logs, materialCatalog: materialCatalog),
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
          Text(logs.isEmpty ? '기록 없음' : '기록 ${logs.length}건'),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.maxFinite,
            height: MediaQuery.sizeOf(context).height * 0.52,
            child: logs.isEmpty
                ? const Center(child: Text('전투 기록이 없습니다.'))
                : _BattleResultList(
                    logs: logs,
                    materialCatalog: materialCatalog,
                  ),
          ),
        ],
      ),
    );
  }
}

class _BattleResultList extends StatelessWidget {
  const _BattleResultList({required this.logs, required this.materialCatalog});

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
                const Expanded(child: Text('전투 결과')),
                if (log.wipedParty)
                  Text('전멸', style: TextStyle(color: colorScheme.error)),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _formatClock(log.resolvedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            subtitle: Text(
              '${log.success ? '성공' : '실패'} / 골드 ${battleSignedValueLabel(log.gold)} / 정수 ${battleSignedValueLabel(log.essence)} / 재료 ${log.materials.length}종 / 행동 ${log.turns}회${log.usedLoadoutFallback ? ' / 포션 부족' : ''}',
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
              if (log.actions.isNotEmpty) const SizedBox(height: AppSpacing.sm),
              ...log.actions.map((BattleActionLog action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
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
    );
  }
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
  if (action.type == BattleActionType.skillUse) {
    return 'T${action.turn} ${action.actorName} ${action.skillName ?? '스킬'} 사용';
  }
  if (action.type == BattleActionType.lifesteal) {
    return 'T${action.turn} ${action.actorName} 흡혈 +${action.healing} / HP ${action.actorHpAfter}';
  }
  if (action.type == BattleActionType.heal) {
    return 'T${action.turn} ${action.actorName} -> ${action.targetName ?? action.actorName} 회복 +${action.healing} / 대상 HP ${action.targetHpAfter ?? action.actorHpAfter}';
  }
  if (action.type == BattleActionType.modifier) {
    return 'T${action.turn} ${action.actorName} -> ${action.targetName ?? action.actorName} 효과 부여';
  }
  if (action.type == BattleActionType.status) {
    return _formatStatusAction(action);
  }
  if (action.type == BattleActionType.shield) {
    return 'T${action.turn} ${action.actorName} -> ${action.targetName ?? action.actorName} 보호막 +${action.healing} / 보호막 ${action.targetShieldAfter ?? 0}';
  }
  if (action.type == BattleActionType.passive) {
    return 'T${action.turn} ${action.actorName} 패시브 발동';
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
  final String mpLabel = action.mpSpent > 0 ? ' / 마나 -${action.mpSpent}' : '';
  return 'T${action.turn} ${action.actorName} -> ${action.targetName} $schoolLabel ${action.damage}$criticalLabel$mpLabel / 대상 HP ${action.targetHpAfter ?? 0}';
}

String _formatStatusAction(BattleActionLog action) {
  final String statusLabel = _statusLabel(action.statusType);
  if (action.damage > 0) {
    return 'T${action.turn} ${action.actorName} $statusLabel 피해 ${action.damage} / HP ${action.actorHpAfter}';
  }
  if (action.statusType == BattleStatusType.stun && action.targetName == null) {
    return 'T${action.turn} ${action.actorName} $statusLabel로 행동 불가 / HP ${action.actorHpAfter}';
  }
  if (action.targetName != null) {
    return 'T${action.turn} ${action.actorName} -> ${action.targetName} $statusLabel 부여';
  }
  return 'T${action.turn} ${action.actorName} $statusLabel';
}

String _statusLabel(BattleStatusType? statusType) {
  return switch (statusType) {
    BattleStatusType.poison => '중독',
    BattleStatusType.stun => '기절',
    null => '상태효과',
  };
}
