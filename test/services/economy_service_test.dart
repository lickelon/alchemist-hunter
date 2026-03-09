import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/town/application/services/economy_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final EconomyService service = EconomyService();

  test('forced refresh cost increases within cycle', () {
    final DateTime now = DateTime(2026, 1, 1, 10);
    final ShopState state = ShopState(
      shopType: ShopType.general,
      items: const <ShopItem>[],
      nextRefreshAt: now.add(const Duration(minutes: 10)),
      forcedRefreshCost: 20,
      baseRefreshCost: 20,
      refreshCostStep: 5,
      cycleRefreshCount: 0,
    );

    final ({ShopState shop, int costPaid}) result = service.forceRefresh(
      shop: state,
      now: now,
      nextItems: const <ShopItem>[],
    );

    expect(result.costPaid, 20);
    expect(result.shop.forcedRefreshCost, 25);
    expect(result.shop.cycleRefreshCount, 1);
  });

  test('auto refresh resets cost and cycle count', () {
    final DateTime now = DateTime(2026, 1, 1, 10, 30);
    final ShopState state = ShopState(
      shopType: ShopType.general,
      items: const <ShopItem>[],
      nextRefreshAt: DateTime(2026, 1, 1, 10, 0),
      forcedRefreshCost: 50,
      baseRefreshCost: 20,
      refreshCostStep: 5,
      cycleRefreshCount: 3,
    );

    final ({ShopState shop, bool refreshed}) result = service.applyAutoRefresh(
      shop: state,
      now: now,
      nextItems: const <ShopItem>[ShopItem(materialId: 'm_1', name: 'M1', price: 10, quantity: 1)],
      refreshInterval: const Duration(minutes: 15),
    );

    expect(result.refreshed, true);
    expect(result.shop.forcedRefreshCost, 20);
    expect(result.shop.cycleRefreshCount, 0);
    expect(result.shop.nextRefreshAt, now.add(const Duration(minutes: 15)));
  });
}
