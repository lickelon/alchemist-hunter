import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_potion_sale_controller.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/catalog_fixtures.dart';

void main() {
  SessionController buildSession() {
    final DateTime now = DateTime(2026, 1, 1, 10);
    return SessionController(
      initialState: createTestInitialSessionState(now),
      clock: () => now,
    );
  }

  test('sellCraftedPotion removes stack and adds gold', () {
    final SessionController session = buildSession();
    final TownPotionSaleController controller = TownPotionSaleController(
      session,
      potionCatalogRepository: testPotionCatalogRepository,
      townSkillTreeRepository: testTownSkillTreeRepository,
      townSkillTreeService: const TownSkillTreeService(),
    );
    const String stackKey = 'p_1|a';
    final CraftedPotion sample = CraftedPotion(
      id: 'crafted_1',
      typePotionId: 'p_1',
      qualityGrade: PotionQualityGrade.a,
      qualityScore: 0.82,
      traits: const <String, double>{'t_hp': 0.6, 't_atk': 0.4},
      createdAt: DateTime(2026, 1, 1, 10),
    );

    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        craftedPotionStacks: const <String, int>{stackKey: 1},
        craftedPotionDetails: <String, CraftedPotion>{stackKey: sample},
      ),
    );

    final int previousGold = session.state.player.gold;
    controller.sellCraftedPotion(stackKey, 1);

    expect(session.state.player.gold, greaterThan(previousGold));
    expect(
      session.state.workshop.craftedPotionStacks.containsKey(stackKey),
      false,
    );
    expect(
      session.state.workshop.logs.first,
      startsWith('포션 판매 / $stackKey x1 / 골드 +'),
    );
  });

  test('sellCraftedPotion applies trade ledger sale bonus', () {
    final SessionController session = buildSession();
    final TownPotionSaleController controller = TownPotionSaleController(
      session,
      potionCatalogRepository: testPotionCatalogRepository,
      townSkillTreeRepository: testTownSkillTreeRepository,
      townSkillTreeService: const TownSkillTreeService(),
    );
    const String stackKey = 'p_1|a';
    final CraftedPotion sample = CraftedPotion(
      id: 'crafted_1',
      typePotionId: 'p_1',
      qualityGrade: PotionQualityGrade.a,
      qualityScore: 0.82,
      traits: const <String, double>{'t_hp': 0.6, 't_atk': 0.4},
      createdAt: DateTime(2026, 1, 1, 10),
    );

    session.state = session.state.copyWith(
      town: session.state.town.copyWith(
        skillTree: session.state.town.skillTree.copyWith(
          nodeLevels: const <String, int>{'town_trade_ledger': 1},
          unlockedNodes: const <String>{'town_trade_ledger'},
        ),
      ),
      workshop: session.state.workshop.copyWith(
        craftedPotionStacks: const <String, int>{stackKey: 1},
        craftedPotionDetails: <String, CraftedPotion>{stackKey: sample},
      ),
    );

    final int previousGold = session.state.player.gold;
    controller.sellCraftedPotion(stackKey, 1);

    expect(session.state.player.gold - previousGold, 137);
  });
}
