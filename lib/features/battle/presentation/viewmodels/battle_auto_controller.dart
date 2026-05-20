import 'dart:math';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_potion_loadout_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_progression_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/battle/domain/use_cases/battle_expedition_use_case.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_display_labels.dart';
import 'package:alchemist_hunter/features/characters/domain/services/character_progression_service.dart';

class BattleAutoController {
  BattleAutoController(
    this._session, {
    BattleService? battleService,
    BattleExpeditionUseCase battleExpeditionUseCase =
        const BattleExpeditionUseCase(),
    CharacterProgressionService characterProgressionService =
        const CharacterProgressionService(),
    Random? encounterRandom,
    required BattleCatalogRepository battleCatalogRepository,
  }) : _battleService = battleService,
       _battleExpeditionUseCase = battleExpeditionUseCase,
       _characterProgressionService = characterProgressionService,
       _encounterRandom = encounterRandom ?? Random(),
       _battleCatalogRepository = battleCatalogRepository;

  final SessionController _session;
  final BattleService? _battleService;
  final BattleExpeditionUseCase _battleExpeditionUseCase;
  final CharacterProgressionService _characterProgressionService;
  final Random _encounterRandom;
  final BattleCatalogRepository _battleCatalogRepository;
  static const BattlePotionLoadoutService _battlePotionLoadoutService =
      BattlePotionLoadoutService();
  static const BattleProgressionService _battleProgressionService =
      BattleProgressionService();

  void runAutoBattle(String stageId) {
    final SessionState current = _session.snapshot();
    final BattleService battleService =
        _battleService ?? BattleService(random: Random(11));
    final SessionState started = _battleExpeditionUseCase.startExpedition(
      state: current,
      stageId: stageId,
      now: _session.now(),
    );
    if (identical(started, current)) {
      _session.appendLog('Battle assignment missing for $stageId');
      return;
    }

    final DefaultBattleExpeditionResolver resolver =
        DefaultBattleExpeditionResolver(
          battleService: battleService,
          random: _encounterRandom,
        );
    final BattleEncounterResolution resolution = resolver.resolveEncounter(
      state: started,
      stageId: stageId,
      battleCatalogRepository: _battleCatalogRepository,
    );
    final BattleRunState? runState = resolution.runState;
    final BattleEncounterRuntimeState? encounter = runState?.currentEncounter;
    if (runState == null || encounter == null) {
      _session.applyState(started);
      _session.appendLog('Battle encounter missing for $stageId');
      return;
    }

    final int potionBoost = encounter.appliedPotionLoadout.values.fold<int>(
      0,
      (int total, int value) => total + value,
    );
    final BattleEncounterOutcome outcome = battleService
        .runEncounterToCompletion(
          allies: runState.allies,
          encounter: encounter,
          potionBoost: potionBoost,
        );
    final BattleStageDefinition stage = _battleCatalogRepository
        .stageDefinition(stageId);
    final Map<String, int> materials = outcome.success
        ? resolver.resolveRewards(
            success: true,
            table: _battleCatalogRepository.dropTableForEnemySet(
              stageId: stageId,
              enemySetId: encounter.enemySetId,
            ),
          )
        : const <String, int>{};
    final List<String> assignedCharacterIds =
        started.battle.stageAssignments[stageId] ?? const <String>[];
    final ProgressState nextProgress = _battleProgressionService
        .applyStageEncounterResult(
          currentProgress: started.battle.progress,
          stage: stage,
          success: outcome.success,
          battleCatalogRepository: _battleCatalogRepository,
        );
    final SessionState rewardedState = started.copyWith(
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
            lastProgressedAt: _session.now(),
            phaseProgress: Duration.zero,
            pendingClaim: BattlePendingClaim(
              materials: materials,
              gold: outcome.success ? stage.goldSuccess : 0,
              essence: outcome.success ? stage.essenceSuccess : 0,
              hasSuccessfulBattle: outcome.success,
            ),
            recentLogs: <BattleLogEntry>[
              BattleLogEntry(
                resolvedAt: _session.now(),
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
    final SessionState claimedState = _battleExpeditionUseCase
        .claimStageRewards(
          state: rewardedState,
          stageId: stageId,
          battleCatalogRepository: _battleCatalogRepository,
        );
    _session.applyState(claimedState);
    _session.appendLog(
      'Battle ${battleStageDisplayName(stage.id, fallback: stage.name)} / ${outcome.success ? '성공' : '실패'}${encounter.usedLoadoutFallback ? ' / 포션 부족' : ''}',
    );
  }
}
