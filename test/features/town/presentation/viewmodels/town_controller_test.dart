import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_controller.dart';
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
}
