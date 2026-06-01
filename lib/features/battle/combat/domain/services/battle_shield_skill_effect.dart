part of 'battle_service.dart';

extension _BattleShieldSkillEffect on _BattleSkillEffectMixin {
  List<BattleActionLog> _applySkillShield({
    required _ActionLifecycleContext context,
    required BattleSkillDefinition skill,
    required List<_BattleUnit> targets,
    required int mpSpent,
  }) {
    final int shield = max(skill.shieldValue, skill.flatPower);
    if (shield <= 0) {
      return const <BattleActionLog>[];
    }
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final _BattleUnit target in targets) {
      target.shield += shield;
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.turn,
          type: BattleActionType.shield,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          skillId: skill.id,
          skillName: skill.name,
          healing: shield,
          mpSpent: mpSpent,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: target.currentHp,
          targetShieldAfter: target.shield,
          message: 'shield:${skill.id}',
        ),
      );
    }
    return actions;
  }
}
