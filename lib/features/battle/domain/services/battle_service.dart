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
      pendingActorIds = List<String>.of(_buildTurnOrder(units), growable: true);
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

    _applyBeforeActionHooks(context);
    final BattleSkillDefinition? skill = _selectBaseAction(context.actor);
    final List<_BattleUnit> targets = _selectActionTargets(
      context.actor,
      units,
    );
    if (targets.isEmpty) {
      return _buildActionLifecycleResult(
        actions: const <BattleActionLog>[],
        nextLifecycle: startLifecycle,
      );
    }

    final _BattleUnit target = targets[_random.nextInt(targets.length)];
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

    final List<BattleActionLog> actions = <BattleActionLog>[];
    _applyBeforeHitCheckHooks(context, target);
    final bool hit = _resolveHitCheck(context, target);
    if (!hit) {
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
          hit: false,
          mpSpent: mpSpent,
          actorHpAfter: context.actor.currentHp,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: target.currentHp,
        ),
      );
    } else {
      _applyBeforeDamageHooks(context, target);
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
      _applyActionEffect(target: target, damageRoll: damageRoll);
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
          damage: damageRoll.damage,
          mpSpent: mpSpent,
          actorHpAfter: actorHpBeforeRecovery,
          actorMpAfter: context.actor.currentMp,
          targetHpAfter: target.currentHp,
        ),
      );
      _applyAfterHitHooks(context, target);
      onDamagedRequests = _applyOnDamagedHooks(context, target);
      actions.addAll(
        _applyPostActionRecovery(
          context: context,
          target: target,
          damage: damageRoll.damage,
          usesSkill: usesSkill,
        ),
      );
    }

    if (!hit) {
      actions.addAll(
        _applyPostActionRecovery(
          context: context,
          target: target,
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
    _applyTurnEndHooks(context);
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

  void _applyBeforeActionHooks(_ActionLifecycleContext context) {}

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
  ) {
    return actor.side == _BattleSide.ally
        ? _livingUnits(units, _BattleSide.enemy)
        : _livingUnits(units, _BattleSide.ally);
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

  void _applyBeforeDamageHooks(
    _ActionLifecycleContext context,
    _BattleUnit target,
  ) {}

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

  void _applyActionEffect({
    required _BattleUnit target,
    required _DamageRoll damageRoll,
  }) {
    target.currentHp = max(0, target.currentHp - damageRoll.damage);
  }

  void _applyAfterHitHooks(
    _ActionLifecycleContext context,
    _BattleUnit target,
  ) {}

  List<_DerivedActionRequest> _applyOnDamagedHooks(
    _ActionLifecycleContext context,
    _BattleUnit target,
  ) {
    return const <_DerivedActionRequest>[];
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

  void _applyTurnEndHooks(_ActionLifecycleContext context) {}

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
      modifiers: unit.modifiers,
      passives: unit.passives,
      skills: unit.skills,
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
            modifiers: unit.modifiers,
            passives: unit.passives,
            skills: unit.skills,
            currentHp: unit.currentHp,
            currentMp: unit.currentMp,
            skillCooldowns: unit.skillCooldowns,
          ),
        )
        .toList(growable: false);
  }

  List<String> _buildTurnOrder(Map<String, _BattleUnit> units) {
    final List<_BattleUnit> living =
        units.values
            .where((_BattleUnit unit) => unit.isAlive)
            .toList(growable: false)
          ..sort((_BattleUnit left, _BattleUnit right) {
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
    return skill.effectType == BattleSkillEffectType.damage &&
        skill.targetType == BattleSkillTargetType.randomEnemy;
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
