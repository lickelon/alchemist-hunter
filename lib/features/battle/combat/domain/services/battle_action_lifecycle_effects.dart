part of 'battle_service.dart';

extension _BattleActionLifecycleEffects on _BattleActionLifecycleMixin {
  _PrimaryActionEffectResult _applyPrimaryActionEffects({
    required _ActionLifecycleContext context,
    required List<_BattleUnit> targets,
    required BattleSkillDefinition? skill,
    required bool usesSkill,
  }) {
    final _BattleUnit recoveryTarget = targets.first;
    final _PrimaryActionEffectResult? skillEffect = _applyNonDamageSkillEffects(
      context: context,
      targets: targets,
      skill: skill,
      recoveryTarget: recoveryTarget,
    );
    if (skillEffect != null) {
      return skillEffect;
    }
    return _applyDamageActionEffects(
      context: context,
      targets: targets,
      skill: skill,
      usesSkill: usesSkill,
      recoveryTarget: recoveryTarget,
    );
  }

  _PrimaryActionEffectResult _applyDamageActionEffects({
    required _ActionLifecycleContext context,
    required List<_BattleUnit> targets,
    required BattleSkillDefinition? skill,
    required bool usesSkill,
    required _BattleUnit recoveryTarget,
  }) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    List<_DerivedActionRequest> onDamagedRequests =
        const <_DerivedActionRequest>[];
    int totalDamage = 0;

    for (final _BattleUnit target in targets) {
      _applyBeforeHitCheckHooks(context, target);
      final bool hit = _resolveHitCheck(context, target);
      if (!hit) {
        actions.add(_buildMissAction(context, target, skill, usesSkill));
        continue;
      }

      actions.addAll(_applyBeforeDamageHooks(context, target));
      final bool critical = _BattleAttackResolver(random: _random).rollCritical(
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
      actions.add(
        _buildDamageAction(
          context: context,
          target: target,
          skill: skill,
          usesSkill: usesSkill,
          damageRoll: damageRoll,
          critical: critical,
          damage: damage,
        ),
      );
      actions.addAll(_applyAfterHitHooks(context, target, critical: critical));
      onDamagedRequests = <_DerivedActionRequest>[
        ...onDamagedRequests,
        ..._applyOnDamagedHooks(context, target, damage: damage),
      ];
    }

    return _PrimaryActionEffectResult(
      actions: actions,
      onDamagedRequests: onDamagedRequests,
      totalDamage: totalDamage,
      recoveryTarget: recoveryTarget,
    );
  }

  BattleActionLog _buildMissAction(
    _ActionLifecycleContext context,
    _BattleUnit target,
    BattleSkillDefinition? skill,
    bool usesSkill,
  ) {
    return BattleActionLog(
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
      hit: false,
      mpSpent: 0,
      actorHpAfter: context.actor.currentHp,
      actorMpAfter: context.actor.currentMp,
      targetHpAfter: target.currentHp,
    );
  }

  BattleActionLog _buildDamageAction({
    required _ActionLifecycleContext context,
    required _BattleUnit target,
    required BattleSkillDefinition? skill,
    required bool usesSkill,
    required _DamageRoll damageRoll,
    required bool critical,
    required int damage,
  }) {
    return BattleActionLog(
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
      actorHpAfter: context.actor.currentHp,
      actorMpAfter: context.actor.currentMp,
      targetHpAfter: target.currentHp,
      targetShieldAfter: target.shield,
    );
  }
}
