import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';

class BattleCycleResolution {
  const BattleCycleResolution({
    required this.pendingClaim,
    required this.summary,
  });

  final BattlePendingClaim pendingClaim;
  final String summary;
}

abstract class BattleExpeditionResolver {
  BattleCycleResolution resolveCycle({
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
  BattleCycleResolution resolveCycle({
    required SessionState state,
    required String stageId,
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

    final BattleResult result = _battleService.runAutoBattle(
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

    final int stageNumber =
        int.tryParse(stageId.replaceFirst('stage_', '')) ?? 1;
    final int xpGain = result.success ? 16 + (stageNumber * 4) : 6 + (stageNumber * 2);
    final Map<String, int> characterXp = <String, int>{
      for (final String characterId in assignedCharacterIds) characterId: xpGain,
    };
    final int gold = result.success ? 35 : -result.failurePenalty;
    final int essence = result.success ? 6 : 2;

    return BattleCycleResolution(
      pendingClaim: BattlePendingClaim(
        materials: result.loot,
        gold: gold,
        essence: essence,
        characterXp: characterXp,
      ),
      summary:
          '${result.success ? '성공' : '실패'} / Gold ${gold >= 0 ? '+' : ''}$gold / Essence +$essence / 재료 ${result.loot.length}종',
    );
  }
}
