part of 'battle_service.dart';

mixin _BattleActionLifecycleMixin
    on
        _BattleEncounterUnitMapperMixin,
        _BattleSkillEffectMixin,
        _BattleActionTargetSelectionMixin,
        _BattleActionSelectionMixin,
        _BattleActionFollowupMixin,
        _BattleActionRecoveryHookMixin,
        _BattleActionTurnEndHookMixin {
  @override
  Random get _random;

  _ActionLifecycleResult _runActionLifecycle({
    required Map<String, _BattleUnit> units,
    required _BattleUnit actor,
    required int actionTurn,
    required int startLifecycle,
    required int maxLifecycle,
    required int potionBoost,
    required bool allowExtraAttack,
    required bool allowCounterAttack,
  }) {
    if (startLifecycle > maxLifecycle) {
      return _buildActionLifecycleResult(
        actions: const <BattleActionLog>[],
        nextLifecycle: startLifecycle,
      );
    }
    final _ActionLifecycleContext? context = _prepareActionContext(
      actor: actor,
      turn: actionTurn,
      lifecycle: startLifecycle,
      potionBoost: potionBoost,
      allowExtraAttack: allowExtraAttack,
      allowCounterAttack: allowCounterAttack,
    );
    if (context == null) {
      return _buildActionLifecycleResult(
        actions: const <BattleActionLog>[],
        nextLifecycle: startLifecycle,
      );
    }

    final List<BattleActionLog> actions = <BattleActionLog>[
      ..._applyBeforeActionHooks(context),
    ];
    if (_isActionBlockedByStatus(context)) {
      actions.add(_buildStunBlockedAction(context));
      actions.addAll(_applyTurnEndHooks(context));
      return _buildActionLifecycleResult(
        actions: actions,
        nextLifecycle: context.lifecycle + 1,
      );
    }
    final BattleSkillDefinition? skill = _selectBaseAction(context.actor);
    final List<_BattleUnit> targets = _selectActionTargets(
      context.actor,
      units,
      skill,
    );
    if (targets.isEmpty) {
      return _buildActionLifecycleResult(
        actions: const <BattleActionLog>[],
        nextLifecycle: startLifecycle,
      );
    }

    final bool usesSkill = skill != null;
    final int mpSpent = usesSkill ? context.actor.currentMp : 0;
    if (usesSkill) {
      context.actor.currentMp = 0;
      context.actor.skillCooldowns = _startSkillCooldowns(context.actor, skill);
      actions.add(
        _buildSkillUseAction(context: context, skill: skill, mpSpent: mpSpent),
      );
    } else {
      context.actor.skillCooldowns = _tickSkillCooldowns(context.actor);
    }

    final _PrimaryActionEffectResult primaryResult = _applyPrimaryActionEffects(
      context: context,
      targets: targets,
      skill: skill,
      usesSkill: usesSkill,
    );
    actions.addAll(primaryResult.actions);

    if (skill?.effectType == BattleSkillEffectType.damage || skill == null) {
      actions.addAll(
        _applyPostActionRecovery(
          context: context,
          target: primaryResult.recoveryTarget,
          damage: primaryResult.totalDamage,
          usesSkill: usesSkill,
        ),
      );
    } else {
      actions.addAll(
        _applyPostActionRecovery(
          context: context,
          target: primaryResult.recoveryTarget,
          damage: 0,
          usesSkill: usesSkill,
        ),
      );
    }

    final List<_DerivedActionRequest> derivedRequests = <_DerivedActionRequest>[
      ...primaryResult.onDamagedRequests,
      ..._applyAfterActionHooks(
        context,
        encounterEnded: _encounterEnded(units),
      ),
    ];
    final _ActionLifecycleResult derivedResult =
        _resolveDerivedActionLifecycles(
          units: units,
          requests: derivedRequests,
          actionTurn: context.turn,
          startLifecycle: context.lifecycle + 1,
          maxLifecycle: maxLifecycle,
          potionBoost: potionBoost,
        );
    actions.addAll(derivedResult.actions);
    actions.addAll(_applyTurnEndHooks(context));
    return _buildActionLifecycleResult(
      actions: actions,
      nextLifecycle: derivedResult.nextLifecycle,
    );
  }
}
