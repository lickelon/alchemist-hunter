import 'package:alchemist_hunter/app/session/session_state.dart';
import 'dart:math';

import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_encounter_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_potion_loadout_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';

class BattleEncounterResolution {
  const BattleEncounterResolution({
    required this.runState,
    required this.summary,
    this.consumedPotionLoadout = const <String, int>{},
    this.usedLoadoutFallback = false,
  });

  final BattleRunState? runState;
  final String summary;
  final Map<String, int> consumedPotionLoadout;
  final bool usedLoadoutFallback;
}

abstract class BattleExpeditionResolver {
  BattleEncounterResolution resolveEncounter({
    required SessionState state,
    required String stageId,
    BattleRunState? currentRunState,
    required BattleCatalogRepository battleCatalogRepository,
  });

  BattleEncounterStepResult runEncounterStep({
    required List<BattleRunUnitState> allies,
    required BattleEncounterRuntimeState encounter,
    required int potionBoost,
  });

  Map<String, int> resolveRewards({
    required bool success,
    required BattleDropTable table,
  });
}

class DefaultBattleExpeditionResolver implements BattleExpeditionResolver {
  DefaultBattleExpeditionResolver({
    BattleService? battleService,
    BattleEncounterService battleEncounterService =
        const BattleEncounterService(),
    BattlePartyPowerService battlePartyPowerService =
        const BattlePartyPowerService(),
    BattlePotionLoadoutService battlePotionLoadoutService =
        const BattlePotionLoadoutService(),
    Random? random,
  }) : _battleService = battleService ?? BattleService(),
       _battleEncounterService = battleEncounterService,
       _battlePartyPowerService = battlePartyPowerService,
       _battlePotionLoadoutService = battlePotionLoadoutService,
       _random = random ?? Random();

  final BattleService _battleService;
  final BattleEncounterService _battleEncounterService;
  final BattlePartyPowerService _battlePartyPowerService;
  final BattlePotionLoadoutService _battlePotionLoadoutService;
  final Random _random;

  @override
  BattleEncounterResolution resolveEncounter({
    required SessionState state,
    required String stageId,
    BattleRunState? currentRunState,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    final BattleExpeditionState currentExpedition =
        state.battle.stageExpeditions[stageId] ??
        const BattleExpeditionState(
          status: BattleExpeditionStatus.idle,
          lastProgressedAt: null,
          phaseProgress: Duration.zero,
        );
    final List<String> assignedCharacterIds =
        state.battle.stageAssignments[stageId] ?? const <String>[];
    final Map<String, int> requestedPotionLoadout =
        state.battle.stagePotionLoadouts[stageId] ?? const <String, int>{};
    if (assignedCharacterIds.isEmpty) {
      return const BattleEncounterResolution(runState: null, summary: '편성 없음');
    }
    final ResolvedBattlePotionLoadout resolvedLoadout =
        _battlePotionLoadoutService.resolveLoadout(
          requestedLoadout: requestedPotionLoadout,
          ownedStacks: state.workshop.craftedPotionStacks,
        );

    final BattleStageDefinition stageDefinition = battleCatalogRepository
        .stageDefinition(stageId);
    final BattleEncounterSelection encounter = _battleEncounterService
        .selectEncounter(
          stage: stageDefinition,
          battleCatalogRepository: battleCatalogRepository,
          random: _random,
        );
    final List<HeroProfile> party = _battlePartyPowerService.buildParty(
      state.characters,
      assignedCharacterIds: assignedCharacterIds,
    );
    final BattleRunState previousRunState =
        currentRunState ?? currentExpedition.runState ?? const BattleRunState();
    final List<BattleRunUnitState> allies = previousRunState.allies.isEmpty
        ? _battleService.createRunAllies(party: party)
        : previousRunState.allies;
    final BattleEncounterRuntimeState runtimeEncounter =
        BattleEncounterRuntimeState(
          encounterId: encounter.definition.id,
          encounterName: encounter.definition.name,
          encounterIndex: previousRunState.encounterCount + 1,
          enemySetId: encounter.definition.enemySetId,
          enemies: _battleService.createEncounterEnemies(
            enemies: encounter.enemies,
          ),
          appliedPotionLoadout: resolvedLoadout.appliedLoadout,
          usedLoadoutFallback: resolvedLoadout.fallback,
        );
    final BattleRunState nextRunState = previousRunState.copyWith(
      allies: allies,
      currentEncounter: runtimeEncounter,
    );

    return BattleEncounterResolution(
      runState: nextRunState,
      summary:
          '${encounter.definition.name} 교전 시작${resolvedLoadout.fallback ? ' / 포션 부족' : ''}',
      consumedPotionLoadout: resolvedLoadout.appliedLoadout,
      usedLoadoutFallback: resolvedLoadout.fallback,
    );
  }

  @override
  BattleEncounterStepResult runEncounterStep({
    required List<BattleRunUnitState> allies,
    required BattleEncounterRuntimeState encounter,
    required int potionBoost,
  }) {
    return _battleService.runEncounterStep(
      allies: allies,
      encounter: encounter,
      potionBoost: potionBoost,
    );
  }

  @override
  Map<String, int> resolveRewards({
    required bool success,
    required BattleDropTable table,
  }) {
    return _battleService.resolveRewards(success: success, table: table);
  }
}
