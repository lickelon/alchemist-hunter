import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:flutter/material.dart';

class TownShopCard extends StatelessWidget {
  const TownShopCard({
    super.key,
    required this.title,
    required this.getItems,
    required this.getRefreshCost,
    required this.onBuy,
    required this.onRefresh,
  });

  final String title;
  final List<ShopItem> Function() getItems;
  final int Function() getRefreshCost;
  final ValueChanged<String> onBuy;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: title,
      description: getItems().isEmpty
          ? '아이템 없음'
          : '품목 ${getItems().length}개 / 갱신 비용 ${getRefreshCost()}',
      icon: Icons.storefront_outlined,
      onTap: () => _showShopSheet(context),
    );
  }

  void _showShopSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setModalState) {
            final List<ShopItem> items = getItems();
            final int refreshCost = getRefreshCost();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () {
                          onRefresh();
                          setModalState(() {});
                        },
                        child: Text('강제 갱신 ($refreshCost)'),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: items.isEmpty
                            ? const Center(child: Text('판매 아이템이 없습니다'))
                            : ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final ShopItem item = items[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text('${item.name} (${item.quantity})'),
                                    subtitle: Text('가격 ${item.price}'),
                                    trailing: FilledButton.tonal(
                                      onPressed: () {
                                        onBuy(item.materialId);
                                        setModalState(() {});
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
          },
        );
      },
    );
  }
}

class TownPotionSellCard extends StatelessWidget {
  const TownPotionSellCard({
    super.key,
    required this.getStacks,
    required this.getDetails,
    required this.onSell,
  });

  final Map<String, int> Function() getStacks;
  final Map<String, CraftedPotion> Function() getDetails;
  final ValueChanged<String> onSell;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Potion Sell',
      description: getStacks().isEmpty ? '판매 가능한 포션 없음' : '판매 가능한 스택 ${getStacks().length}개',
      icon: Icons.sell_outlined,
      onTap: () => _showSellSheet(context),
    );
  }

  void _showSellSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setModalState) {
            final Map<String, int> stacks = getStacks();
            final Map<String, CraftedPotion> details = getDetails();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('포션 판매', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: stacks.isEmpty
                            ? const Center(child: Text('판매 가능한 포션이 없습니다'))
                            : ListView(
                                children: stacks.entries.map((MapEntry<String, int> entry) {
                                  final CraftedPotion? detail = details[entry.key];
                                  return ListTile(
                                    dense: true,
                                    title: Text('${entry.key} x${entry.value}'),
                                    subtitle: Text(
                                      '품질 ${detail?.qualityGrade.name.toUpperCase() ?? '-'} / 점수 ${(detail?.qualityScore ?? 0).toStringAsFixed(2)}',
                                    ),
                                    trailing: FilledButton.tonal(
                                      onPressed: () {
                                        onSell(entry.key);
                                        setModalState(() {});
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
          },
        );
      },
    );
  }
}
