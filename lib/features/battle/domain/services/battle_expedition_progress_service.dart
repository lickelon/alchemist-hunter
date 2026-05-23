import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_tick_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';

class BattleExpeditionSyncResult {
  const BattleExpeditionSyncResult({
    required this.battle,
    required this.characters,
    this.consumedPotionStacks = const <String, int>{},
  });

  final BattleState battle;
  final CharactersState characters;
  final Map<String, int> consumedPotionStacks;
}

class BattleExpeditionProgressService {
  const BattleExpeditionProgressService({
    BattleExpeditionTickService tickService =
        const BattleExpeditionTickService(),
  }) : _tickService = tickService;

  final BattleExpeditionTickService _tickService;

  BattleExpeditionSyncResult syncExpeditions({
    required SessionState state,
    required DateTime syncFrom,
    required DateTime now,
    required double speedMultiplier,
    required Duration battleActionInterval,
    required BattleExpeditionResolver battleExpeditionResolver,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    if (state.battle.stageExpeditions.isEmpty) {
      return BattleExpeditionSyncResult(
        battle: state.battle,
        characters: state.characters,
      );
    }

    final Map<String, BattleExpeditionState> nextExpeditions =
        <String, BattleExpeditionState>{...state.battle.stageExpeditions};
    final Map<String, int> consumedPotionStacks = <String, int>{};
    CharactersState nextCharacters = state.characters;
    ProgressState nextProgress = state.battle.progress;

    state.battle.stageExpeditions.forEach((
      String stageId,
      BattleExpeditionState expedition,
    ) {
      final List<String> assignedCharacterIds =
          state.battle.stageAssignments[stageId] ?? const <String>[];
      final BattleExpeditionTickResult result = _tickService.tick(
        state: state,
        stageId: stageId,
        expedition: expedition,
        assignedCharacterIds: assignedCharacterIds,
        characters: nextCharacters,
        progress: nextProgress,
        syncFrom: syncFrom,
        now: now,
        speedMultiplier: speedMultiplier,
        battleActionInterval: battleActionInterval,
        battleExpeditionResolver: battleExpeditionResolver,
        battleCatalogRepository: battleCatalogRepository,
      );
      nextExpeditions[stageId] = result.expedition;
      nextCharacters = result.characters;
      nextProgress = result.progress;
      result.consumedPotionStacks.forEach((String stackKey, int quantity) {
        consumedPotionStacks[stackKey] =
            (consumedPotionStacks[stackKey] ?? 0) + quantity;
      });
    });

    return BattleExpeditionSyncResult(
      battle: state.battle.copyWith(
        progress: nextProgress,
        stageExpeditions: nextExpeditions,
      ),
      characters: nextCharacters,
      consumedPotionStacks: consumedPotionStacks,
    );
  }
}
