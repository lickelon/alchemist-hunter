import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

enum EquipmentSlot { weapon, armor, accessory }

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

String _signedValue(int value) => value >= 0 ? '+$value' : '$value';

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

String _statModifierLabel(BattleStatModifier modifier) {
  final String valueLabel = _battleStatModifierUsesPercent(modifier.type)
      ? _signedPercent(modifier.value)
      : _signedValue(modifier.value.round());
  return switch (modifier.type) {
    BattleStatModifierType.maxHp => '체력 $valueLabel',
    BattleStatModifierType.maxMp => 'MP $valueLabel',
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
    BattleStatModifierType.mpRegen => 'MP재생 $valueLabel',
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

@immutable
class EquipmentEnchant {
  const EquipmentEnchant({
    required this.potionStackKey,
    required this.potionName,
    required this.qualityLabel,
    required this.dominantTraitId,
    this.magicalAttackBonus = 0,
    this.magicalDefenseBonus = 0,
    this.speedBonus = 0,
    this.statModifiers = const <BattleStatModifier>[],
    this.modifiers = const <BattleModifier>[],
    this.passives = const <BattlePassiveEffect>[],
    int maxHpBonus = 0,
    int physicalAttackBonus = 0,
    int physicalDefenseBonus = 0,
    int attackBonus = 0,
    int defenseBonus = 0,
    int healthBonus = 0,
  }) : maxHpBonus = maxHpBonus != 0 ? maxHpBonus : healthBonus,
       physicalAttackBonus = physicalAttackBonus != 0
           ? physicalAttackBonus
           : attackBonus,
       physicalDefenseBonus = physicalDefenseBonus != 0
           ? physicalDefenseBonus
           : defenseBonus;

  final String potionStackKey;
  final String potionName;
  final String qualityLabel;
  final String dominantTraitId;
  final int maxHpBonus;
  final int physicalAttackBonus;
  final int physicalDefenseBonus;
  final int magicalAttackBonus;
  final int magicalDefenseBonus;
  final int speedBonus;
  final List<BattleStatModifier> statModifiers;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;

  int get attackBonus => physicalAttackBonus;

  int get defenseBonus => physicalDefenseBonus;

  int get healthBonus => maxHpBonus;

  String get label => '$potionName $qualityLabel';

  String get statLabel => formatEquipmentStatLabel(
    maxHp: maxHpBonus,
    physicalAttack: physicalAttackBonus,
    physicalDefense: physicalDefenseBonus,
    magicalAttack: magicalAttackBonus,
    magicalDefense: magicalDefenseBonus,
    speed: speedBonus,
    signed: true,
    includeZero: false,
    emptyLabel: '보정 없음',
  );

  String get effectLabel => formatEquipmentEffectLabel(
    statModifiers: statModifiers,
    modifiers: modifiers,
    passives: passives,
  );
}

@immutable
class EquipmentBlueprint {
  const EquipmentBlueprint({
    required this.id,
    required this.name,
    required this.slot,
    required this.materialCosts,
    this.craftDuration = const Duration(seconds: 30),
    this.magicalAttack = 0,
    this.magicalDefense = 0,
    this.speed = 0,
    this.statModifiers = const <BattleStatModifier>[],
    this.modifiers = const <BattleModifier>[],
    this.passives = const <BattlePassiveEffect>[],
    int maxHp = 0,
    int physicalAttack = 0,
    int physicalDefense = 0,
    int attack = 0,
    int defense = 0,
    int health = 0,
  }) : maxHp = maxHp != 0 ? maxHp : health,
       physicalAttack = physicalAttack != 0 ? physicalAttack : attack,
       physicalDefense = physicalDefense != 0 ? physicalDefense : defense;

  final String id;
  final String name;
  final EquipmentSlot slot;
  final Map<String, int> materialCosts;
  final Duration craftDuration;
  final int maxHp;
  final int physicalAttack;
  final int physicalDefense;
  final int magicalAttack;
  final int magicalDefense;
  final int speed;
  final List<BattleStatModifier> statModifiers;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;

  int get attack => physicalAttack;

  int get defense => physicalDefense;

  int get health => maxHp;

  String get statLabel => formatEquipmentStatLabel(
    maxHp: maxHp,
    physicalAttack: physicalAttack,
    physicalDefense: physicalDefense,
    magicalAttack: magicalAttack,
    magicalDefense: magicalDefense,
    speed: speed,
  );

  String get effectLabel => formatEquipmentEffectLabel(
    statModifiers: statModifiers,
    modifiers: modifiers,
    passives: passives,
  );
}

@immutable
class EquipmentInstance {
  const EquipmentInstance({
    required this.id,
    required this.blueprintId,
    required this.name,
    required this.slot,
    this.magicalAttack = 0,
    this.magicalDefense = 0,
    this.speed = 0,
    this.statModifiers = const <BattleStatModifier>[],
    this.modifiers = const <BattleModifier>[],
    this.passives = const <BattlePassiveEffect>[],
    int maxHp = 0,
    int physicalAttack = 0,
    int physicalDefense = 0,
    int attack = 0,
    int defense = 0,
    int health = 0,
    required this.createdAt,
    this.enchant,
  }) : maxHp = maxHp != 0 ? maxHp : health,
       physicalAttack = physicalAttack != 0 ? physicalAttack : attack,
       physicalDefense = physicalDefense != 0 ? physicalDefense : defense;

  final String id;
  final String blueprintId;
  final String name;
  final EquipmentSlot slot;
  final int maxHp;
  final int physicalAttack;
  final int physicalDefense;
  final int magicalAttack;
  final int magicalDefense;
  final int speed;
  final List<BattleStatModifier> statModifiers;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;
  final DateTime createdAt;
  final EquipmentEnchant? enchant;

  int get attack => physicalAttack;

  int get defense => physicalDefense;

  int get health => maxHp;

  int get totalMaxHp => maxHp + (enchant?.maxHpBonus ?? 0);

  int get totalPhysicalAttack =>
      physicalAttack + (enchant?.physicalAttackBonus ?? 0);

  int get totalPhysicalDefense =>
      physicalDefense + (enchant?.physicalDefenseBonus ?? 0);

  int get totalMagicalAttack =>
      magicalAttack + (enchant?.magicalAttackBonus ?? 0);

  int get totalMagicalDefense =>
      magicalDefense + (enchant?.magicalDefenseBonus ?? 0);

  int get totalSpeed => speed + (enchant?.speedBonus ?? 0);

  int get totalAttack => totalPhysicalAttack;

  int get totalDefense => totalPhysicalDefense;

  int get totalHealth => totalMaxHp;

  List<BattleStatModifier> get totalStatModifiers => <BattleStatModifier>[
    ...statModifiers,
    ...?enchant?.statModifiers,
  ];

  List<BattleModifier> get totalModifiers => <BattleModifier>[
    ...modifiers,
    ...?enchant?.modifiers,
  ];

  List<BattlePassiveEffect> get totalPassives => <BattlePassiveEffect>[
    ...passives,
    ...?enchant?.passives,
  ];

  String get statLabel => formatEquipmentStatLabel(
    maxHp: totalMaxHp,
    physicalAttack: totalPhysicalAttack,
    physicalDefense: totalPhysicalDefense,
    magicalAttack: totalMagicalAttack,
    magicalDefense: totalMagicalDefense,
    speed: totalSpeed,
  );

  String get effectLabel => formatEquipmentEffectLabel(
    statModifiers: totalStatModifiers,
    modifiers: totalModifiers,
    passives: totalPassives,
  );

  String get detailLabel {
    final List<String> lines = <String>[
      statLabel,
      if (enchant != null) '인챈트 ${enchant!.label}',
    ];
    if (totalStatModifiers.isNotEmpty ||
        totalModifiers.isNotEmpty ||
        totalPassives.isNotEmpty) {
      lines.add(effectLabel);
    }
    return lines.join('\n');
  }

  EquipmentInstance copyWith({
    EquipmentEnchant? enchant,
    bool clearEnchant = false,
  }) {
    return EquipmentInstance(
      id: id,
      blueprintId: blueprintId,
      name: name,
      slot: slot,
      maxHp: maxHp,
      physicalAttack: physicalAttack,
      physicalDefense: physicalDefense,
      magicalAttack: magicalAttack,
      magicalDefense: magicalDefense,
      speed: speed,
      statModifiers: statModifiers,
      modifiers: modifiers,
      passives: passives,
      createdAt: createdAt,
      enchant: clearEnchant ? null : enchant ?? this.enchant,
    );
  }
}
