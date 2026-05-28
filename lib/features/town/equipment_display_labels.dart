import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

String equipmentSlotLabel(EquipmentSlot slot) {
  return switch (slot) {
    EquipmentSlot.weapon => '무기',
    EquipmentSlot.armor => '방어구',
    EquipmentSlot.accessory => '장신구',
  };
}

String formatEquipmentStatLabel({
  required int maxHp,
  required int physicalAttack,
  required int physicalDefense,
  required int magicalAttack,
  required int magicalDefense,
  required int speed,
  bool signed = false,
  bool includeZero = true,
  String emptyLabel = '없음',
}) {
  final List<({String label, int value})> stats = <({String label, int value})>[
    (label: '체력', value: maxHp),
    (label: '물공', value: physicalAttack),
    (label: '물방', value: physicalDefense),
    (label: '마공', value: magicalAttack),
    (label: '마방', value: magicalDefense),
    (label: '속도', value: speed),
  ];

  final List<String> segments = stats
      .where(
        (({String label, int value}) entry) => includeZero || entry.value != 0,
      )
      .map(
        (({String label, int value}) entry) =>
            '${entry.label} ${signed ? _signedValue(entry.value) : entry.value}',
      )
      .toList(growable: false);

  if (segments.isEmpty) {
    return emptyLabel;
  }
  if (includeZero) {
    return '${segments.take(3).join(' / ')}\n${segments.skip(3).join(' / ')}';
  }
  return segments.join(' / ');
}

String formatEquipmentStatModifierLabel(
  List<BattleStatModifier> modifiers, {
  String emptyLabel = '추가 스탯 없음',
}) {
  final List<String> lines = modifiers.map(_statModifierLabel).toList();
  if (lines.isEmpty) {
    return emptyLabel;
  }
  return lines.join('\n');
}

String formatEquipmentEffectLabel({
  required List<BattleStatModifier> statModifiers,
  required List<BattleModifier> modifiers,
  required List<BattlePassiveEffect> passives,
  String emptyLabel = '특수 효과 없음',
}) {
  final List<String> lines = <String>[
    ...statModifiers.map(_statModifierLabel),
    ...modifiers.map(_modifierLabel),
    ...passives.map(_passiveLabel),
  ];
  if (lines.isEmpty) {
    return emptyLabel;
  }
  return lines.join('\n');
}

String equipmentEnchantStatLabel(EquipmentEnchant enchant) {
  return formatEquipmentStatLabel(
    maxHp: enchant.maxHpBonus,
    physicalAttack: enchant.physicalAttackBonus,
    physicalDefense: enchant.physicalDefenseBonus,
    magicalAttack: enchant.magicalAttackBonus,
    magicalDefense: enchant.magicalDefenseBonus,
    speed: enchant.speedBonus,
    signed: true,
    includeZero: false,
    emptyLabel: '보정 없음',
  );
}

String equipmentEnchantEffectLabel(EquipmentEnchant enchant) {
  return formatEquipmentEffectLabel(
    statModifiers: enchant.statModifiers,
    modifiers: enchant.modifiers,
    passives: enchant.passives,
  );
}

String equipmentBlueprintStatLabel(EquipmentBlueprint blueprint) {
  return formatEquipmentStatLabel(
    maxHp: blueprint.maxHp,
    physicalAttack: blueprint.physicalAttack,
    physicalDefense: blueprint.physicalDefense,
    magicalAttack: blueprint.magicalAttack,
    magicalDefense: blueprint.magicalDefense,
    speed: blueprint.speed,
  );
}

String equipmentBlueprintEffectLabel(EquipmentBlueprint blueprint) {
  return formatEquipmentEffectLabel(
    statModifiers: blueprint.statModifiers,
    modifiers: blueprint.modifiers,
    passives: blueprint.passives,
  );
}

String equipmentBlueprintDetailLabel(EquipmentBlueprint blueprint) {
  final String statLabel = equipmentBlueprintStatLabel(blueprint);
  if (blueprint.statModifiers.isEmpty &&
      blueprint.modifiers.isEmpty &&
      blueprint.passives.isEmpty) {
    return statLabel;
  }
  return '$statLabel\n${equipmentBlueprintEffectLabel(blueprint)}';
}

