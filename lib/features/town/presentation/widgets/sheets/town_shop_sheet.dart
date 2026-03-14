import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownShopSheet extends ConsumerWidget {
  const TownShopSheet({
    super.key,
    required this.title,
    required this.shopType,
  });

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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  ref.read(shopControllerProvider).forceRefresh(shopType);
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
                                      .read(shopControllerProvider)
                                      .buyGeneralMaterial(item.materialId, 1);
                                } else {
                                  ref
                                      .read(shopControllerProvider)
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
