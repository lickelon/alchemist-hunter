import 'dart:math';

import 'package:alchemist_hunter/features/battle/domain/models.dart';

part 'battle_loop_runner.dart';
part 'battle_attack_resolver.dart';
part 'battle_encounter_unit_mapper.dart';
part 'battle_skill_effect_resolver.dart';
part 'battle_passive_effect_resolver.dart';
part 'battle_action_selection.dart';
part 'battle_action_followup_resolver.dart';
part 'battle_action_lifecycle.dart';
part 'battle_encounter_runner.dart';
part 'battle_modifier_resolver.dart';
part 'battle_recovery_resolver.dart';
part 'battle_reward_resolver.dart';
part 'battle_unit.dart';

class BattleService
    with
        _BattleEncounterUnitMapperMixin,
        _BattleSkillEffectMixin,
        _BattlePassiveEffectMixin,
        _BattleActionSelectionMixin,
        _BattleActionFollowupMixin,
        _BattleActionLifecycleMixin,
        _BattleEncounterRunnerMixin {
  BattleService({Random? random}) : _random = random ?? Random();

  @override
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
