import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';

class BattleEncounterResolution {
  const BattleEncounterResolution({
    required this.playback,
    required this.summary,
  });

  final BattlePlaybackState? playback;
  final String summary;
}

abstract class BattleExpeditionResolver {
  BattleEncounterResolution resolveEncounter({
    required SessionState state,
    required String stageId,
    required BattleCatalogRepository battleCatalogRepository,
  });
}

class DefaultBattleExpeditionResolver implements BattleExpeditionResolver {
  DefaultBattleExpeditionResolver({
    BattleService? battleService,
    BattlePartyPowerService battlePartyPowerService =
        const BattlePartyPowerService(),
  }) : _battleService = battleService ?? BattleService(),
       _battlePartyPowerService = battlePartyPowerService;

  final BattleService _battleService;
  final BattlePartyPowerService _battlePartyPowerService;

  @override
  BattleEncounterResolution resolveEncounter({
    required SessionState state,
    required String stageId,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    final List<String> assignedCharacterIds =
        state.battle.stageAssignments[stageId] ?? const <String>[];
    final Map<String, int> potionLoadout =
        state.battle.stagePotionLoadouts[stageId] ?? const <String, int>{};
    if (assignedCharacterIds.isEmpty) {
      return const BattleEncounterResolution(playback: null, summary: '편성 없음');
    }

    final BattleStageDefinition stageDefinition = battleCatalogRepository
        .stageDefinition(stageId);

    final BattleResult result = _battleService.runAutoBattle(
      config: AutoBattleConfig(
        party: _battlePartyPowerService.buildParty(
          state.characters,
          assignedCharacterIds: assignedCharacterIds,
        ),
        potionLoadout: potionLoadout,
        stageId: stageId,
      ),
      stage: stageDefinition,
      enemies: battleCatalogRepository.enemyDefinitionsForStage(stageId),
      dropTable: battleCatalogRepository.dropTable(stageId),
    );

    final Map<String, int> characterXp = result.success
        ? <String, int>{
            for (final String characterId in assignedCharacterIds)
              characterId: stageDefinition.xpSuccessBase,
          }
        : const <String, int>{};
    final int gold = result.success ? stageDefinition.goldSuccess : 0;
    final int essence = result.success ? stageDefinition.essenceSuccess : 0;
    final BattlePendingClaim pendingClaim = BattlePendingClaim(
      materials: result.loot,
      gold: gold,
      essence: essence,
      characterXp: characterXp,
      hasSuccessfulBattle: result.success,
    );
    final BattlePlaybackState playback = BattlePlaybackState(
      success: result.success,
      turns: result.turns,
      pendingClaim: pendingClaim,
      actions: result.actions,
    );

    return BattleEncounterResolution(
      playback: playback,
      summary:
          '${playback.success ? '성공' : '실패'} / 골드 ${gold >= 0 ? '+' : ''}$gold / 에센스 ${essence >= 0 ? '+' : ''}$essence / 재료 ${pendingClaim.materials.length}종',
    );
  }
}
