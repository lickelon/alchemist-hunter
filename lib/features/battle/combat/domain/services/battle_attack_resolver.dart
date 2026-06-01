part of 'battle_service.dart';

class _BattleAttackResolver {
  const _BattleAttackResolver({required Random random}) : _random = random;

  final Random _random;

  bool rollHit({
    required _BattleUnit attacker,
    required _BattleUnit defender,
    required int potionBoost,
  }) {
    if (_BattleModifierResolver.hasPassive(
      attacker,
      BattlePassiveEffectType.alwaysHit,
      trigger: BattlePassiveTrigger.beforeHitCheck,
    )) {
      return true;
    }
    final double accuracyBonus = potionBoost * 0.02;
    final double hitChance =
        (attacker.stats.accuracy + accuracyBonus - defender.stats.evasion)
            .clamp(0.25, 0.98);
    return _random.nextDouble() <= hitChance;
  }

  bool rollCritical({
    required _BattleUnit attacker,
    required _BattleUnit defender,
    required int potionBoost,
  }) {
    final double critChance =
        (attacker.stats.critChance + (potionBoost * 0.005)).clamp(0, 0.95);
    return _random.nextDouble() <= critChance;
  }

  _DamageRoll rollDamage({
    required _BattleUnit attacker,
    required _BattleUnit defender,
    required bool critical,
    required int potionBoost,
    BattleSkillDefinition? skill,
  }) {
    final bool useMagic = skill?.school == DamageSchool.magical
        ? true
        : skill?.school == DamageSchool.physical
        ? false
        : attacker.stats.magicalAttack > attacker.stats.physicalAttack;
    final int attack = useMagic
        ? attacker.stats.magicalAttack
        : attacker.stats.physicalAttack;
    final int defense = useMagic
        ? defender.stats.magicalDefense
        : defender.stats.physicalDefense;
    final double penetration = useMagic
        ? attacker.stats.magicalPenetration
        : attacker.stats.physicalPenetration;
    final DamageSchool school = useMagic
        ? DamageSchool.magical
        : DamageSchool.physical;
    final double effectiveDefense = defense * (1 - penetration.clamp(0, 0.8));
    double damage =
        attack * max(0.28, 1 - (effectiveDefense / max(attack * 2.2 + 16, 1)));

    if (attacker.side == _BattleSide.ally && potionBoost > 0) {
      damage *= 1 + (potionBoost * 0.08);
    }
    if (skill != null) {
      damage = (damage * skill.powerMultiplier) + skill.flatPower;
    }
    if (critical) {
      damage *= 1 + attacker.stats.critDamage;
    }
    damage *=
        1 +
        _BattleModifierResolver.percentModifierTotal(
          attacker,
          BattleModifierType.damageDealt,
          school: school,
          targetFaction: defender.faction,
        );
    damage *=
        1 +
        _BattleModifierResolver.percentModifierTotal(
          defender,
          BattleModifierType.damageTaken,
          school: school,
          targetFaction: attacker.faction,
        );
    return _DamageRoll(
      damage: max(max(attack ~/ 4, 1), damage.round()),
      school: school,
    );
  }
}
