import 'dart:math';

import 'package:alchemist_hunter/features/battle/domain/models.dart';

part 'battle_loop_runner.dart';
part 'battle_attack_resolver.dart';
part 'battle_modifier_resolver.dart';
part 'battle_recovery_resolver.dart';
part 'battle_reward_resolver.dart';
part 'battle_unit.dart';

class BattleService {
  BattleService({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<BattleRunUnitState> createRunAllies({required List<HeroProfile> party}) {
    return party
        .map(
          (HeroProfile profile) => BattleRunUnitState(
            unitId: profile.id,
            name: profile.name,
            team: BattleTeam.ally,
            faction: profile.faction,
            stats: profile.stats,
            modifiers: profile.modifiers,
            passives: profile.passives,
            skills: profile.skills,
            currentHp: profile.stats.maxHp,
            currentMp: 0,
          ),
        )
        .toList(growable: false);
  }

  List<BattleRunUnitState> resetRunAllies({required List<HeroProfile> party}) {
    return createRunAllies(party: party);
  }

  List<BattleRunUnitState> createEncounterEnemies({
    required List<BattleEnemyDefinition> enemies,
  }) {
    return enemies
        .map(
          (BattleEnemyDefinition enemy) => BattleRunUnitState(
            unitId: enemy.id,
            name: enemy.name,
            team: BattleTeam.enemy,
            faction: enemy.faction,
            stats: enemy.stats,
            modifiers: enemy.modifiers,
            passives: enemy.passives,
            skills: enemy.skills,
            currentHp: enemy.stats.maxHp,
            currentMp: 0,
          ),
        )
        .toList(growable: false);
  }

  List<BattleRunUnitState> applySearchRecovery(
    List<BattleRunUnitState> allies,
  ) {
    return allies
        .map((BattleRunUnitState unit) {
          if (!unit.isAlive) {
            return unit;
          }
          final int healing = max(
            1,
            (unit.maxHp * (0.08 + unit.stats.regen)).ceil(),
          );
          final int nextHp = min(unit.maxHp, unit.currentHp + healing);
          return unit.copyWith(currentHp: nextHp);
        })
        .toList(growable: false);
  }

  BattleEncounterStepResult runEncounterStep({
    required List<BattleRunUnitState> allies,
    required BattleEncounterRuntimeState encounter,
    required int potionBoost,
  }) {
    final Map<String, _BattleUnit> units = <String, _BattleUnit>{
      for (final BattleRunUnitState ally in allies) ally.unitId: _toUnit(ally),
      for (final BattleRunUnitState enemy in encounter.enemies)
        enemy.unitId: _toUnit(enemy),
    };
    List<String> pendingActorIds = encounter.pendingActorIds
        .where((String unitId) => units[unitId]?.isAlive ?? false)
        .toList(growable: true);
    if (pendingActorIds.isEmpty) {
      pendingActorIds = List<String>.of(
        _buildTurnOrder(units, firstTurn: encounter.turnInEncounter == 0),
        growable: true,
      );
    }
    if (pendingActorIds.isEmpty) {
      return BattleEncounterStepResult(
        allies: allies,
        encounter: encounter,
        ended: true,
        success: encounter.enemies.every(
          (BattleRunUnitState unit) => !unit.isAlive,
        ),
        wiped: allies.every((BattleRunUnitState unit) => !unit.isAlive),
      );
    }

    final String actorId = pendingActorIds.removeAt(0);
    final _BattleUnit? actor = units[actorId];
    if (actor == null || !actor.isAlive) {
      return BattleEncounterStepResult(
        allies: _extractUnits(units, BattleTeam.ally),
        encounter: encounter.copyWith(
          enemies: _extractUnits(units, BattleTeam.enemy),
          pendingActorIds: pendingActorIds,
        ),
        ended: false,
      );
    }

    final List<_BattleUnit> targets = actor.side == _BattleSide.ally
        ? _livingUnits(units, _BattleSide.enemy)
        : _livingUnits(units, _BattleSide.ally);
    if (targets.isEmpty) {
      return BattleEncounterStepResult(
        allies: _extractUnits(units, BattleTeam.ally),
        encounter: encounter.copyWith(
          enemies: _extractUnits(units, BattleTeam.enemy),
          pendingActorIds: pendingActorIds,
        ),
        ended: true,
        success: actor.side == _BattleSide.ally,
        wiped: actor.side == _BattleSide.enemy,
      );
    }

    final _ActionLifecycleResult lifecycleResult = _runActionLifecycle(
      units: units,
      actor: actor,
      startLifecycle: encounter.turnInEncounter + 1,
      potionBoost: potionBoost,
      allowDerivedActions: true,
    );
    final List<BattleActionLog> actions = lifecycleResult.actions;
    final bool success = _livingUnits(units, _BattleSide.enemy).isEmpty;
    final bool wiped = _livingUnits(units, _BattleSide.ally).isEmpty;

    return BattleEncounterStepResult(
      allies: _extractUnits(units, BattleTeam.ally),
      encounter: encounter.copyWith(
        enemies: _extractUnits(units, BattleTeam.enemy),
        pendingActorIds: pendingActorIds,
        recentActionLogs: <BattleActionLog>[
          ...encounter.recentActionLogs,
          ...actions,
        ],
        turnInEncounter: max(
          encounter.turnInEncounter,
          lifecycleResult.nextLifecycle - 1,
        ),
      ),
      ended: success || wiped,
      success: success,
      wiped: wiped,
      lifecycleActions: actions,
    );
  }

  _ActionLifecycleResult _runActionLifecycle({
    required Map<String, _BattleUnit> units,
    required _BattleUnit actor,
    required int startLifecycle,
    required int potionBoost,
    required bool allowDerivedActions,
  }) {
    final _ActionLifecycleContext? context = _prepareActionContext(
      actor: actor,
      lifecycle: startLifecycle,
      potionBoost: potionBoost,
      allowDerivedActions: allowDerivedActions,
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
          turn: context.lifecycle,
          type: BattleActionType.status,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
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
          mpSpent: mpSpent,
        ),
      );
    } else if (skill?.effectType == BattleSkillEffectType.grantModifier) {
      actions.addAll(
        _applySkillModifier(
          context: context,
          skill: skill!,
          targets: targets,
          mpSpent: mpSpent,
        ),
      );
    } else if (skill?.effectType == BattleSkillEffectType.grantStatus) {
      actions.addAll(
        _applySkillStatus(
          context: context,
          skill: skill!,
          targets: targets,
          mpSpent: mpSpent,
        ),
      );
    } else if (skill?.effectType == BattleSkillEffectType.grantShield) {
      actions.addAll(
        _applySkillShield(
          context: context,
          skill: skill!,
          targets: targets,
          mpSpent: mpSpent,
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
              turn: context.lifecycle,
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
              mpSpent: mpSpent,
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
            turn: context.lifecycle,
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
            mpSpent: mpSpent,
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
          startLifecycle: context.lifecycle + 1,
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
    required int lifecycle,
    required int potionBoost,
    required bool allowDerivedActions,
  }) {
    if (!actor.isAlive) {
      return null;
    }
    return _ActionLifecycleContext(
      actor: actor,
      lifecycle: lifecycle,
      potionBoost: actor.side == _BattleSide.ally ? potionBoost : 0,
      allowDerivedActions: allowDerivedActions,
    );
  }

  List<BattleActionLog> _applyBeforeActionHooks(
    _ActionLifecycleContext context,
  ) {
    return <BattleActionLog>[
      ..._applyGrantModifierPassives(
        trigger: BattlePassiveTrigger.beforeAction,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
      ..._applyGrantStatusPassives(
        trigger: BattlePassiveTrigger.beforeAction,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
      ..._applyGrantShieldPassives(
        trigger: BattlePassiveTrigger.beforeAction,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
    ];
  }

  BattleSkillDefinition? _selectBaseAction(_BattleUnit actor) {
    if (!actor.isAlive || actor.maxMp <= 0 || actor.currentMp < actor.maxMp) {
      return null;
    }
    final List<BattleSkillDefinition> available = actor.skills
        .where(
          (BattleSkillDefinition skill) =>
              _isSupportedActiveSkill(skill) &&
              (actor.skillCooldowns[skill.id] ?? 0) <= 0,
        )
        .toList(growable: false);
    if (available.isEmpty) {
      return null;
    }
    return available.reduce(
      (BattleSkillDefinition left, BattleSkillDefinition right) =>
          right.priority > left.priority ? right : left,
    );
  }

  List<_BattleUnit> _selectActionTargets(
    _BattleUnit actor,
    Map<String, _BattleUnit> units,
    BattleSkillDefinition? skill,
  ) {
    final List<_BattleUnit> enemies = actor.side == _BattleSide.ally
        ? _livingUnits(units, _BattleSide.enemy)
        : _livingUnits(units, _BattleSide.ally);
    final List<_BattleUnit> allies = actor.side == _BattleSide.ally
        ? _livingUnits(units, _BattleSide.ally)
        : _livingUnits(units, _BattleSide.enemy);
    if (skill == null) {
      if (enemies.isEmpty) {
        return const <_BattleUnit>[];
      }
      return <_BattleUnit>[enemies[_random.nextInt(enemies.length)]];
    }
    return switch (skill.targetType) {
      BattleSkillTargetType.randomEnemy =>
        enemies.isEmpty
            ? const <_BattleUnit>[]
            : <_BattleUnit>[enemies[_random.nextInt(enemies.length)]],
      BattleSkillTargetType.self => <_BattleUnit>[actor],
      BattleSkillTargetType.randomAlly =>
        allies.isEmpty
            ? const <_BattleUnit>[]
            : <_BattleUnit>[allies[_random.nextInt(allies.length)]],
      BattleSkillTargetType.allEnemies => enemies,
      BattleSkillTargetType.allAllies => allies,
    };
  }

  void _applyBeforeHitCheckHooks(
    _ActionLifecycleContext context,
    _BattleUnit target,
  ) {}

  bool _resolveHitCheck(_ActionLifecycleContext context, _BattleUnit target) {
    return _BattleAttackResolver(random: _random).rollHit(
      attacker: context.actor,
      defender: target,
      potionBoost: context.potionBoost,
    );
  }

  List<BattleActionLog> _applyBeforeDamageHooks(
    _ActionLifecycleContext context,
    _BattleUnit target,
  ) {
    return _applyGrantModifierPassives(
      trigger: BattlePassiveTrigger.beforeDamage,
      context: context,
      target: target,
      recipient: context.actor,
      critical: false,
    );
  }

  _DamageRoll _resolveActionEffect({
    required _ActionLifecycleContext context,
    required _BattleUnit target,
    required bool critical,
    BattleSkillDefinition? skill,
  }) {
    return _BattleAttackResolver(random: _random).rollDamage(
      attacker: context.actor,
      defender: target,
      critical: critical,
      potionBoost: context.potionBoost,
      skill: skill,
    );
  }

  int _applyActionEffect({
    required _BattleUnit target,
    required _DamageRoll damageRoll,
  }) {
    final int blocked = min(target.shield, damageRoll.damage);
    target.shield -= blocked;
    final int hpDamage = damageRoll.damage - blocked;
    target.currentHp = max(0, target.currentHp - hpDamage);
    return hpDamage;
  }

  List<BattleActionLog> _applyAfterHitHooks(
    _ActionLifecycleContext context,
    _BattleUnit target, {
    required bool critical,
  }) {
    return <BattleActionLog>[
      ..._applyGrantModifierPassives(
        trigger: BattlePassiveTrigger.afterHit,
        context: context,
        target: target,
        recipient: target,
        critical: critical,
      ),
      ..._applyGrantStatusPassives(
        trigger: BattlePassiveTrigger.afterHit,
        context: context,
        target: target,
        recipient: target,
        critical: critical,
      ),
      ..._applyGrantShieldPassives(
        trigger: BattlePassiveTrigger.afterHit,
        context: context,
        target: target,
        recipient: context.actor,
        critical: critical,
      ),
    ];
  }

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
          turn: context.lifecycle,
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

  List<BattleActionLog> _applySkillModifier({
    required _ActionLifecycleContext context,
    required BattleSkillDefinition skill,
    required List<_BattleUnit> targets,
    required int mpSpent,
  }) {
    if (skill.modifier == null) {
      return const <BattleActionLog>[];
    }
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final _BattleUnit target in targets) {
      target.activeModifiers = <BattleTimedModifier>[
        ...target.activeModifiers,
        BattleTimedModifier(
          modifier: skill.modifier!,
          remainingLifecycles: max(1, skill.durationLifecycles),
        ),
      ];
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.lifecycle,
          type: BattleActionType.modifier,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          skillId: skill.id,
          skillName: skill.name,
          mpSpent: mpSpent,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: target.currentHp,
          message: 'modifier:${skill.id}',
        ),
      );
    }
    return actions;
  }

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
          turn: context.lifecycle,
          type: BattleActionType.status,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          skillId: skill.id,
          skillName: skill.name,
          mpSpent: mpSpent,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: target.currentHp,
          message: 'status:${skill.id}',
        ),
      );
    }
    return actions;
  }

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
          turn: context.lifecycle,
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

  int _resolveHealing(_BattleUnit actor, BattleSkillDefinition skill) {
    final double baseHealing =
        (actor.stats.magicalAttack * skill.powerMultiplier) + skill.flatPower;
    return max(1, (baseHealing * (1 + actor.stats.healingPower)).round());
  }

  List<_DerivedActionRequest> _applyOnDamagedHooks(
    _ActionLifecycleContext context,
    _BattleUnit target, {
    required int damage,
  }) {
    if (!context.allowDerivedActions || damage <= 0 || !target.isAlive) {
      return const <_DerivedActionRequest>[];
    }
    final int counterAttackCount = _BattleModifierResolver.counterAttackCount(
      target,
    );
    if (counterAttackCount <= 0) {
      return const <_DerivedActionRequest>[];
    }
    return List<_DerivedActionRequest>.filled(
      counterAttackCount,
      _DerivedActionRequest(actor: target),
    );
  }

  List<BattleActionLog> _applyPostActionRecovery({
    required _ActionLifecycleContext context,
    required _BattleUnit target,
    required int damage,
    required bool usesSkill,
  }) {
    const _BattleRecoveryResolver recoveryResolver = _BattleRecoveryResolver();
    final List<BattleActionLog> actions = <BattleActionLog>[];
    final int lifestealHealing = recoveryResolver.applyLifesteal(
      actor: context.actor,
      damage: damage,
    );
    if (lifestealHealing > 0) {
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.lifecycle,
          type: BattleActionType.lifesteal,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          healing: lifestealHealing,
          actorHpAfter: context.actor.currentHp,
          targetHpAfter: target.currentHp,
        ),
      );
    }

    final int regenHealing = recoveryResolver.applyRegen(context.actor);
    if (regenHealing > 0) {
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.lifecycle,
          type: BattleActionType.regen,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          healing: regenHealing,
          actorHpAfter: context.actor.currentHp,
        ),
      );
    }
    final int mpRegen = usesSkill
        ? 0
        : recoveryResolver.applyMpRegen(context.actor);
    if (mpRegen > 0) {
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.lifecycle,
          type: BattleActionType.mpRegen,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          healing: mpRegen,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
        ),
      );
    }
    return actions;
  }

  List<_DerivedActionRequest> _applyAfterActionHooks(
    _ActionLifecycleContext context, {
    required bool encounterEnded,
  }) {
    if (!context.allowDerivedActions ||
        encounterEnded ||
        !context.actor.isAlive) {
      return const <_DerivedActionRequest>[];
    }
    final int extraAttackCount = _BattleModifierResolver.extraAttackCount(
      context.actor,
    );
    if (extraAttackCount <= 0) {
      return const <_DerivedActionRequest>[];
    }
    return List<_DerivedActionRequest>.filled(
      extraAttackCount,
      _DerivedActionRequest(actor: context.actor),
    );
  }

  _ActionLifecycleResult _resolveDerivedActionLifecycles({
    required Map<String, _BattleUnit> units,
    required List<_DerivedActionRequest> requests,
    required int startLifecycle,
    required int potionBoost,
  }) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    int nextLifecycle = startLifecycle;
    for (final _DerivedActionRequest request in requests) {
      if (_encounterEnded(units) || !request.actor.isAlive) {
        break;
      }
      final _ActionLifecycleResult result = _runActionLifecycle(
        units: units,
        actor: request.actor,
        startLifecycle: nextLifecycle,
        potionBoost: potionBoost,
        allowDerivedActions: false,
      );
      actions.addAll(result.actions);
      nextLifecycle = result.nextLifecycle;
    }
    return _buildActionLifecycleResult(
      actions: actions,
      nextLifecycle: nextLifecycle,
    );
  }

  List<BattleActionLog> _applyTurnEndHooks(_ActionLifecycleContext context) {
    final List<BattleActionLog> actions = <BattleActionLog>[
      ..._applyStatusTurnEndEffects(context),
    ];
    context.actor.activeModifiers = context.actor.activeModifiers
        .map(
          (BattleTimedModifier modifier) => modifier.copyWith(
            remainingLifecycles: modifier.remainingLifecycles - 1,
          ),
        )
        .where(
          (BattleTimedModifier modifier) => modifier.remainingLifecycles > 0,
        )
        .toList(growable: false);
    context.actor.statuses = context.actor.statuses
        .map(
          (BattleStatusEffect status) => status.copyWith(
            remainingLifecycles: status.remainingLifecycles - 1,
          ),
        )
        .where((BattleStatusEffect status) => status.remainingLifecycles > 0)
        .toList(growable: false);
    actions.addAll(
      _applyGrantModifierPassives(
        trigger: BattlePassiveTrigger.turnEnd,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
    );
    actions.addAll(
      _applyGrantStatusPassives(
        trigger: BattlePassiveTrigger.turnEnd,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
    );
    actions.addAll(
      _applyGrantShieldPassives(
        trigger: BattlePassiveTrigger.turnEnd,
        context: context,
        target: context.actor,
        recipient: context.actor,
        critical: false,
      ),
    );
    return actions;
  }

  bool _isActionBlockedByStatus(_ActionLifecycleContext context) {
    return context.actor.statuses.any(
      (BattleStatusEffect status) => status.type == BattleStatusType.stun,
    );
  }

  List<BattleActionLog> _applyStatusTurnEndEffects(
    _ActionLifecycleContext context,
  ) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final BattleStatusEffect status in context.actor.statuses) {
      if (status.type != BattleStatusType.poison || status.power <= 0) {
        continue;
      }
      final int damage = min(context.actor.currentHp, status.power);
      context.actor.currentHp = max(0, context.actor.currentHp - damage);
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.lifecycle,
          type: BattleActionType.status,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          damage: damage,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          message: 'status:poison',
        ),
      );
    }
    return actions;
  }

  List<BattleActionLog> _applyGrantModifierPassives({
    required BattlePassiveTrigger trigger,
    required _ActionLifecycleContext context,
    required _BattleUnit target,
    required _BattleUnit recipient,
    required bool critical,
  }) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final BattlePassiveEffect passive in context.actor.passives) {
      if (passive.trigger != trigger ||
          passive.type != BattlePassiveEffectType.grantModifier ||
          passive.modifier == null ||
          !_passiveConditionMatches(
            passive,
            actor: context.actor,
            target: target,
            critical: critical,
          )) {
        continue;
      }
      recipient.activeModifiers = <BattleTimedModifier>[
        ...recipient.activeModifiers,
        BattleTimedModifier(
          modifier: passive.modifier!,
          remainingLifecycles: max(1, passive.durationLifecycles),
        ),
      ];
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.lifecycle,
          type: BattleActionType.modifier,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: recipient.id,
          targetName: recipient.name,
          targetTeam: _toBattleTeam(recipient.side),
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: recipient.currentHp,
          message: 'modifier:${passive.sourceId}',
        ),
      );
    }
    return actions;
  }

  List<BattleActionLog> _applyGrantStatusPassives({
    required BattlePassiveTrigger trigger,
    required _ActionLifecycleContext context,
    required _BattleUnit target,
    required _BattleUnit recipient,
    required bool critical,
  }) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final BattlePassiveEffect passive in context.actor.passives) {
      if (passive.trigger != trigger ||
          passive.type != BattlePassiveEffectType.grantStatus ||
          passive.statusType == null ||
          !_passiveConditionMatches(
            passive,
            actor: context.actor,
            target: target,
            critical: critical,
          )) {
        continue;
      }
      recipient.statuses = <BattleStatusEffect>[
        ...recipient.statuses,
        BattleStatusEffect(
          type: passive.statusType!,
          sourceId: passive.sourceId,
          remainingLifecycles: max(1, passive.durationLifecycles),
          power: passive.value ?? 0,
        ),
      ];
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.lifecycle,
          type: BattleActionType.status,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: recipient.id,
          targetName: recipient.name,
          targetTeam: _toBattleTeam(recipient.side),
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: recipient.currentHp,
          message: 'status:${passive.sourceId}',
        ),
      );
    }
    return actions;
  }

  List<BattleActionLog> _applyGrantShieldPassives({
    required BattlePassiveTrigger trigger,
    required _ActionLifecycleContext context,
    required _BattleUnit target,
    required _BattleUnit recipient,
    required bool critical,
  }) {
    final List<BattleActionLog> actions = <BattleActionLog>[];
    for (final BattlePassiveEffect passive in context.actor.passives) {
      if (passive.trigger != trigger ||
          passive.type != BattlePassiveEffectType.grantShield ||
          (passive.value ?? 0) <= 0 ||
          !_passiveConditionMatches(
            passive,
            actor: context.actor,
            target: target,
            critical: critical,
          )) {
        continue;
      }
      recipient.shield += passive.value ?? 0;
      actions.add(
        BattleActionLog(
          lifecycle: context.lifecycle,
          turn: context.lifecycle,
          type: BattleActionType.shield,
          actorId: context.actor.id,
          actorName: context.actor.name,
          actorTeam: _toBattleTeam(context.actor.side),
          targetId: recipient.id,
          targetName: recipient.name,
          targetTeam: _toBattleTeam(recipient.side),
          healing: passive.value ?? 0,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: recipient.currentHp,
          targetShieldAfter: recipient.shield,
          message: 'shield:${passive.sourceId}',
        ),
      );
    }
    return actions;
  }

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

  _ActionLifecycleResult _buildActionLifecycleResult({
    required List<BattleActionLog> actions,
    required int nextLifecycle,
  }) {
    return _ActionLifecycleResult(
      actions: actions,
      nextLifecycle: nextLifecycle,
    );
  }

  bool _encounterEnded(Map<String, _BattleUnit> units) {
    return _livingUnits(units, _BattleSide.enemy).isEmpty ||
        _livingUnits(units, _BattleSide.ally).isEmpty;
  }

  BattleEncounterOutcome runEncounterToCompletion({
    required List<BattleRunUnitState> allies,
    required BattleEncounterRuntimeState encounter,
    required int potionBoost,
  }) {
    List<BattleRunUnitState> nextAllies = allies;
    BattleEncounterRuntimeState nextEncounter = encounter;
    BattleEncounterStepResult step;
    do {
      step = runEncounterStep(
        allies: nextAllies,
        encounter: nextEncounter,
        potionBoost: potionBoost,
      );
      nextAllies = step.allies;
      nextEncounter = step.encounter;
    } while (!step.ended);
    return BattleEncounterOutcome(
      allies: nextAllies,
      encounter: nextEncounter,
      success: step.success,
      wiped: step.wiped,
    );
  }

  BattleResult runAutoBattle({
    required AutoBattleConfig config,
    required BattleStageDefinition stage,
    required List<BattleEnemyDefinition> enemies,
    required BattleDropTable dropTable,
  }) {
    final _BattleLoopResult loopResult = _BattleLoopRunner(
      random: _random,
    ).run(config: config, enemies: enemies);
    final Map<String, int> loot = resolveRewards(
      success: loopResult.success,
      table: dropTable,
    );
    return BattleResult(
      success: loopResult.success,
      turns: loopResult.turns,
      loot: loot,
      failurePenalty: 0,
      actions: loopResult.actions,
    );
  }

  Map<String, int> resolveRewards({
    required bool success,
    required BattleDropTable table,
  }) {
    return _BattleRewardResolver(
      random: _random,
    ).resolve(success: success, table: table);
  }

  _BattleUnit _toUnit(BattleRunUnitState unit) {
    return _BattleUnit(
      id: unit.unitId,
      name: unit.name,
      side: unit.team == BattleTeam.ally ? _BattleSide.ally : _BattleSide.enemy,
      faction: unit.faction,
      stats: unit.stats,
      baseModifiers: unit.modifiers,
      passives: unit.passives,
      skills: unit.skills,
      activeModifiers: List<BattleTimedModifier>.of(unit.activeModifiers),
      statuses: List<BattleStatusEffect>.of(unit.statuses),
      shield: unit.shield,
      currentHp: unit.currentHp,
      currentMp: unit.currentMp,
      skillCooldowns: unit.skillCooldowns,
    );
  }

  BattleTeam _toBattleTeam(_BattleSide side) {
    return side == _BattleSide.ally ? BattleTeam.ally : BattleTeam.enemy;
  }

  List<BattleRunUnitState> _extractUnits(
    Map<String, _BattleUnit> units,
    BattleTeam team,
  ) {
    return units.values
        .where(
          (_BattleUnit unit) =>
              (team == BattleTeam.ally && unit.side == _BattleSide.ally) ||
              (team == BattleTeam.enemy && unit.side == _BattleSide.enemy),
        )
        .map(
          (_BattleUnit unit) => BattleRunUnitState(
            unitId: unit.id,
            name: unit.name,
            team: team,
            faction: unit.faction,
            stats: unit.stats,
            modifiers: unit.baseModifiers,
            passives: unit.passives,
            skills: unit.skills,
            activeModifiers: unit.activeModifiers,
            statuses: unit.statuses,
            shield: unit.shield,
            currentHp: unit.currentHp,
            currentMp: unit.currentMp,
            skillCooldowns: unit.skillCooldowns,
          ),
        )
        .toList(growable: false);
  }

  List<String> _buildTurnOrder(
    Map<String, _BattleUnit> units, {
    required bool firstTurn,
  }) {
    final List<_BattleUnit> living =
        units.values
            .where((_BattleUnit unit) => unit.isAlive)
            .toList(growable: false)
          ..sort((_BattleUnit left, _BattleUnit right) {
            if (firstTurn) {
              final int firstStrikeCompare =
                  _BattleModifierResolver.firstStrikePriority(right).compareTo(
                    _BattleModifierResolver.firstStrikePriority(left),
                  );
              if (firstStrikeCompare != 0) {
                return firstStrikeCompare;
              }
            }
            final int speedCompare = right.stats.speed.compareTo(
              left.stats.speed,
            );
            if (speedCompare != 0) {
              return speedCompare;
            }
            if (left.side == right.side) {
              return left.id.compareTo(right.id);
            }
            return left.side == _BattleSide.ally ? -1 : 1;
          });
    return living.map((_BattleUnit unit) => unit.id).toList(growable: false);
  }

  bool _isSupportedActiveSkill(BattleSkillDefinition skill) {
    final bool supportedTarget = switch (skill.targetType) {
      BattleSkillTargetType.randomEnemy ||
      BattleSkillTargetType.self ||
      BattleSkillTargetType.randomAlly ||
      BattleSkillTargetType.allEnemies ||
      BattleSkillTargetType.allAllies => true,
    };
    final bool supportedEffect = switch (skill.effectType) {
      BattleSkillEffectType.damage => true,
      BattleSkillEffectType.heal => true,
      BattleSkillEffectType.grantModifier => skill.modifier != null,
      BattleSkillEffectType.grantStatus => skill.statusType != null,
      BattleSkillEffectType.grantShield =>
        skill.shieldValue > 0 || skill.flatPower > 0,
    };
    return supportedTarget && supportedEffect;
  }

  Map<String, int> _tickSkillCooldowns(_BattleUnit actor) {
    if (actor.skillCooldowns.isEmpty) {
      return <String, int>{};
    }
    final Map<String, int> next = <String, int>{};
    actor.skillCooldowns.forEach((String skillId, int remaining) {
      final int ticked = remaining - 1;
      if (ticked > 0) {
        next[skillId] = ticked;
      }
    });
    return next;
  }

  Map<String, int> _startSkillCooldowns(
    _BattleUnit actor,
    BattleSkillDefinition skill,
  ) {
    final Map<String, int> next = _tickSkillCooldowns(actor);
    if (skill.cooldownLifecycles > 0) {
      next[skill.id] = skill.cooldownLifecycles;
    }
    return next;
  }

  List<_BattleUnit> _livingUnits(
    Map<String, _BattleUnit> units,
    _BattleSide side,
  ) {
    return units.values
        .where((_BattleUnit unit) => unit.side == side && unit.isAlive)
        .toList(growable: false);
  }
}

