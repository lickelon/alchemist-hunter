import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_label_formatters.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_stat_labels.dart';

String formatEquipmentEffectLabel({
  required List<BattleStatModifier> statModifiers,
  required List<BattleModifier> modifiers,
  required List<BattlePassiveEffect> passives,
  String emptyLabel = '특수 효과 없음',
}) {
  final List<String> lines = <String>[
    ...statModifiers.map(equipmentStatModifierLabel),
    ...modifiers.map(equipmentModifierLabel),
    ...passives.map(equipmentPassiveLabel),
  ];
  if (lines.isEmpty) {
    return emptyLabel;
  }
  return lines.join('\n');
}

String equipmentEnchantEffectLabel(EquipmentEnchant enchant) {
  return formatEquipmentEffectLabel(
    statModifiers: enchant.statModifiers,
    modifiers: enchant.modifiers,
    passives: enchant.passives,
  );
}

String equipmentBlueprintEffectLabel(EquipmentBlueprint blueprint) {
  return formatEquipmentEffectLabel(
    statModifiers: blueprint.statModifiers,
    modifiers: blueprint.modifiers,
    passives: blueprint.passives,
  );
}

String equipmentInstanceEffectLabel(EquipmentInstance equipment) {
  return formatEquipmentEffectLabel(
    statModifiers: equipment.totalStatModifiers,
    modifiers: equipment.totalModifiers,
    passives: equipment.totalPassives,
  );
}

String equipmentModifierLabel(BattleModifier modifier) {
  final String valueLabel = signedPercent(modifier.value);
  final String schoolLabel = switch (modifier.school) {
    DamageSchool.any => '',
    DamageSchool.physical => ' / 물리',
    DamageSchool.magical => ' / 마법',
  };
  final String targetLabel = modifier.targetFaction == null
      ? ''
      : ' / 대 ${modifier.targetFaction == CombatFaction.mercenary ? "용병" : "호문쿨루스"}';
  final String base = switch (modifier.type) {
    BattleModifierType.damageDealt => '주는 피해 $valueLabel',
    BattleModifierType.damageTaken => '받는 피해 $valueLabel',
  };
  return '$base$schoolLabel$targetLabel';
}

String equipmentPassiveLabel(BattlePassiveEffect passive) {
  return switch (passive.type) {
    BattlePassiveEffectType.alwaysHit => '패시브: 필중',
    BattlePassiveEffectType.extraAttack => '패시브: 추가 공격 +${passive.value ?? 1}회',
    BattlePassiveEffectType.firstStrike => '패시브: 선공',
    BattlePassiveEffectType.counterAttack => '패시브: 반격 +${passive.value ?? 1}회',
    BattlePassiveEffectType.grantModifier => '패시브: 버프/디버프 부여',
    BattlePassiveEffectType.grantStatus => '패시브: 상태이상 부여',
    BattlePassiveEffectType.grantShield => '패시브: 보호막 부여',
  };
}
