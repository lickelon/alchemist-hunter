import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';

String formatBattleResultClock(DateTime dateTime) {
  final String hour = dateTime.hour.toString().padLeft(2, '0');
  final String minute = dateTime.minute.toString().padLeft(2, '0');
  final String second = dateTime.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}

String formatBattleResultMaterials(
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

String formatBattleResultAction(BattleActionLog action) {
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
