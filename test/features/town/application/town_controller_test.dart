import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/town/application/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/application/town_controller.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionController buildSession({DateTime? now}) {
    return SessionController(clock: () => now ?? DateTime(2026, 1, 1, 10));
  }

  TownController buildController(SessionController session) {
    return TownController(session, EconomyService());
  }

  test('buyGeneralMaterial updates gold inventory and shop stock', () {
    final SessionController session = buildSession();
    final TownController controller = buildController(session);

    final ShopItem item = session.state.town.generalShop.items.first;
    controller.buyGeneralMaterial(item.materialId, 2);

    expect(session.state.player.gold, 1400);
    expect(session.state.player.materialInventory[item.materialId], 2);
    expect(
      session.state.town.generalShop.items
          .firstWhere(
            (ShopItem current) => current.materialId == item.materialId,
          )
          .quantity,
      18,
    );
    expect(
      session.state.workshop.logs.first,
      'Bought 2 of ${item.materialId} (general)',
    );
  });

  test('forceRefresh updates shop and consumes gold', () {
    final SessionController session = buildSession();
    final TownController controller = buildController(session);
    final int previousGold = session.state.player.gold;
    final DateTime previousRefreshAt =
        session.state.town.generalShop.nextRefreshAt;

    controller.forceRefresh(ShopType.general);

    expect(session.state.player.gold, previousGold - 25);
    expect(session.state.town.generalShop.cycleRefreshCount, 1);
    expect(session.state.town.generalShop.nextRefreshAt, previousRefreshAt);
    expect(session.state.workshop.logs.first, 'Forced refresh general shop');
  });

  test('syncShopAutoRefresh refreshes overdue shop state', () {
    final SessionController session = buildSession(
      now: DateTime(2026, 1, 1, 10, 30),
    );
    final TownController controller = buildController(session);

    session.state = session.state.copyWith(
      town: session.state.town.copyWith(
        generalShop: session.state.town.generalShop.copyWith(
          nextRefreshAt: DateTime(2026, 1, 1, 10),
          forcedRefreshCost: 55,
          cycleRefreshCount: 2,
        ),
      ),
    );

    controller.syncShopAutoRefresh();

    expect(
      session.state.town.generalShop.nextRefreshAt,
      DateTime(2026, 1, 1, 10, 45),
    );
    expect(session.state.town.generalShop.forcedRefreshCost, 25);
    expect(session.state.town.generalShop.cycleRefreshCount, 0);
    expect(session.state.workshop.logs.first, 'Auto refresh executed');
  });

  test('sellCraftedPotion removes stack and adds gold', () {
    final SessionController session = buildSession();
    final TownController controller = buildController(session);
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
      startsWith('Sold potion $stackKey x1 for '),
    );
  });
}
