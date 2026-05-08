import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_potion_loadout_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_progression_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/services/character_progression_service.dart';

class AutoBattleUseCase {
  const AutoBattleUseCase({
    CharacterProgressionService characterProgressionService =
        const CharacterProgressionService(),
    BattlePartyPowerService battlePartyPowerService =
        const BattlePartyPowerService(),
    BattleProgressionService battleProgressionService =
        const BattleProgressionService(),
    BattlePotionLoadoutService battlePotionLoadoutService =
        const BattlePotionLoadoutService(),
  }) : _characterProgressionService = characterProgressionService,
       _battlePartyPowerService = battlePartyPowerService,
       _battleProgressionService = battleProgressionService,
       _battlePotionLoadoutService = battlePotionLoadoutService;

  final CharacterProgressionService _characterProgressionService;
  final BattlePartyPowerService _battlePartyPowerService;
  final BattleProgressionService _battleProgressionService;
  final BattlePotionLoadoutService _battlePotionLoadoutService;

  SessionState runAutoBattle({
    required SessionState state,
    required String stageId,
    required BattleService battleService,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    final List<String> assignedCharacterIds =
        state.battle.stageAssignments[stageId] ?? const <String>[];
    final Map<String, int> potionLoadout =
        state.battle.stagePotionLoadouts[stageId] ?? const <String, int>{};
    if (assignedCharacterIds.isEmpty) {
      return state;
    }

    final BattleStageDefinition stageDefinition = battleCatalogRepository
        .stageDefinition(stageId);

    final ResolvedBattlePotionLoadout resolvedLoadout =
        _battlePotionLoadoutService.resolveLoadout(
          requestedLoadout: potionLoadout,
          ownedStacks: state.workshop.craftedPotionStacks,
        );

    final BattleResult result = battleService.runAutoBattle(
      config: AutoBattleConfig(
        party: _battlePartyPowerService.buildParty(
          state.characters,
          assignedCharacterIds: assignedCharacterIds,
        ),
        potionLoadout: resolvedLoadout.appliedLoadout,
        stageId: stageId,
      ),
      stage: stageDefinition,
      enemies: battleCatalogRepository.enemyDefinitionsForStage(stageId),
      dropTable: battleCatalogRepository.dropTable(stageId),
    );

    final Map<String, int> inventory = <String, int>{
      ...state.player.materialInventory,
    };
    result.loot.forEach((String materialId, int quantity) {
      inventory[materialId] = (inventory[materialId] ?? 0) + quantity;
    });

    final ProgressState nextProgress = _battleProgressionService
        .applyStageClearUnlocks(
          currentProgress: state.battle.progress,
          clearedStage: stageDefinition,
          success: result.success,
        );

    final int nextGold =
        state.player.gold + (result.success ? stageDefinition.goldSuccess : 0);
    final int essenceGain = result.success ? stageDefinition.essenceSuccess : 0;
    final int xpGain = result.success ? stageDefinition.xpSuccessBase : 0;
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
      workshop: _battlePotionLoadoutService.consumeLoadout(
        workshop: state.workshop,
        appliedLoadout: resolvedLoadout.appliedLoadout,
      ),
      battle: state.battle.copyWith(
        progress: nextProgress,
      ),
      characters: nextCharacters,
    );
  }
}
