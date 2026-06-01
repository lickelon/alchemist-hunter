import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/battle/expedition/domain/services/battle_expedition_progress_helpers.dart';
import 'package:alchemist_hunter/features/battle/expedition/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/battle/expedition/domain/services/battle_progression_service.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/services/character_progression_service.dart';

part 'battle_expedition_tick_frame.dart';
part 'battle_expedition_tick_encounter_results.dart';
part 'battle_expedition_tick_steps.dart';

class BattleExpeditionTickResult {
  const BattleExpeditionTickResult({
    required this.expedition,
    required this.characters,
    required this.progress,
    this.consumedPotionStacks = const <String, int>{},
  });

  final BattleExpeditionState expedition;
  final CharactersState characters;
  final ProgressState progress;
  final Map<String, int> consumedPotionStacks;
}

class BattleExpeditionTickService {
  const BattleExpeditionTickService({
    CharacterProgressionService characterProgressionService =
        const CharacterProgressionService(),
    BattleExpeditionProgressHelpers helpers =
        const BattleExpeditionProgressHelpers(),
    BattleProgressionService battleProgressionService =
        const BattleProgressionService(),
  }) : _characterProgressionService = characterProgressionService,
       _helpers = helpers,
       _battleProgressionService = battleProgressionService;

  final CharacterProgressionService _characterProgressionService;
  final BattleExpeditionProgressHelpers _helpers;
  final BattleProgressionService _battleProgressionService;

  BattleExpeditionTickResult tick({
    required SessionState state,
    required String stageId,
    required BattleExpeditionState expedition,
    required List<String> assignedCharacterIds,
    required CharactersState characters,
    required ProgressState progress,
    required DateTime syncFrom,
    required DateTime now,
    required double speedMultiplier,
    required Duration battleActionInterval,
    required BattleExpeditionResolver battleExpeditionResolver,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    if (assignedCharacterIds.isEmpty) {
      return BattleExpeditionTickResult(
        expedition: expedition.copyWith(
          status: BattleExpeditionStatus.idle,
          lastProgressedAt: now,
          phaseProgress: Duration.zero,
          clearRunState: true,
        ),
        characters: characters,
        progress: progress,
      );
    }
    if (!expedition.isActive) {
      return BattleExpeditionTickResult(
        expedition: expedition,
        characters: characters,
        progress: progress,
      );
    }

    final BattleStageDefinition stageDefinition = battleCatalogRepository
        .stageDefinition(stageId);
    final DateTime baseTime = _helpers.laterOf(
      syncFrom,
      expedition.lastProgressedAt ?? syncFrom,
    );
    if (!now.isAfter(baseTime)) {
      return BattleExpeditionTickResult(
        expedition: expedition.copyWith(lastProgressedAt: now),
        characters: characters,
        progress: progress,
      );
    }

    final _BattleExpeditionTickFrame frame = _BattleExpeditionTickFrame(
      state: state,
      stageId: stageId,
      assignedCharacterIds: assignedCharacterIds,
      stageDefinition: stageDefinition,
      battleActionInterval: battleActionInterval,
      speedMultiplier: speedMultiplier,
      battleExpeditionResolver: battleExpeditionResolver,
      battleCatalogRepository: battleCatalogRepository,
      nextCharacters: characters,
      nextProgress: progress,
      nextStatus: expedition.status,
      nextPhaseProgress: expedition.phaseProgress,
      runState: expedition.runState,
      pendingClaim: expedition.pendingClaim,
      recentLogs: expedition.recentLogs,
      remainingElapsed: _helpers.scaledDuration(
        now.difference(baseTime),
        speedMultiplier,
      ),
      cursorTime: baseTime,
    );

    while (frame.remainingElapsed > Duration.zero) {
      final bool shouldContinue = switch (frame.nextStatus) {
        BattleExpeditionStatus.searching => _tickSearching(frame),
        BattleExpeditionStatus.battling => _tickBattling(frame),
        BattleExpeditionStatus.recovering => _tickRecovering(frame),
        BattleExpeditionStatus.idle => false,
      };
      if (!shouldContinue) {
        break;
      }
    }

    return BattleExpeditionTickResult(
      expedition: expedition.copyWith(
        status: frame.nextStatus,
        lastProgressedAt: now,
        phaseProgress: frame.nextPhaseProgress,
        runState: frame.runState,
        pendingClaim: frame.pendingClaim.copyWith(
          elapsedRealTime: frame.pendingClaimElapsedRealTime,
        ),
        recentLogs: frame.recentLogs,
      ),
      characters: frame.nextCharacters,
      progress: frame.nextProgress,
      consumedPotionStacks: frame.consumedPotionStacks,
    );
  }
}
