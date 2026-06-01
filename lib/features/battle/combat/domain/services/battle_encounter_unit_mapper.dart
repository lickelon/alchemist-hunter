part of 'battle_service.dart';

mixin _BattleEncounterUnitMapperMixin {
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
