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
  });

  final String title;
  final ShopType shopType;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: title,
      summary: itemCount == 0 ? '판매 품목 없음' : '판매 품목 $itemCount개',
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
      name: '포션 판매',
      summary: stackCount == 0 ? '판매 대기 없음' : '판매 대기 $stackCount스택',
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
