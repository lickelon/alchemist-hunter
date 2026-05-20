part of 'battle_service.dart';

class _BattleLoopRunner {
  const _BattleLoopRunner({required Random random}) : _random = random;

  final Random _random;

  _BattleLoopResult run({
    required AutoBattleConfig config,
    required List<BattleEnemyDefinition> enemies,
  }) {
    final int potionBoost = config.potionLoadout.values.fold<int>(
      0,
      (int s, int v) => s + v,
    );
    final List<_BattleUnit> allies = config.party
        .map(
          (HeroProfile profile) => _BattleUnit(
            id: profile.id,
            name: profile.name,
            side: _BattleSide.ally,
            faction: profile.faction,
            stats: profile.stats,
            baseModifiers: profile.modifiers,
            passives: profile.passives,
            skills: profile.skills,
            activeModifiers: <BattleTimedModifier>[],
            statuses: <BattleStatusEffect>[],
            shield: 0,
            currentHp: profile.stats.maxHp,
            currentMp: 0,
            skillCooldowns: const <String, int>{},
          ),
        )
        .toList(growable: false);
    final List<_BattleUnit> battleEnemies = enemies
        .map(
          (BattleEnemyDefinition enemy) => _BattleUnit(
            id: enemy.id,
            name: enemy.name,
            side: _BattleSide.enemy,
            faction: enemy.faction,
            stats: enemy.stats,
            baseModifiers: enemy.modifiers,
            passives: enemy.passives,
            skills: enemy.skills,
            activeModifiers: <BattleTimedModifier>[],
            statuses: <BattleStatusEffect>[],
            shield: 0,
            currentHp: enemy.stats.maxHp,
            currentMp: 0,
            skillCooldowns: const <String, int>{},
          ),
        )
        .toList(growable: false);

    return _runBattleLoop(
      allies: allies,
      enemies: battleEnemies,
      potionBoost: potionBoost,
    );
  }

