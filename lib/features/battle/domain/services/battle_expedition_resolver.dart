import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';

class BattleCycleResolution {
  const BattleCycleResolution({
    required this.pendingClaim,
    required this.summary,
    this.logEntry,
  });

  final BattlePendingClaim pendingClaim;
  final String summary;
  final BattleLogEntry? logEntry;
}

abstract class BattleExpeditionResolver {
  BattleCycleResolution resolveCycle({
    required SessionState state,
    required String stageId,
    required DateTime resolvedAt,
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
  BattleCycleResolution resolveCycle({
    required SessionState state,
    required String stageId,
    required DateTime resolvedAt,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    final List<String> assignedCharacterIds =
        state.battle.stageAssignments[stageId] ?? const <String>[];
    if (assignedCharacterIds.isEmpty) {
      return const BattleCycleResolution(
        pendingClaim: BattlePendingClaim(),
        summary: '편성 없음',
      );
    }

    final BattleStageDefinition stageDefinition = battleCatalogRepository
        .stageDefinition(stageId);

    final BattleResult result = _battleService.runAutoBattle(
      config: AutoBattleConfig(
        party: _battlePartyPowerService.buildParty(
          state.characters,
          assignedCharacterIds: assignedCharacterIds,
        ),
        potionLoadout: const <String, int>{'p_1': 2, 'p_2': 1},
        stageId: stageId,
      ),
      stage: stageDefinition,
      enemies: battleCatalogRepository.enemyDefinitionsForStage(stageId),
      dropTable: battleCatalogRepository.dropTable(stageId),
    );

    final int xpGain = result.success
        ? stageDefinition.xpSuccessBase
        : stageDefinition.xpFailureBase;
    final Map<String, int> characterXp = <String, int>{
      for (final String characterId in assignedCharacterIds)
        characterId: xpGain,
    };
    final int gold = result.success
        ? stageDefinition.goldSuccess
        : -result.failurePenalty;
    final int essence = result.success
        ? stageDefinition.essenceSuccess
        : stageDefinition.essenceFailure;
    final BattleLogEntry logEntry = BattleLogEntry(
      resolvedAt: resolvedAt,
      success: result.success,
      gold: gold,
      essence: essence,
      materials: result.loot,
      turns: result.turns,
      actions: result.actions,
    );

    return BattleCycleResolution(
      pendingClaim: BattlePendingClaim(
        materials: result.loot,
        gold: gold,
        essence: essence,
        characterXp: characterXp,
      ),
      summary:
          '${logEntry.success ? '성공' : '실패'} / Gold ${gold >= 0 ? '+' : ''}$gold / Essence +$essence / 재료 ${logEntry.materials.length}종',
      logEntry: logEntry,
    );
  }
}
