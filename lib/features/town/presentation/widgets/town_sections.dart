import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/application/workshop_providers.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/town/application/town_providers.dart';

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
        return _TownShopSheet(title: title, shopType: shopType);
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
        return const _TownPotionSellSheet();
      },
    );
  }
}

class _TownShopSheet extends ConsumerWidget {
  const _TownShopSheet({required this.title, required this.shopType});

  final String title;
  final ShopType shopType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ShopState shop = ref.watch(
      shopType == ShopType.general
          ? generalShopStateProvider
          : catalystShopStateProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  ref.read(townControllerProvider).forceRefresh(shopType);
                },
                child: Text('강제 갱신 (${shop.forcedRefreshCost})'),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: shop.items.isEmpty
                    ? const Center(child: Text('판매 아이템이 없습니다'))
                    : ListView.builder(
                        itemCount: shop.items.length,
                        itemBuilder: (BuildContext context, int index) {
                          final ShopItem item = shop.items[index];
                          return ListTile(
                            dense: true,
                            title: Text('${item.name} (${item.quantity})'),
                            subtitle: Text('가격 ${item.price}'),
                            trailing: FilledButton.tonal(
                              onPressed: () {
                                if (shopType == ShopType.general) {
                                  ref
                                      .read(townControllerProvider)
                                      .buyGeneralMaterial(item.materialId, 1);
                                } else {
                                  ref
                                      .read(townControllerProvider)
                                      .buyCatalystMaterial(item.materialId, 1);
                                }
                              },
                              child: const Text('구매'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TownPotionSellSheet extends ConsumerWidget {
  const _TownPotionSellSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CraftedPotionStackView> views = ref.watch(
      craftedPotionStackViewsProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '포션 판매',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: views.isEmpty
                    ? const Center(child: Text('판매 가능한 포션이 없습니다'))
                    : ListView(
                        children: views.map((CraftedPotionStackView entry) {
                          return ListTile(
                            dense: true,
                            title: Text('${entry.stackKey} x${entry.quantity}'),
                            subtitle: Text(
                              '품질 ${entry.qualityLabel} / 점수 ${entry.scoreLabel}',
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: () {
                                ref
                                    .read(
                                      workshopCraftedInventoryControllerProvider,
                                    )
                                    .sellCraftedPotion(entry.stackKey, 1);
                              },
                              child: const Text('판매'),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
