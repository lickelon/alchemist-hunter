part of 'battle_combat_stat_service.dart';

int _summaryPowerForStats(BattleCombatStats stats) {
  final int offense =
      (stats.physicalAttack * 2) + (stats.magicalAttack * 2) + stats.speed;
  final int defense = stats.physicalDefense + stats.magicalDefense;
  final int health = stats.maxHp ~/ 4;
  final int resource = (stats.maxMp ~/ 5) + (stats.mpRegen * 2);
  final int utility =
      (stats.critChance * 100).round() +
      (stats.critDamage * 80).round() +
      (stats.accuracy * 10).round() +
      (stats.evasion * 10).round() +
      (stats.statusAccuracy * 10).round() +
      (stats.statusResistance * 10).round() +
      (stats.physicalPenetration * 80).round() +
      (stats.magicalPenetration * 80).round() +
      (stats.lifesteal * 120).round() +
      (stats.healingPower * 100).round() +
      (stats.regen * 100).round();
  return health + resource + offense + defense + utility;
}

int _summaryPowerForEffects(
  List<BattleModifier> modifiers,
  List<BattlePassiveEffect> passives,
) {
  final int modifierPower = modifiers.fold<int>(0, (
    int total,
    BattleModifier modifier,
  ) {
    final double weightedValue = modifier.mode == BattleModifierMode.percent
        ? modifier.value.abs() * 100
        : modifier.value.abs() * 80;
    return total + weightedValue.round();
  });
  final int passivePower = passives.fold<int>(0, (
    int total,
    BattlePassiveEffect passive,
  ) {
    return total +
        switch (passive.type) {
          BattlePassiveEffectType.alwaysHit => 10,
          BattlePassiveEffectType.extraAttack => 14 * (passive.value ?? 1),
          BattlePassiveEffectType.firstStrike => 8 * (passive.value ?? 1),
          BattlePassiveEffectType.counterAttack => 12 * (passive.value ?? 1),
          BattlePassiveEffectType.grantModifier => 8,
          BattlePassiveEffectType.grantStatus => 8,
          BattlePassiveEffectType.grantShield => 8,
        };
  });
  return modifierPower + passivePower;
}
