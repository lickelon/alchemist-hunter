import 'package:flutter/foundation.dart';

enum ShopType { general, catalyst }

@immutable
class ShopItem {
  const ShopItem({
    required this.materialId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String materialId;
  final String name;
  final int price;
  final int quantity;
}

@immutable
class ShopState {
  const ShopState({
    required this.shopType,
    required this.items,
    required this.nextRefreshAt,
    required this.forcedRefreshCost,
    required this.baseRefreshCost,
    required this.refreshCostStep,
    required this.cycleRefreshCount,
  });

  final ShopType shopType;
  final List<ShopItem> items;
  final DateTime nextRefreshAt;
  final int forcedRefreshCost;
  final int baseRefreshCost;
  final int refreshCostStep;
  final int cycleRefreshCount;

  ShopState copyWith({
    List<ShopItem>? items,
    DateTime? nextRefreshAt,
    int? forcedRefreshCost,
    int? cycleRefreshCount,
  }) {
    return ShopState(
      shopType: shopType,
      items: items ?? this.items,
      nextRefreshAt: nextRefreshAt ?? this.nextRefreshAt,
      forcedRefreshCost: forcedRefreshCost ?? this.forcedRefreshCost,
      baseRefreshCost: baseRefreshCost,
      refreshCostStep: refreshCostStep,
      cycleRefreshCount: cycleRefreshCount ?? this.cycleRefreshCount,
    );
  }
}
