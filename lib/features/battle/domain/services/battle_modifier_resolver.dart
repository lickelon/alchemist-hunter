part of 'battle_service.dart';

class _BattleModifierResolver {
  static bool hasPassive(
    _BattleUnit unit,
    BattlePassiveEffectType type, {
    BattlePassiveTrigger? trigger,
  }) {
    return unit.passives.any(
      (BattlePassiveEffect passive) =>
          passive.type == type &&
          (trigger == null || passive.trigger == trigger),
    );
  }

  static int extraAttackCount(_BattleUnit unit) {
    return unit.passives
        .where(
          (BattlePassiveEffect passive) =>
              passive.type == BattlePassiveEffectType.extraAttack &&
              passive.trigger == BattlePassiveTrigger.afterAction,
        )
        .fold<int>(0, (int total, BattlePassiveEffect passive) {
          return total + (passive.value ?? 1);
        });
  }

  static int counterAttackCount(_BattleUnit unit) {
    return unit.passives
        .where(
          (BattlePassiveEffect passive) =>
              passive.type == BattlePassiveEffectType.counterAttack &&
              passive.trigger == BattlePassiveTrigger.onDamaged,
        )
        .fold<int>(0, (int total, BattlePassiveEffect passive) {
          return total + (passive.value ?? 1);
        });
  }

  static int firstStrikePriority(_BattleUnit unit) {
    return unit.passives
        .where(
          (BattlePassiveEffect passive) =>
              passive.type == BattlePassiveEffectType.firstStrike &&
              passive.trigger == BattlePassiveTrigger.battleStart,
        )
        .fold<int>(0, (int total, BattlePassiveEffect passive) {
          return total + (passive.value ?? 1);
        });
  }

  static double percentModifierTotal(
    _BattleUnit unit,
    BattleModifierType type, {
    required DamageSchool school,
    required CombatFaction targetFaction,
  }) {
    return unit.modifiers
        .where(
          (BattleModifier modifier) =>
              modifier.type == type &&
              modifier.mode == BattleModifierMode.percent &&
              (modifier.school == DamageSchool.any ||
                  modifier.school == school) &&
              (modifier.targetFaction == null ||
                  modifier.targetFaction == targetFaction),
        )
        .fold<double>(0, (double total, BattleModifier modifier) {
          return total + modifier.value;
        });
  }
}
