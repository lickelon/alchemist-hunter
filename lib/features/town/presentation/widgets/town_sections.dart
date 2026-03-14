export 'town_equipment_card.dart';
export 'town_mercenary_card.dart';
export 'town_skill_tree_card.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/sheets/town_potion_sale_sheet.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/sheets/town_shop_sheet.dart';
import 'package:flutter/material.dart';

class TownShopCard extends StatelessWidget {
  const TownShopCard({
    super.key,
    required this.title,
    required this.shopType,
    required this.itemCount,
    required this.refreshCost,
  });

  final String title;
  final ShopType shopType;
  final int itemCount;
  final int refreshCost;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: title,
      description: itemCount == 0
          ? '아이템 없음'
          : '품목 $itemCount개 / 갱신 비용 $refreshCost',
      icon: Icons.storefront_outlined,
      onTap: () => _showShopSheet(context, title, shopType),
    );
  }

  void _showShopSheet(BuildContext context, String title, ShopType shopType) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TownShopSheet(title: title, shopType: shopType);
      },
    );
  }
}

class TownPotionSellCard extends StatelessWidget {
  const TownPotionSellCard({super.key, required this.stackCount});

  final int stackCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Potion Sell',
      description: stackCount == 0 ? '판매 가능한 포션 없음' : '판매 가능한 스택 $stackCount개',
      icon: Icons.sell_outlined,
      onTap: () => _showSellSheet(context),
    );
  }

  void _showSellSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const TownPotionSaleSheet();
      },
    );
  }
}
