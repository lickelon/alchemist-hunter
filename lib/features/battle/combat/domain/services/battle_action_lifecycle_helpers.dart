part of 'battle_service.dart';

extension _BattleActionLifecycleHelpers on _BattleActionLifecycleMixin {
  _ActionLifecycleContext? _prepareActionContext({
    required _BattleUnit actor,
    required int turn,
    required int lifecycle,
    required int potionBoost,
    required bool allowExtraAttack,
    required bool allowCounterAttack,
  }) {
    if (!actor.isAlive) {
      return null;
    }
    return _ActionLifecycleContext(
      actor: actor,
      turn: turn,
      lifecycle: lifecycle,
      potionBoost: actor.side == _BattleSide.ally ? potionBoost : 0,
      allowExtraAttack: allowExtraAttack,
      allowCounterAttack: allowCounterAttack,
    );
  }

  BattleActionLog _buildStunBlockedAction(_ActionLifecycleContext context) {
    return BattleActionLog(
      lifecycle: context.lifecycle,
      turn: context.turn,
      type: BattleActionType.status,
      actorId: context.actor.id,
      actorName: context.actor.name,
      actorTeam: _toBattleTeam(context.actor.side),
      statusType: BattleStatusType.stun,
      actorHpAfter: context.actor.currentHp,
      actorMpAfter: context.actor.currentMp,
      message: 'status:stun',
    );
  }

  BattleActionLog _buildSkillUseAction({
    required _ActionLifecycleContext context,
    required BattleSkillDefinition skill,
    required int mpSpent,
  }) {
    return BattleActionLog(
      lifecycle: context.lifecycle,
      turn: context.turn,
      type: BattleActionType.skillUse,
      actorId: context.actor.id,
      actorName: context.actor.name,
      actorTeam: _toBattleTeam(context.actor.side),
      skillId: skill.id,
      skillName: skill.name,
      mpSpent: mpSpent,
      actorHpAfter: context.actor.currentHp,
      actorMpAfter: context.actor.currentMp,
    );
  }

  _ActionLifecycleResult _resolveDerivedActionLifecycles({
    required Map<String, _BattleUnit> units,
    required List<_DerivedActionRequest> requests,
    required int actionTurn,
    required int startLifecycle,
    required int maxLifecycle,
    required int potionBoost,
  }) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    int nextLifecycle = startLifecycle;
    for (final _DerivedActionRequest request in requests) {
      if (nextLifecycle > maxLifecycle) {
        break;
      }
      if (_encounterEnded(units) || !request.actor.isAlive) {
        break;
      }
      final _ActionLifecycleResult result = _runActionLifecycle(
        units: units,
        actor: request.actor,
        actionTurn: actionTurn,
        startLifecycle: nextLifecycle,
        maxLifecycle: maxLifecycle,
        potionBoost: potionBoost,
        allowExtraAttack: false,
        allowCounterAttack: true,
      );
      actions.addAll(result.actions);
      nextLifecycle = result.nextLifecycle;
    }
    return _buildActionLifecycleResult(
      actions: actions,
      nextLifecycle: nextLifecycle,
    );
  }
}
