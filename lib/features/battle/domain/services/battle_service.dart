import 'dart:math';

import 'package:alchemist_hunter/features/battle/domain/models.dart';

class BattleService {
  BattleService({Random? random}) : _random = random ?? Random();

  final Random _random;

  BattleResult runAutoBattle({
    required AutoBattleConfig config,
    required BattleStageDefinition stage,
    required List<BattleEnemyDefinition> enemies,
    required BattleDropTable dropTable,
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
            modifiers: profile.modifiers,
            passives: profile.passives,
            currentHp: profile.stats.maxHp,
          ),
        )
        .toList(growable: false);
    final _BattleLoopResult loopResult = _runBattleLoop(
      allies: allies,
      enemies: enemies
          .map(
            (BattleEnemyDefinition enemy) => _BattleUnit(
              id: enemy.id,
              name: enemy.name,
              side: _BattleSide.enemy,
              faction: enemy.faction,
              stats: enemy.stats,
              modifiers: enemy.modifiers,
              passives: enemy.passives,
              currentHp: enemy.stats.maxHp,
            ),
          )
          .toList(growable: false),
      potionBoost: potionBoost,
    );
    final Map<String, int> loot = resolveRewards(
      success: loopResult.success,
      table: dropTable,
    );
    final int penalty = loopResult.success ? 0 : stage.goldFailurePenalty;

