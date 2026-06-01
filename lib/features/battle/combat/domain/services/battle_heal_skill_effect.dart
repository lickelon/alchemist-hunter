part of 'battle_service.dart';

extension _BattleHealSkillEffect on _BattleSkillEffectMixin {
  List<BattleActionLog> _applyHealSkill({
    required _ActionLifecycleContext context,
    required BattleSkillDefinition skill,
    required List<_BattleUnit> targets,
    required int mpSpent,
  }) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final _BattleUnit target in targets) {
      final int healing = _resolveHealing(context.actor, skill);
      final int previousHp = target.currentHp;
      target.currentHp = min(target.maxHp, target.currentHp + healing);
      final int appliedHealing = target.currentHp - previousHp;
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.turn,
          type: BattleActionType.heal,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          skillId: skill.id,
          skillName: skill.name,
          healing: appliedHealing,
          mpSpent: mpSpent,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: target.currentHp,
        ),
      );
    }
    return actions;
  }

  int _resolveHealing(_BattleUnit actor, BattleSkillDefinition skill) {
    final double baseHealing =
        (actor.stats.magicalAttack * skill.powerMultiplier) + skill.flatPower;
    return max(1, (baseHealing * (1 + actor.stats.healingPower)).round());
  }
}