class _ActionLifecycleContext {
  const _ActionLifecycleContext({
    required this.actor,
    required this.lifecycle,
    required this.potionBoost,
    required this.allowDerivedActions,
  });

  final _BattleUnit actor;
  final int lifecycle;
  final int potionBoost;
  final bool allowDerivedActions;
}

class _ActionLifecycleResult {
  const _ActionLifecycleResult({
    required this.actions,
    required this.nextLifecycle,
  });

  final List<BattleActionLog> actions;
  final int nextLifecycle;
}

class _DerivedActionRequest {
  const _DerivedActionRequest({required this.actor});

  final _BattleUnit actor;
}

class BattleEncounterStepResult {
  const BattleEncounterStepResult({
    required this.allies,
    required this.encounter,
    required this.ended,
    this.success = false,
    this.wiped = false,
    this.lifecycleActions = const <BattleActionLog>[],
  });

  final List<BattleRunUnitState> allies;
  final BattleEncounterRuntimeState encounter;
  final bool ended;
  final bool success;
  final bool wiped;
  final List<BattleActionLog> lifecycleActions;
}

class BattleEncounterOutcome {
  const BattleEncounterOutcome({
    required this.allies,
    required this.encounter,
    required this.success,
    required this.wiped,
  });

  final List<BattleRunUnitState> allies;
  final BattleEncounterRuntimeState encounter;
  final bool success;
  final bool wiped;
}
