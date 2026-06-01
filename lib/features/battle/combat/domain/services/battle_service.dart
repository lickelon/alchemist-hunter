import 'dart:math';

import 'package:alchemist_hunter/features/battle/domain/models.dart';

part 'battle_attack_resolver.dart';
part 'battle_encounter_unit_mapper.dart';
part 'battle_skill_effect_resolver.dart';
part 'battle_heal_skill_effect.dart';
part 'battle_modifier_skill_effect.dart';
part 'battle_status_skill_effect.dart';
part 'battle_shield_skill_effect.dart';
part 'battle_passive_condition_resolver.dart';
part 'battle_passive_effect_resolver.dart';
part 'battle_action_target_selection.dart';
part 'battle_action_selection.dart';
part 'battle_action_followup_resolver.dart';
part 'battle_action_recovery_hooks.dart';
part 'battle_action_turn_end_hooks.dart';
part 'battle_action_lifecycle_models.dart';
part 'battle_action_lifecycle.dart';
part 'battle_action_skill_effects.dart';
part 'battle_action_lifecycle_effects.dart';
part 'battle_action_lifecycle_helpers.dart';
part 'battle_encounter_runner.dart';
part 'battle_modifier_resolver.dart';
part 'battle_recovery_resolver.dart';
part 'battle_reward_resolver.dart';
part 'battle_encounter_results.dart';
part 'battle_unit.dart';

class BattleService
    with
        _BattleEncounterUnitMapperMixin,
        _BattleSkillEffectMixin,
        _BattlePassiveConditionMixin,
        _BattlePassiveEffectMixin,
        _BattleActionTargetSelectionMixin,
        _BattleActionSelectionMixin,
        _BattleActionFollowupMixin,
        _BattleActionRecoveryHookMixin,
        _BattleActionTurnEndHookMixin,
        _BattleActionLifecycleMixin,
        _BattleEncounterRunnerMixin {
  BattleService({Random? random}) : _random = random ?? Random();
  static const int maxActionTurns = 256;

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
      if (nextEncounter.turnInEncounter >= maxActionTurns) {
        return BattleEncounterOutcome(
          allies: nextAllies,
          encounter: nextEncounter,
          success: false,
          wiped: false,
        );
      }
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

  Map<String, int> resolveRewards({
    required bool success,
    required BattleDropTable table,
  }) {
    return _BattleRewardResolver(
      random: _random,
    ).resolve(success: success, table: table);
  }
}
