import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_label_formatters.dart';

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
            '${entry.label} ${signed ? signedValue(entry.value) : entry.value}',
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
  final List<String> lines = modifiers.map(equipmentStatModifierLabel).toList();
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

String equipmentStatModifierLabel(BattleStatModifier modifier) {
  final String valueLabel = battleStatModifierUsesPercent(modifier.type)
      ? signedPercent(modifier.value)
      : signedValue(modifier.value.round());
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

bool battleStatModifierUsesPercent(BattleStatModifierType type) {
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