String equipmentInstanceStatLabel(EquipmentInstance equipment) {
  return formatEquipmentStatLabel(
    maxHp: equipment.totalMaxHp,
    physicalAttack: equipment.totalPhysicalAttack,
    physicalDefense: equipment.totalPhysicalDefense,
    magicalAttack: equipment.totalMagicalAttack,
    magicalDefense: equipment.totalMagicalDefense,
    speed: equipment.totalSpeed,
  );
}

String equipmentInstanceEffectLabel(EquipmentInstance equipment) {
  return formatEquipmentEffectLabel(
    statModifiers: equipment.totalStatModifiers,
    modifiers: equipment.totalModifiers,
    passives: equipment.totalPassives,
  );
}

String equipmentInstanceDetailLabel(EquipmentInstance equipment) {
  final List<String> lines = <String>[
    equipmentInstanceStatLabel(equipment),
    if (equipment.enchant != null) '인챈트 ${equipment.enchant!.label}',
  ];
  if (equipment.totalStatModifiers.isNotEmpty ||
      equipment.totalModifiers.isNotEmpty ||
      equipment.totalPassives.isNotEmpty) {
    lines.add(equipmentInstanceEffectLabel(equipment));
  }
  return lines.join('\n');
}

String _signedValue(int value) => value >= 0 ? '+$value' : '$value';

String _statModifierLabel(BattleStatModifier modifier) {
  final String valueLabel = _battleStatModifierUsesPercent(modifier.type)
      ? _signedPercent(modifier.value)
      : _signedValue(modifier.value.round());
  return switch (modifier.type) {
    BattleStatModifierType.maxHp => '체력 $valueLabel',
    BattleStatModifierType.maxMp => '마나 $valueLabel',
    BattleStatModifierType.physicalAttack => '물공 $valueLabel',
    BattleStatModifierType.physicalDefense => '물방 $valueLabel',
    BattleStatModifierType.magicalAttack => '마공 $valueLabel',
    BattleStatModifierType.magicalDefense => '마방 $valueLabel',
    BattleStatModifierType.speed => '속도 $valueLabel',
    BattleStatModifierType.critRate => '치확 $valueLabel',
    BattleStatModifierType.critDamage => '치피 $valueLabel',
    BattleStatModifierType.accuracy => '명중 $valueLabel',
    BattleStatModifierType.evasion => '회피 $valueLabel',
    BattleStatModifierType.statusAccuracy => '상태적중 $valueLabel',
    BattleStatModifierType.statusResistance => '상태저항 $valueLabel',
    BattleStatModifierType.physicalPenetration => '물관 $valueLabel',
    BattleStatModifierType.magicalPenetration => '마관 $valueLabel',
    BattleStatModifierType.lifesteal => '흡혈 $valueLabel',
    BattleStatModifierType.healingPower => '회복력 $valueLabel',
    BattleStatModifierType.regen => '재생 $valueLabel',
    BattleStatModifierType.mpRegen => '마나재생 $valueLabel',
  };
}

String _modifierLabel(BattleModifier modifier) {
  final String valueLabel = _signedPercent(modifier.value);
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

String _passiveLabel(BattlePassiveEffect passive) {
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

String _signedPercent(double value) {
  final int percent = (value * 100).round();
  if (percent > 0) {
    return '+$percent%';
  }
  return '$percent%';
}

bool _battleStatModifierUsesPercent(BattleStatModifierType type) {
  return switch (type) {
    BattleStatModifierType.maxHp ||
    BattleStatModifierType.maxMp ||
    BattleStatModifierType.physicalAttack ||
    BattleStatModifierType.physicalDefense ||
    BattleStatModifierType.magicalAttack ||
    BattleStatModifierType.magicalDefense ||
    BattleStatModifierType.speed => false,
    BattleStatModifierType.critRate ||
    BattleStatModifierType.critDamage ||
    BattleStatModifierType.accuracy ||
    BattleStatModifierType.evasion ||
    BattleStatModifierType.statusAccuracy ||
    BattleStatModifierType.statusResistance ||
    BattleStatModifierType.physicalPenetration ||
    BattleStatModifierType.magicalPenetration ||
    BattleStatModifierType.lifesteal ||
    BattleStatModifierType.healingPower ||
    BattleStatModifierType.regen => true,
    BattleStatModifierType.mpRegen => false,
  };
}
