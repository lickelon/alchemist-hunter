import 'package:alchemist_hunter/features/game/domain/models.dart';
import 'package:alchemist_hunter/features/game/services/economy_service.dart';
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
}
