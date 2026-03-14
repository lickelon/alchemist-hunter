import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class EconomyService {
  int sellPotion({required PotionBlueprint blueprint, required int quantity}) {
    if (quantity < 1) {
      throw ArgumentError('quantity must be >= 1');
    }
    return blueprint.baseValue * quantity;
  }

  ({int remainingGold, List<ShopItem> purchased}) buyMaterial({
    required int currentGold,
    required List<ShopItem> items,
    required String itemId,
    required int quantity,
  }) {
    if (quantity < 1) {
      throw ArgumentError('quantity must be >= 1');
    }

    final ShopItem item = items.firstWhere(
      (ShopItem i) => i.materialId == itemId,
      orElse: () => throw ArgumentError('item not found: $itemId'),
    );

    if (item.quantity < quantity) {
      throw StateError('not enough quantity');
    }

    final int cost = item.price * quantity;
    if (currentGold < cost) {
      throw StateError('not enough gold');
    }

    final List<ShopItem> next = items
        .map(
          (ShopItem i) => i.materialId == itemId
              ? ShopItem(
                  materialId: i.materialId,
                  name: i.name,
                  price: i.price,
                  quantity: i.quantity - quantity,
                )
              : i,
        )
        .toList();

    return (remainingGold: currentGold - cost, purchased: next);
  }

  ({ShopState shop, int costPaid}) forceRefresh({
    required ShopState shop,
    required DateTime now,
    required List<ShopItem> nextItems,
  }) {
    ShopState normalized = shop;
    if (now.isAfter(shop.nextRefreshAt) ||
        now.isAtSameMomentAs(shop.nextRefreshAt)) {
      normalized = shop.copyWith(
        cycleRefreshCount: 0,
        forcedRefreshCost: shop.baseRefreshCost,
      );
    }

    final int paid = normalized.forcedRefreshCost;
    final int nextCount = normalized.cycleRefreshCount + 1;
    final int nextCost =
        normalized.baseRefreshCost + (normalized.refreshCostStep * nextCount);

    return (
      shop: normalized.copyWith(
        items: nextItems,
        cycleRefreshCount: nextCount,
        forcedRefreshCost: nextCost,
      ),
      costPaid: paid,
    );
  }

  ({ShopState shop, bool refreshed}) applyAutoRefresh({
    required ShopState shop,
    required DateTime now,
    required List<ShopItem> nextItems,
    required Duration refreshInterval,
  }) {
    if (now.isBefore(shop.nextRefreshAt)) {
      return (shop: shop, refreshed: false);
    }

    return (
      shop: shop.copyWith(
        items: nextItems,
        nextRefreshAt: now.add(refreshInterval),
        forcedRefreshCost: shop.baseRefreshCost,
        cycleRefreshCount: 0,
      ),
      refreshed: true,
    );
  }
}
