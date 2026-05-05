part of 'battle_service.dart';

class _BattleRecoveryResolver {
  const _BattleRecoveryResolver();

  int applyLifesteal({required _BattleUnit actor, required int damage}) {
    final double lifestealRate =
        actor.stats.lifesteal +
        _BattleModifierResolver.flatModifierTotal(
          actor,
          BattleModifierType.lifesteal,
        );
    if (damage <= 0 || lifestealRate <= 0) {
      return 0;
    }
    final int healing = max(1, (damage * lifestealRate).round());
    actor.currentHp = min(actor.maxHp, actor.currentHp + healing);
    return healing;
  }

  int applyRegen(_BattleUnit unit) {
    final double regenRate =
        unit.stats.regen +
        _BattleModifierResolver.flatModifierTotal(
          unit,
          BattleModifierType.regen,
        );
    if (!unit.isAlive || regenRate <= 0) {
      return 0;
    }
    final int previousHp = unit.currentHp;
    final int healing = max(1, (unit.maxHp * regenRate).round());
    unit.currentHp = min(unit.maxHp, unit.currentHp + healing);
    return unit.currentHp - previousHp;
  }
}
