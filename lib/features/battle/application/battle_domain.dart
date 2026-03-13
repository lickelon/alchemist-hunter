import 'package:alchemist_hunter/features/battle/application/services/battle_service.dart';
import 'package:alchemist_hunter/features/characters/application/character_progression_service.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/data/dummy_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class BattleDomain {
  const BattleDomain({
    CharacterProgressionService characterProgressionService =
        const CharacterProgressionService(),
  }) : _characterProgressionService = characterProgressionService;

  final CharacterProgressionService _characterProgressionService;

  SessionState runAutoBattle({
    required SessionState state,
    required String stageId,
    required BattleService battleService,
  }) {
    final BattleResult result = battleService.runAutoBattle(
      config: AutoBattleConfig(
        party: const <HeroProfile>[
          HeroProfile(id: 'h1', name: 'Alchemist', power: 120),
          HeroProfile(id: 'h2', name: 'Hunter', power: 110),
        ],
        potionLoadout: const <String, int>{'p_1': 2, 'p_2': 1},
        stageId: stageId,
      ),
      dropTable: DummyData.dropTable(stageId),
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
        .grantBattleXp(state: state.characters, xpGain: xpGain);

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
