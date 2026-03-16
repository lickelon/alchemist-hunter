import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/services/character_progression_service.dart';

class BattleExpeditionUseCase {
  const BattleExpeditionUseCase({
    CharacterProgressionService characterProgressionService =
        const CharacterProgressionService(),
  }) : _characterProgressionService = characterProgressionService;

  final CharacterProgressionService _characterProgressionService;

  SessionState startExpedition({
    required SessionState state,
    required String stageId,
    required DateTime now,
  }) {
    final List<String> assigned = state.battle.stageAssignments[stageId] ??
        const <String>[];
    if (assigned.isEmpty) {
      return state;
    }
    final BattleExpeditionState current = state.battle.stageExpeditions[stageId] ??
        const BattleExpeditionState(
          status: BattleExpeditionStatus.idle,
          lastResolvedAt: null,
          cycleProgress: Duration.zero,
        );
    if (current.status == BattleExpeditionStatus.running) {
      return state;
    }
    final Map<String, BattleExpeditionState> nextExpeditions =
        <String, BattleExpeditionState>{...state.battle.stageExpeditions};
    nextExpeditions[stageId] = current.copyWith(
      status: BattleExpeditionStatus.running,
      lastResolvedAt: now,
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
    final BattleExpeditionState? current = state.battle.stageExpeditions[stageId];
    if (current == null || current.status != BattleExpeditionStatus.running) {
      return state;
    }
    final Map<String, BattleExpeditionState> nextExpeditions =
        <String, BattleExpeditionState>{...state.battle.stageExpeditions};
    nextExpeditions[stageId] = current.copyWith(
      status: BattleExpeditionStatus.paused,
      lastResolvedAt: now,
    );
    return state.copyWith(
      battle: state.battle.copyWith(stageExpeditions: nextExpeditions),
    );
  }

  SessionState claimStageRewards({
    required SessionState state,
    required String stageId,
  }) {
    final BattleExpeditionState? expedition = state.battle.stageExpeditions[stageId];
    if (expedition == null || expedition.pendingClaim.isEmpty) {
      return state;
    }

    final Map<String, int> materialInventory = <String, int>{
      ...state.player.materialInventory,
    };
    expedition.pendingClaim.materials.forEach((String materialId, int quantity) {
      materialInventory[materialId] = (materialInventory[materialId] ?? 0) + quantity;
    });

    final Set<String> unlocks = <String>{...state.battle.progress.unlockFlags};
    if ((expedition.pendingClaim.materials['m_27'] ?? 0) > 0) {
      unlocks.add('potion_special_1');
    }
    if ((expedition.pendingClaim.materials['m_30'] ?? 0) > 0) {
      unlocks.add('potion_special_2');
      unlocks.add('stage_2');
    }

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
