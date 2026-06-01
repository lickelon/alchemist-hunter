part of 'battle_service.dart';

mixin _BattlePassiveConditionMixin {
  bool _passiveConditionMatches(
    BattlePassiveEffect passive, {
    required _BattleUnit actor,
    required _BattleUnit target,
    required bool critical,
  }) {
    final BattlePassiveCondition condition = passive.condition;
    return switch (condition.type) {
      BattlePassiveConditionType.always => true,
      BattlePassiveConditionType.actorHpBelow =>
        actor.currentHp / max(actor.maxHp, 1) <= condition.threshold,
      BattlePassiveConditionType.actorHpAbove =>
        actor.currentHp / max(actor.maxHp, 1) >= condition.threshold,
      BattlePassiveConditionType.targetFaction =>
        condition.faction == null || target.faction == condition.faction,
      BattlePassiveConditionType.targetHasStatus =>
        condition.statusType == null ||
            target.statuses.any(
              (BattleStatusEffect status) =>
                  status.type == condition.statusType,
            ),
      BattlePassiveConditionType.criticalHit => critical,
    };
  }
}
