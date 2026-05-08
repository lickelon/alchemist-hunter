import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_progression_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/services/character_progression_service.dart';

class BattleExpeditionUseCase {
  const BattleExpeditionUseCase({
    CharacterProgressionService characterProgressionService =
        const CharacterProgressionService(),
    BattleProgressionService battleProgressionService =
        const BattleProgressionService(),
  }) : _characterProgressionService = characterProgressionService,
       _battleProgressionService = battleProgressionService;

  final CharacterProgressionService _characterProgressionService;
  final BattleProgressionService _battleProgressionService;

  SessionState startExpedition({
    required SessionState state,
    required String stageId,
    required DateTime now,
  }) {
    final List<String> assigned =
        state.battle.stageAssignments[stageId] ?? const <String>[];
    if (assigned.isEmpty) {
      return state;
    }
    final BattleExpeditionState current =
        state.battle.stageExpeditions[stageId] ??
        const BattleExpeditionState(
          status: BattleExpeditionStatus.idle,
          lastProgressedAt: null,
          phaseProgress: Duration.zero,
        );
    if (current.isActive) {
      return state;
    }
    final BattleExpeditionStatus nextStatus = current.currentBattle == null
        ? BattleExpeditionStatus.searching
        : BattleExpeditionStatus.battling;
    final Map<String, BattleExpeditionState> nextExpeditions =
        <String, BattleExpeditionState>{...state.battle.stageExpeditions};
    nextExpeditions[stageId] = current.copyWith(
      status: nextStatus,
      lastProgressedAt: now,
    );
    return state.copyWith(
      battle: state.battle.copyWith(stageExpeditions: nextExpeditions),
    );
  }

  SessionState stopExpedition({
    required SessionState state,
    required String stageId,
    required DateTime now,
  }) {
    final BattleExpeditionState? current =
        state.battle.stageExpeditions[stageId];
    if (current == null || !current.isActive) {
      return state;
    }
    final Map<String, BattleExpeditionState> nextExpeditions =
        <String, BattleExpeditionState>{...state.battle.stageExpeditions};
    nextExpeditions[stageId] = current.copyWith(
      status: BattleExpeditionStatus.paused,
      lastProgressedAt: now,
    );
    return state.copyWith(
      battle: state.battle.copyWith(stageExpeditions: nextExpeditions),
    );
  }

  SessionState claimStageRewards({
    required SessionState state,
    required String stageId,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    final BattleExpeditionState? expedition =
        state.battle.stageExpeditions[stageId];
    if (expedition == null || expedition.pendingClaim.isEmpty) {
      return state;
    }

    final Map<String, int> materialInventory = <String, int>{
      ...state.player.materialInventory,
    };
    expedition.pendingClaim.materials.forEach((
      String materialId,
      int quantity,
    ) {
      materialInventory[materialId] =
          (materialInventory[materialId] ?? 0) + quantity;
    });

    final BattleStageDefinition stageDefinition = battleCatalogRepository
        .stageDefinition(stageId);
    final bool success = expedition.pendingClaim.hasSuccessfulBattle;
    final Set<String> unlocks = _battleProgressionService
        .applyStageClearUnlocks(
          currentUnlockFlags: state.battle.progress.unlockFlags,
          clearedStage: stageDefinition,
          success: success,
        );

    final CharactersState nextCharacters = _characterProgressionService
        .grantCharacterXpMap(
          state: state.characters,
          xpByCharacter: expedition.pendingClaim.characterXp,
        );
    final Map<String, BattleExpeditionState> nextExpeditions =
        <String, BattleExpeditionState>{...state.battle.stageExpeditions};
    nextExpeditions[stageId] = expedition.copyWith(
      pendingClaim: const BattlePendingClaim(),
    );

    return state.copyWith(
      player: state.player.copyWith(
        gold: state.player.gold + expedition.pendingClaim.gold,
        essence: state.player.essence + expedition.pendingClaim.essence,
        materialInventory: materialInventory,
      ),
      battle: state.battle.copyWith(
        stageExpeditions: nextExpeditions,
        progress: state.battle.progress.copyWith(unlockFlags: unlocks),
      ),
      characters: nextCharacters,
    );
  }
}