  _BattleLoopResult _runBattleLoop({
    required List<_BattleUnit> allies,
    required List<_BattleUnit> enemies,
    required int potionBoost,
  }) {
    int turns = 0;
    const int maxTurns = 24;
    final List<BattleActionLog> actions = <BattleActionLog>[];
    final _BattleAttackResolver attackResolver = _BattleAttackResolver(
      random: _random,
    );
    const _BattleRecoveryResolver recoveryResolver = _BattleRecoveryResolver();

    while (_hasLiving(allies) && _hasLiving(enemies) && turns < maxTurns) {
      final List<_BattleUnit> turnOrder =
          <_BattleUnit>[
            ...allies.where((unit) => unit.isAlive),
            ...enemies.where((unit) => unit.isAlive),
          ]..sort((_BattleUnit left, _BattleUnit right) {
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

      for (final _BattleUnit actor in turnOrder) {
        if (!actor.isAlive) {
          continue;
        }
        final List<_BattleUnit> targets = actor.side == _BattleSide.ally
            ? enemies
            : allies;
        _BattleUnit? target = _selectTarget(targets);
        if (target == null) {
          break;
        }

        final BattleSkillDefinition? skill = _selectSkill(actor);
        final bool usesSkill = skill != null;
        final int mpSpent = usesSkill ? actor.currentMp : 0;
        if (usesSkill) {
          actor.currentMp = 0;
          actor.skillCooldowns = _startSkillCooldowns(actor, skill);
        } else {
          actor.skillCooldowns = _tickSkillCooldowns(actor);
        }
        final int extraAttackCount = _BattleModifierResolver.extraAttackCount(
          actor,
        );
        final int attackCount = usesSkill ? 1 : 1 + extraAttackCount;
        for (int attackIndex = 0; attackIndex < attackCount; attackIndex++) {
          if (!actor.isAlive) {
            break;
          }
          final _BattleUnit? currentTarget = target!.isAlive
              ? target
              : _selectTarget(targets);
          if (currentTarget == null) {
            break;
          }
          turns += 1;
          final int lifecycle = turns;
          if (usesSkill && attackIndex == 0) {
            actions.add(
              BattleActionLog(
                lifecycle: lifecycle,
                turn: turns,
                type: BattleActionType.skillUse,
                actorId: actor.id,
                actorName: actor.name,
                actorTeam: _toBattleTeam(actor.side),
                skillId: skill.id,
                skillName: skill.name,
                mpSpent: mpSpent,
                actorHpAfter: actor.currentHp,
                actorMpAfter: actor.currentMp,
              ),
            );
          }

          final bool hit = attackResolver.rollHit(
            attacker: actor,
            defender: currentTarget,
            potionBoost: actor.side == _BattleSide.ally ? potionBoost : 0,
          );
          if (!hit) {
            actions.add(
              BattleActionLog(
                lifecycle: lifecycle,
                turn: turns,
                type: usesSkill
                    ? BattleActionType.skill
                    : BattleActionType.attack,
                actorId: actor.id,
                actorName: actor.name,
                actorTeam: _toBattleTeam(actor.side),
                targetId: currentTarget.id,
                targetName: currentTarget.name,
                targetTeam: _toBattleTeam(currentTarget.side),
                skillId: skill?.id,
                skillName: skill?.name,
                hit: false,
                mpSpent: 0,
                actorHpAfter: actor.currentHp,
                actorMpAfter: actor.currentMp,
                targetHpAfter: currentTarget.currentHp,
              ),
            );
            _applyRegen(
              actor,
              lifecycle: lifecycle,
              turn: turns,
              actions: actions,
              recoveryResolver: recoveryResolver,
            );
            if (!usesSkill) {
              _applyMpRegen(actor, recoveryResolver: recoveryResolver);
            }
            continue;
          }

          final bool critical = attackResolver.rollCritical(
            attacker: actor,
            defender: currentTarget,
            potionBoost: actor.side == _BattleSide.ally ? potionBoost : 0,
          );
          final _DamageRoll damageRoll = attackResolver.rollDamage(
            attacker: actor,
            defender: currentTarget,
            critical: critical,
            potionBoost: actor.side == _BattleSide.ally ? potionBoost : 0,
            skill: attackIndex == 0 ? skill : null,
          );
          currentTarget.currentHp = max(
            0,
            currentTarget.currentHp - damageRoll.damage,
          );

          final int actorHpBeforeRecovery = actor.currentHp;
          final int lifestealHealing = recoveryResolver.applyLifesteal(
            actor: actor,
            damage: damageRoll.damage,
          );
          actions.add(
            BattleActionLog(
              lifecycle: lifecycle,
              turn: turns,
              type: usesSkill && attackIndex == 0
                  ? BattleActionType.skill
                  : BattleActionType.attack,
              actorId: actor.id,
              actorName: actor.name,
              actorTeam: _toBattleTeam(actor.side),
              targetId: currentTarget.id,
              targetName: currentTarget.name,
              targetTeam: _toBattleTeam(currentTarget.side),
              skillId: attackIndex == 0 ? skill?.id : null,
              skillName: attackIndex == 0 ? skill?.name : null,
              school: damageRoll.school,
              hit: true,
              critical: critical,
              damage: damageRoll.damage,
              mpSpent: 0,
              actorHpAfter: actorHpBeforeRecovery,
              actorMpAfter: actor.currentMp,
              targetHpAfter: currentTarget.currentHp,
            ),
          );
          if (lifestealHealing > 0) {
            actions.add(
              BattleActionLog(
                lifecycle: lifecycle,
                turn: turns,
                type: BattleActionType.lifesteal,
                actorId: actor.id,
                actorName: actor.name,
                actorTeam: _toBattleTeam(actor.side),
                targetId: currentTarget.id,
                targetName: currentTarget.name,
                targetTeam: _toBattleTeam(currentTarget.side),
                healing: lifestealHealing,
                actorHpAfter: actor.currentHp,
                targetHpAfter: currentTarget.currentHp,
              ),
            );
          }
          _applyRegen(
            actor,
            lifecycle: lifecycle,
            turn: turns,
            actions: actions,
            recoveryResolver: recoveryResolver,
          );
          if (!usesSkill) {
            _applyMpRegen(actor, recoveryResolver: recoveryResolver);
          }
          target = currentTarget;
        }

        if (!_hasLiving(allies) || !_hasLiving(enemies) || turns >= maxTurns) {
          break;
        }
      }
    }

    if (_hasLiving(allies) && !_hasLiving(enemies)) {
      return _BattleLoopResult(success: true, turns: turns, actions: actions);
    }
    if (!_hasLiving(allies)) {
      return _BattleLoopResult(success: false, turns: turns, actions: actions);
    }

    final int allyHp = _totalCurrentHp(allies);
    final int enemyHp = _totalCurrentHp(enemies);
    return _BattleLoopResult(
      success: allyHp >= enemyHp,
      turns: turns,
      actions: actions,
    );
  }

  _BattleUnit? _selectTarget(List<_BattleUnit> candidates) {
    final List<_BattleUnit> living = candidates
        .where((unit) => unit.isAlive)
        .toList(growable: false);
    if (living.isEmpty) {
      return null;
    }
    return living[_random.nextInt(living.length)];
  }

  void _applyRegen(
    _BattleUnit unit, {
    required int lifecycle,
    required int turn,
    required List<BattleActionLog> actions,
    required _BattleRecoveryResolver recoveryResolver,
  }) {
    final int healing = recoveryResolver.applyRegen(unit);
    if (healing == 0) {
      return;
    }
    actions.add(
      BattleActionLog(
        lifecycle: lifecycle,
        turn: turn,
        type: BattleActionType.regen,
        actorId: unit.id,
        actorName: unit.name,
        actorTeam: _toBattleTeam(unit.side),
        healing: healing,
        actorHpAfter: unit.currentHp,
      ),
    );
  }

  void _applyMpRegen(
    _BattleUnit unit, {
    required _BattleRecoveryResolver recoveryResolver,
  }) {
    recoveryResolver.applyMpRegen(unit);
  }

  BattleSkillDefinition? _selectSkill(_BattleUnit actor) {
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

  BattleTeam _toBattleTeam(_BattleSide side) {
    return side == _BattleSide.ally ? BattleTeam.ally : BattleTeam.enemy;
  }

  bool _hasLiving(List<_BattleUnit> units) {
    return units.any((unit) => unit.isAlive);
  }

  int _totalCurrentHp(List<_BattleUnit> units) {
    return units
        .where((unit) => unit.isAlive)
        .fold<int>(0, (int sum, _BattleUnit unit) => sum + unit.currentHp);
  }
}
