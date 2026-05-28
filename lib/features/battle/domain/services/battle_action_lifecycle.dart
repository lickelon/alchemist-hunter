part of 'battle_service.dart';

mixin _BattleActionLifecycleMixin
    on
        _BattleEncounterUnitMapperMixin,
        _BattleSkillEffectMixin,
        _BattleActionSelectionMixin,
        _BattleActionFollowupMixin {
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
      actions.add(
        BattleActionLog(
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
        ),
      );
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
    List<_DerivedActionRequest> onDamagedRequests =
        const <_DerivedActionRequest>[];
    if (usesSkill) {
      context.actor.currentMp = 0;
      context.actor.skillCooldowns = _startSkillCooldowns(context.actor, skill);
      actions.add(
        _buildSkillUseAction(context: context, skill: skill, mpSpent: mpSpent),
      );
    } else {
      context.actor.skillCooldowns = _tickSkillCooldowns(context.actor);
    }

    int totalDamage = 0;
    final _BattleUnit recoveryTarget = targets.first;
    if (skill?.effectType == BattleSkillEffectType.heal) {
      actions.addAll(
        _applyHealSkill(
          context: context,
          skill: skill!,
          targets: targets,
          mpSpent: 0,
        ),
      );
    } else if (skill?.effectType == BattleSkillEffectType.grantModifier) {
      actions.addAll(
        _applySkillModifier(
          context: context,
          skill: skill!,
          targets: targets,
          mpSpent: 0,
        ),
      );
    } else if (skill?.effectType == BattleSkillEffectType.grantStatus) {
      actions.addAll(
        _applySkillStatus(
          context: context,
          skill: skill!,
          targets: targets,
          mpSpent: 0,
        ),
      );
    } else if (skill?.effectType == BattleSkillEffectType.grantShield) {
      actions.addAll(
        _applySkillShield(
          context: context,
          skill: skill!,
          targets: targets,
          mpSpent: 0,
        ),
      );
    } else {
      for (final _BattleUnit target in targets) {
        _applyBeforeHitCheckHooks(context, target);
        final bool hit = _resolveHitCheck(context, target);
        if (!hit) {
          actions.add(
            BattleActionLog(
              lifecycle: context.lifecycle,
              turn: context.turn,
              type: usesSkill
                  ? BattleActionType.skill
                  : BattleActionType.attack,
              actorId: context.actor.id,
              actorName: context.actor.name,
              actorTeam: _toBattleTeam(context.actor.side),
              targetId: target.id,
              targetName: target.name,
              targetTeam: _toBattleTeam(target.side),
              skillId: skill?.id,
              skillName: skill?.name,
              hit: false,
              mpSpent: 0,
              actorHpAfter: context.actor.currentHp,
              actorMpAfter: context.actor.currentMp,
              targetHpAfter: target.currentHp,
            ),
          );
          continue;
        }
        actions.addAll(_applyBeforeDamageHooks(context, target));
        final bool critical = _BattleAttackResolver(random: _random)
            .rollCritical(
              attacker: context.actor,
              defender: target,
              potionBoost: context.potionBoost,
            );
        final _DamageRoll damageRoll = _resolveActionEffect(
          context: context,
          target: target,
          critical: critical,
          skill: skill,
        );
        final int damage = _applyActionEffect(
          target: target,
          damageRoll: damageRoll,
        );
        totalDamage += damage;
        final int actorHpBeforeRecovery = context.actor.currentHp;
        actions.add(
          BattleActionLog(
            lifecycle: context.lifecycle,
            turn: context.turn,
            type: usesSkill ? BattleActionType.skill : BattleActionType.attack,
            actorId: context.actor.id,
            actorName: context.actor.name,
            actorTeam: _toBattleTeam(context.actor.side),
            targetId: target.id,
            targetName: target.name,
            targetTeam: _toBattleTeam(target.side),
            skillId: skill?.id,
            skillName: skill?.name,
            school: damageRoll.school,
            hit: true,
            critical: critical,
            damage: damage,
            mpSpent: 0,
            actorHpAfter: actorHpBeforeRecovery,
            actorMpAfter: context.actor.currentMp,
            targetHpAfter: target.currentHp,
            targetShieldAfter: target.shield,
          ),
        );
        actions.addAll(
          _applyAfterHitHooks(context, target, critical: critical),
        );
        onDamagedRequests = <_DerivedActionRequest>[
          ...onDamagedRequests,
          ..._applyOnDamagedHooks(context, target, damage: damage),
        ];
      }
    }

    if (skill?.effectType == BattleSkillEffectType.damage || skill == null) {
      actions.addAll(
        _applyPostActionRecovery(
          context: context,
          target: recoveryTarget,
          damage: totalDamage,
          usesSkill: usesSkill,
        ),
      );
    } else {
      actions.addAll(
        _applyPostActionRecovery(
          context: context,
          target: recoveryTarget,
          damage: 0,
          usesSkill: usesSkill,
        ),
      );
    }

    final List<_DerivedActionRequest> derivedRequests = <_DerivedActionRequest>[
      ...onDamagedRequests,
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
