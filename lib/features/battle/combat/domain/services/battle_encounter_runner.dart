part of 'battle_service.dart';

mixin _BattleEncounterRunnerMixin
    on _BattleEncounterUnitMapperMixin, _BattleActionLifecycleMixin {
  static const int maxLifecyclesPerActionTurn = 64;

  BattleEncounterStepResult runEncounterStep({
    required List<BattleRunUnitState> allies,
    required BattleEncounterRuntimeState encounter,
    required int potionBoost,
  }) {
    if (encounter.turnInEncounter >= BattleService.maxActionTurns) {
      return BattleEncounterStepResult(
        allies: allies,
        encounter: encounter,
        ended: true,
        success: false,
        wiped: false,
      );
    }

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

    final int actionTurn = encounter.turnInEncounter + 1;
    final int startLifecycle = encounter.lifecycleInEncounter + 1;
    final _ActionLifecycleResult lifecycleResult = _runActionLifecycle(
      units: units,
      actor: actor,
      actionTurn: actionTurn,
      startLifecycle: startLifecycle,
      maxLifecycle: startLifecycle + maxLifecyclesPerActionTurn - 1,
      potionBoost: potionBoost,
      allowExtraAttack: true,
      allowCounterAttack: true,
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
        turnInEncounter: actionTurn,
        lifecycleInEncounter: max(
          encounter.lifecycleInEncounter,
          lifecycleResult.nextLifecycle - 1,
        ),
      ),
      ended: success || wiped,
      success: success,
      wiped: wiped,
      lifecycleActions: actions,
    );
  }
}
