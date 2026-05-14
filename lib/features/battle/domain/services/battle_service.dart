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
            currentHp: profile.stats.maxHp,
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
            currentHp: enemy.stats.maxHp,
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
        .where((String queueId) {
          final String unitId = _queueActorId(queueId);
          return units[unitId]?.isAlive ?? false;
        })
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

    final String queuedActorId = pendingActorIds.removeAt(0);
    final String actorId = _queueActorId(queuedActorId);
    final bool extraAction = _isExtraQueueActorId(queuedActorId);
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

    final _BattleUnit target = targets[_random.nextInt(targets.length)];
    final _BattleAttackResolver attackResolver = _BattleAttackResolver(
      random: _random,
    );
    const _BattleRecoveryResolver recoveryResolver = _BattleRecoveryResolver();
    final int lifecycle = encounter.turnInEncounter + 1;
    final List<BattleActionLog> actions = <BattleActionLog>[];

    final bool hit = attackResolver.rollHit(
      attacker: actor,
      defender: target,
      potionBoost: actor.side == _BattleSide.ally ? potionBoost : 0,
    );
    if (!hit) {
      actions.add(
        BattleActionLog(
          lifecycle: lifecycle,
          turn: lifecycle,
          type: BattleActionType.attack,
          actorId: actor.id,
          actorName: actor.name,
          actorTeam: _toBattleTeam(actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          hit: false,
          actorHpAfter: actor.currentHp,
          targetHpAfter: target.currentHp,
        ),
      );
    } else {
      final bool critical = attackResolver.rollCritical(
        attacker: actor,
        defender: target,
        potionBoost: actor.side == _BattleSide.ally ? potionBoost : 0,
      );
      final _DamageRoll damageRoll = attackResolver.rollDamage(
        attacker: actor,
        defender: target,
        critical: critical,
        potionBoost: actor.side == _BattleSide.ally ? potionBoost : 0,
      );
      target.currentHp = max(0, target.currentHp - damageRoll.damage);
      final int actorHpBeforeRecovery = actor.currentHp;
      final int lifestealHealing = recoveryResolver.applyLifesteal(
        actor: actor,
        damage: damageRoll.damage,
      );
      actions.add(
        BattleActionLog(
          lifecycle: lifecycle,
          turn: lifecycle,
          type: BattleActionType.attack,
          actorId: actor.id,
          actorName: actor.name,
          actorTeam: _toBattleTeam(actor.side),
          targetId: target.id,
          targetName: target.name,
          targetTeam: _toBattleTeam(target.side),
          school: damageRoll.school,
          hit: true,
          critical: critical,
          damage: damageRoll.damage,
          actorHpAfter: actorHpBeforeRecovery,
          targetHpAfter: target.currentHp,
        ),
      );
      if (lifestealHealing > 0) {
        actions.add(
          BattleActionLog(
            lifecycle: lifecycle,
            turn: lifecycle,
            type: BattleActionType.lifesteal,
            actorId: actor.id,
            actorName: actor.name,
            actorTeam: _toBattleTeam(actor.side),
            targetId: target.id,
            targetName: target.name,
            targetTeam: _toBattleTeam(target.side),
            healing: lifestealHealing,
            actorHpAfter: actor.currentHp,
            targetHpAfter: target.currentHp,
          ),
        );
      }
    }

    final int regenHealing = recoveryResolver.applyRegen(actor);
    if (regenHealing > 0) {
      actions.add(
        BattleActionLog(
          lifecycle: lifecycle,
          turn: lifecycle,
          type: BattleActionType.regen,
          actorId: actor.id,
          actorName: actor.name,
          actorTeam: _toBattleTeam(actor.side),
          healing: regenHealing,
          actorHpAfter: actor.currentHp,
        ),
      );
    }

    final bool success = _livingUnits(units, _BattleSide.enemy).isEmpty;
    final bool wiped = _livingUnits(units, _BattleSide.ally).isEmpty;
    final int extraAttackCount = success || wiped || extraAction
        ? 0
        : _BattleModifierResolver.extraAttackCount(actor);
    if (extraAttackCount > 0 && actor.isAlive) {
      pendingActorIds = <String>[
        ...List<String>.filled(extraAttackCount, _extraQueueActorId(actor.id)),
        ...pendingActorIds,
      ];
    }

    return BattleEncounterStepResult(
      allies: _extractUnits(units, BattleTeam.ally),
      encounter: encounter.copyWith(
        enemies: _extractUnits(units, BattleTeam.enemy),
        pendingActorIds: pendingActorIds,
        recentActionLogs: <BattleActionLog>[
          ...encounter.recentActionLogs,
          ...actions,
        ],
        turnInEncounter: lifecycle,
      ),
      ended: success || wiped,
      success: success,
      wiped: wiped,
      lifecycleActions: actions,
    );
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
      currentHp: unit.currentHp,
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
            currentHp: unit.currentHp,
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

  bool _isExtraQueueActorId(String queueId) => queueId.startsWith('extra:');

  String _queueActorId(String queueId) {
    return _isExtraQueueActorId(queueId) ? queueId.substring(6) : queueId;
  }

  String _extraQueueActorId(String actorId) => 'extra:$actorId';

  List<_BattleUnit> _livingUnits(
    Map<String, _BattleUnit> units,
    _BattleSide side,
  ) {
    return units.values
        .where((_BattleUnit unit) => unit.side == side && unit.isAlive)
        .toList(growable: false);
  }
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
