import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/expedition/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/battle/expedition/domain/services/battle_potion_loadout_service.dart';
import 'package:alchemist_hunter/features/battle/expedition/domain/services/battle_progression_service.dart';
import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/characters/domain/services/character_progression_service.dart';

class BattleAutoRewardBuilder {
  const BattleAutoRewardBuilder({
    required BattleCatalogRepository battleCatalogRepository,
    CharacterProgressionService characterProgressionService =
        const CharacterProgressionService(),
    BattlePotionLoadoutService battlePotionLoadoutService =
        const BattlePotionLoadoutService(),
    BattleProgressionService battleProgressionService =
        const BattleProgressionService(),
  }) : _battleCatalogRepository = battleCatalogRepository,
       _characterProgressionService = characterProgressionService,
       _battlePotionLoadoutService = battlePotionLoadoutService,
       _battleProgressionService = battleProgressionService;

  final BattleCatalogRepository _battleCatalogRepository;
  final CharacterProgressionService _characterProgressionService;
  final BattlePotionLoadoutService _battlePotionLoadoutService;
  final BattleProgressionService _battleProgressionService;

  SessionState buildRewardedState({
    required SessionState started,
    required String stageId,
    required BattleStageDefinition stage,
    required BattleEncounterResolution resolution,
    required BattleEncounterOutcome outcome,
    required Map<String, int> materials,
    required List<String> assignedCharacterIds,
    required DateTime resolvedAt,
  }) {
    final ProgressState nextProgress = _battleProgressionService
        .applyStageEncounterResult(
          currentProgress: started.battle.progress,
          stage: stage,
          success: outcome.success,
          battleCatalogRepository: _battleCatalogRepository,
        );
    return started.copyWith(
      workshop: _battlePotionLoadoutService.consumeLoadout(
        workshop: started.workshop,
        appliedLoadout: resolution.consumedPotionLoadout,
      ),
      characters: outcome.success
          ? _characterProgressionService.grantBattleXp(
              state: started.characters,
              xpGain: stage.xpSuccessBase,
              participantIds: assignedCharacterIds,
            )
          : started.characters,
      battle: started.battle.copyWith(
        progress: nextProgress,
        stageExpeditions: <String, BattleExpeditionState>{
          ...started.battle.stageExpeditions,
          stageId: BattleExpeditionState(
            status: BattleExpeditionStatus.idle,
            lastProgressedAt: resolvedAt,
            phaseProgress: Duration.zero,
            pendingClaim: BattlePendingClaim(
              materials: materials,
              gold: outcome.success ? stage.goldSuccess : 0,
              essence: outcome.success ? stage.essenceSuccess : 0,
              xp: outcome.success ? stage.xpSuccessBase : 0,
              victoryCount: outcome.success ? 1 : 0,
              wipeCount: outcome.wiped ? 1 : 0,
              hasSuccessfulBattle: outcome.success,
            ),
            recentLogs: <BattleLogEntry>[
              BattleLogEntry(
                resolvedAt: resolvedAt,
                encounterIndex: outcome.encounter.encounterIndex,
                success: outcome.success,
                wipedParty: outcome.wiped,
                gold: outcome.success ? stage.goldSuccess : 0,
                essence: outcome.success ? stage.essenceSuccess : 0,
                materials: materials,
                turns: outcome.encounter.turnInEncounter,
                actions: outcome.encounter.recentActionLogs,
                usedLoadoutFallback: outcome.encounter.usedLoadoutFallback,
              ),
              ...started.battle.stageExpeditions[stageId]?.recentLogs ??
                  const <BattleLogEntry>[],
            ].take(10).toList(growable: false),
          ),
        },
      ),
    );
  }
}
