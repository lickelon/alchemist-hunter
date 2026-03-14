import 'package:flutter_test/flutter_test.dart';

import 'package:alchemist_hunter/app/session/session_factory.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/upgrade_town_skill_node_use_case.dart';

void main() {
  test('upgrade town root node consumes insight and increases level', () {
    final useCase = UpgradeTownSkillNodeUseCase();
    final state = createInitialSessionState(DateTime(2026, 1, 1, 10));

    final nextState = useCase.upgradeNode(
      state: state,
      nodeId: 'town_trade_ledger',
      repository: const StaticTownSkillTreeRepository(),
      service: const TownSkillTreeService(),
    );

    expect(nextState.player.townInsight, 1);
    expect(nextState.player.gold, 1500);
    expect(nextState.town.skillTree.nodeLevels['town_trade_ledger'], 1);
    expect(nextState.town.skillTree.spentPoints, 1);
  });

  test('upgrade town node consumes gold on next level cost', () {
    final useCase = UpgradeTownSkillNodeUseCase();
    final state = createInitialSessionState(DateTime(2026, 1, 1, 10)).copyWith(
      player: createInitialSessionState(
        DateTime(2026, 1, 1, 10),
      ).player.copyWith(gold: 2000, townInsight: 5),
      town: createInitialSessionState(
        DateTime(2026, 1, 1, 10),
      ).town.copyWith(
        skillTree: createInitialSessionState(
          DateTime(2026, 1, 1, 10),
        ).town.skillTree.copyWith(
          nodeLevels: const <String, int>{'town_trade_ledger': 1},
          unlockedNodes: const <String>{
            'town_trade_ledger',
            'town_hiring_board',
            'town_forge_rack',
          },
        ),
      ),
    );

    final nextState = useCase.upgradeNode(
      state: state,
      nodeId: 'town_trade_ledger',
      repository: const StaticTownSkillTreeRepository(),
      service: const TownSkillTreeService(),
    );

    expect(nextState.player.townInsight, 3);
    expect(nextState.player.gold, 1850);
    expect(nextState.town.skillTree.nodeLevels['town_trade_ledger'], 2);
  });
}
