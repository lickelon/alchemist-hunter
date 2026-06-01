part of 'battle_service.dart';

extension _BattleStatusSkillEffect on _BattleSkillEffectMixin {
  List<BattleActionLog> _applySkillStatus({
    required _ActionLifecycleContext context,
    required BattleSkillDefinition skill,
    required List<_BattleUnit> targets,
    required int mpSpent,
  }) {
    if (skill.statusType == null) {
      return const <BattleActionLog>[];
    }
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final _BattleUnit target in targets) {
      target.statuses = <BattleStatusEffect>[
        ...target.statuses,
        BattleStatusEffect(
          type: skill.statusType!,
          sourceId: skill.id,
          remainingLifecycles: max(1, skill.durationLifecycles),
          power: skill.flatPower,
        ),
      ];
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.turn,
          type: BattleActionType.status,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          skillId: skill.id,
          skillName: skill.name,
          statusType: skill.statusType,
          mpSpent: mpSpent,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: target.currentHp,
          message: 'status:${skill.statusType!.name}:${skill.id}',
        ),
      );
    }
    return actions;
  }
}
