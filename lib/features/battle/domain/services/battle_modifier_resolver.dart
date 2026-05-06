part of 'battle_service.dart';

class _BattleModifierResolver {
  static bool hasPassive(_BattleUnit unit, BattlePassiveEffectType type) {
    return unit.passives.any(
      (BattlePassiveEffect passive) => passive.type == type,
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
