import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/services/character_progression_service.dart';

class AutoBattleUseCase {
  const AutoBattleUseCase({
    CharacterProgressionService characterProgressionService =
        const CharacterProgressionService(),
    BattlePartyPowerService battlePartyPowerService =
        const BattlePartyPowerService(),
  }) : _characterProgressionService = characterProgressionService,
       _battlePartyPowerService = battlePartyPowerService;

  final CharacterProgressionService _characterProgressionService;
  final BattlePartyPowerService _battlePartyPowerService;

  SessionState runAutoBattle({
    required SessionState state,
    required String stageId,
    required BattleService battleService,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    final List<String> assignedCharacterIds = state.battle.stageAssignments[stageId] ??
        const <String>[];
    if (assignedCharacterIds.isEmpty) {
      return state;
    }

    final BattleResult result = battleService.runAutoBattle(
      config: AutoBattleConfig(
        party: _battlePartyPowerService.buildParty(
          state.characters,
          assignedCharacterIds: assignedCharacterIds,
        ),
        potionLoadout: const <String, int>{'p_1': 2, 'p_2': 1},
        stageId: stageId,
      ),
      dropTable: battleCatalogRepository.dropTable(stageId),
    );

    final Map<String, int> inventory = <String, int>{
      ...state.player.materialInventory,
    };
    result.loot.forEach((String materialId, int quantity) {
      inventory[materialId] = (inventory[materialId] ?? 0) + quantity;
    });

    final Set<String> unlocks = <String>{...state.battle.progress.unlockFlags};
    if ((result.loot['m_27'] ?? 0) > 0) {
      unlocks.add('potion_special_1');
    }
    if ((result.loot['m_30'] ?? 0) > 0) {
      unlocks.add('potion_special_2');
      unlocks.add('stage_2');
    }

    final int nextGold =
        state.player.gold - result.failurePenalty + (result.success ? 35 : 0);
    final int essenceGain = result.success ? 6 : 2;
    final int xpGain = _xpGainForStage(
      stageId: stageId,
      success: result.success,
    );
    final CharactersState nextCharacters = _characterProgressionService
        .grantBattleXp(
          state: state.characters,
          xpGain: xpGain,
          participantIds: assignedCharacterIds,
        );

    return state.copyWith(
      player: state.player.copyWith(
        gold: nextGold,
        essence: state.player.essence + essenceGain,
        materialInventory: inventory,
      ),
      battle: state.battle.copyWith(
        progress: ProgressState(
          unlockFlags: unlocks,
          automationTier: state.battle.progress.automationTier,
          sessionPhase: state.battle.progress.sessionPhase,
        ),
      ),
      characters: nextCharacters,
    );
  }

  int _xpGainForStage({required String stageId, required bool success}) {
    final int stageNumber =
        int.tryParse(stageId.replaceFirst('stage_', '')) ?? 1;
    if (success) {
      return 16 + (stageNumber * 4);
    }
    return 6 + (stageNumber * 2);
  }
}