    return BattleResult(
      success: loopResult.success,
      turns: loopResult.turns,
      loot: loot,
      failurePenalty: penalty,
      actions: loopResult.actions,
    );
  }

  Map<String, int> resolveRewards({
    required bool success,
    required BattleDropTable table,
  }) {
    final Map<String, int> rewards = <String, int>{};

    for (final BattleDropEntry entry in table.normalDrops) {
      if (_random.nextDouble() <= entry.chance) {
        rewards[entry.materialId] =
            entry.min + _random.nextInt(entry.max - entry.min + 1);
      }
    }

    if (success) {
      for (final BattleDropEntry entry in table.specialDrops) {
        if (_random.nextDouble() <= entry.chance) {
          rewards[entry.materialId] =
              (rewards[entry.materialId] ?? 0) +
              (entry.min + _random.nextInt(entry.max - entry.min + 1));
        }
      }
    }

    return rewards;
  }

  _BattleLoopResult _runBattleLoop({
    required List<_BattleUnit> allies,
    required List<_BattleUnit> enemies,
    required int potionBoost,
  }) {
    int turns = 0;
    const int maxTurns = 24;
    final List<BattleActionLog> actions = <BattleActionLog>[];

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

        turns += 1;
        final int extraAttackCount = _extraAttackCount(actor);
        final int attackCount = 1 + extraAttackCount;
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

          final bool hit = _rollHit(
            attacker: actor,
            defender: currentTarget,
            potionBoost: actor.side == _BattleSide.ally ? potionBoost : 0,
          );
          if (!hit) {
            actions.add(
              BattleActionLog(
                turn: turns,
                type: BattleActionType.attack,
                actorId: actor.id,
                actorName: actor.name,
                actorTeam: _toBattleTeam(actor.side),
                targetId: currentTarget.id,
                targetName: currentTarget.name,
                targetTeam: _toBattleTeam(currentTarget.side),
                hit: false,
                actorHpAfter: actor.currentHp,
                targetHpAfter: currentTarget.currentHp,
              ),
            );
            continue;
          }

          final bool critical = _rollCritical(
            attacker: actor,
            defender: currentTarget,
            potionBoost: actor.side == _BattleSide.ally ? potionBoost : 0,
          );
          final _DamageRoll damageRoll = _rollDamage(
            attacker: actor,
            defender: currentTarget,
            critical: critical,
            potionBoost: actor.side == _BattleSide.ally ? potionBoost : 0,
          );
          currentTarget.currentHp = max(
            0,
            currentTarget.currentHp - damageRoll.damage,
          );

          int lifestealHealing = 0;
          final double lifestealRate =
              actor.stats.lifesteal +
              _flatModifierTotal(actor, BattleModifierType.lifesteal);
          if (damageRoll.damage > 0 && lifestealRate > 0) {
            lifestealHealing = max(
              1,
              (damageRoll.damage * lifestealRate).round(),
            );
            actor.currentHp = min(
              actor.maxHp,
              actor.currentHp + lifestealHealing,
            );
          }
          actions.add(
            BattleActionLog(
              turn: turns,
              type: BattleActionType.attack,
              actorId: actor.id,
              actorName: actor.name,
              actorTeam: _toBattleTeam(actor.side),
              targetId: currentTarget.id,
              targetName: currentTarget.name,
              targetTeam: _toBattleTeam(currentTarget.side),
              school: damageRoll.school,
              hit: true,
              critical: critical,
              damage: damageRoll.damage,
              healing: lifestealHealing,
              actorHpAfter: actor.currentHp,
              targetHpAfter: currentTarget.currentHp,
            ),
          );
          target = currentTarget;
        }

        if (!_hasLiving(allies) || !_hasLiving(enemies) || turns >= maxTurns) {
          break;
        }
      }

      _applyRegen(allies, turn: turns, actions: actions);
      _applyRegen(enemies, turn: turns, actions: actions);
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

  bool _rollHit({
    required _BattleUnit attacker,
    required _BattleUnit defender,
    required int potionBoost,
  }) {
    if (_hasPassive(attacker, BattlePassiveEffectType.alwaysHit)) {
      return true;
    }
    final double accuracyBonus = potionBoost * 0.02;
    final double hitChance =
        (attacker.stats.accuracy +
                accuracyBonus +
                _flatModifierTotal(attacker, BattleModifierType.accuracy) -
                defender.stats.evasion -
                _flatModifierTotal(defender, BattleModifierType.evasion))
            .clamp(0.25, 0.98);
    return _random.nextDouble() <= hitChance;
  }

  bool _rollCritical({
    required _BattleUnit attacker,
    required _BattleUnit defender,
    required int potionBoost,
  }) {
    final double critChance =
        (attacker.stats.critChance +
                (potionBoost * 0.005) +
                _flatModifierTotal(attacker, BattleModifierType.critRate) -
                _flatModifierTotal(defender, BattleModifierType.critRate))
            .clamp(0, 0.95);
    return _random.nextDouble() <= critChance;
  }

  _DamageRoll _rollDamage({
    required _BattleUnit attacker,
    required _BattleUnit defender,
    required bool critical,
    required int potionBoost,
  }) {
    final bool useMagic =
        attacker.stats.magicalAttack > attacker.stats.physicalAttack;
    final int attack = useMagic
        ? attacker.stats.magicalAttack
        : attacker.stats.physicalAttack;
    final int defense = useMagic
        ? defender.stats.magicalDefense
        : defender.stats.physicalDefense;
    final double penetration = useMagic
        ? attacker.stats.magicalPenetration
        : attacker.stats.physicalPenetration;
    final DamageSchool school = useMagic
        ? DamageSchool.magical
        : DamageSchool.physical;
    final double effectiveDefense = defense * (1 - penetration.clamp(0, 0.8));
    double damage =
        attack * max(0.28, 1 - (effectiveDefense / max(attack * 2.2 + 16, 1)));

    if (attacker.side == _BattleSide.ally && potionBoost > 0) {
      damage *= 1 + (potionBoost * 0.08);
    }
    if (critical) {
      damage *=
          1 +
          attacker.stats.critDamage +
          _flatModifierTotal(attacker, BattleModifierType.critDamage);
    }
    damage *=
        1 +
        _percentModifierTotal(
          attacker,
          BattleModifierType.damageDealt,
          school: school,
          targetFaction: defender.faction,
        );
    damage *=
        1 +
        _percentModifierTotal(
          defender,
          BattleModifierType.damageTaken,
          school: school,
          targetFaction: attacker.faction,
        );
    return _DamageRoll(
      damage: max(max(attack ~/ 4, 1), damage.round()),
      school: school,
    );
  }

  void _applyRegen(
    List<_BattleUnit> units, {
    required int turn,
    required List<BattleActionLog> actions,
  }) {
    for (final _BattleUnit unit in units) {
      final double regenRate =
          unit.stats.regen + _flatModifierTotal(unit, BattleModifierType.regen);
      if (!unit.isAlive || regenRate <= 0) {
        continue;
      }
      final int healing = max(1, (unit.maxHp * regenRate).round());
      final int previousHp = unit.currentHp;
      unit.currentHp = min(unit.maxHp, unit.currentHp + healing);
      if (unit.currentHp == previousHp) {
        continue;
      }
      actions.add(
        BattleActionLog(
          turn: turn,
          type: BattleActionType.regen,
          actorId: unit.id,
          actorName: unit.name,
          actorTeam: _toBattleTeam(unit.side),
          healing: unit.currentHp - previousHp,
          actorHpAfter: unit.currentHp,
        ),
      );
    }
  }

  BattleTeam _toBattleTeam(_BattleSide side) {
    return side == _BattleSide.ally ? BattleTeam.ally : BattleTeam.enemy;
  }

  bool _hasPassive(_BattleUnit unit, BattlePassiveEffectType type) {
    return unit.passives.any(
      (BattlePassiveEffect passive) => passive.type == type,
    );
  }

  int _extraAttackCount(_BattleUnit unit) {
    return unit.passives
        .where(
          (BattlePassiveEffect passive) =>
              passive.type == BattlePassiveEffectType.extraAttack &&
              passive.trigger == BattlePassiveTrigger.afterAction,
        )
        .fold<int>(0, (int total, BattlePassiveEffect passive) {
          return total + (passive.value ?? 1);
        });
  }

  double _flatModifierTotal(_BattleUnit unit, BattleModifierType type) {
    return unit.modifiers
        .where(
          (BattleModifier modifier) =>
              modifier.type == type && modifier.mode == BattleModifierMode.flat,
        )
        .fold<double>(0, (double total, BattleModifier modifier) {
          return total + modifier.value;
        });
  }

  double _percentModifierTotal(
    _BattleUnit unit,
    BattleModifierType type, {
    required DamageSchool school,
    required CombatFaction targetFaction,
  }) {
    return unit.modifiers
        .where(
          (BattleModifier modifier) =>
              modifier.type == type &&
              modifier.mode == BattleModifierMode.percent &&
              (modifier.school == DamageSchool.any ||
                  modifier.school == school) &&
              (modifier.targetFaction == null ||
                  modifier.targetFaction == targetFaction),
        )
        .fold<double>(0, (double total, BattleModifier modifier) {
          return total + modifier.value;
        });
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

enum _BattleSide { ally, enemy }

class _BattleUnit {
  _BattleUnit({
    required this.id,
    required this.name,
    required this.side,
    required this.faction,
    required this.stats,
    required this.modifiers,
    required this.passives,
    required this.currentHp,
  });

  final String id;
  final String name;
  final _BattleSide side;
  final CombatFaction faction;
  final BattleCombatStats stats;
  final List<BattleModifier> modifiers;
  final List<BattlePassiveEffect> passives;
  int currentHp;

  int get maxHp => stats.maxHp;
  bool get isAlive => currentHp > 0;
}

class _BattleLoopResult {
  const _BattleLoopResult({
    required this.success,
    required this.turns,
    required this.actions,
  });

  final bool success;
  final int turns;
  final List<BattleActionLog> actions;
}

class _DamageRoll {
  const _DamageRoll({required this.damage, required this.school});

  final int damage;
  final DamageSchool school;
}
