import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownShopSheet extends ConsumerWidget {
  const TownShopSheet({super.key, required this.title, required this.shopType});

  final String title;
  final ShopType shopType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ShopState shop = ref.watch(
      shopType == ShopType.general
          ? generalShopStateProvider
          : catalystShopStateProvider,
    );
    final int refreshCost = ref.watch(
      shopType == ShopType.general
          ? generalShopRefreshCostProvider
          : catalystShopRefreshCostProvider,
    );

    return AppBottomSheet(
      child: AppSheetLayout(
        title: title,
        header: FilledButton.tonal(
          onPressed: () {
            ref.read(shopControllerProvider).forceRefresh(shopType);
          },
          child: Text('강제 갱신 (골드 $refreshCost)'),
        ),
        body: shop.items.isEmpty
            ? const Center(child: Text('판매 재료가 없습니다'))
            : ListView.builder(
                itemCount: shop.items.length,
                itemBuilder: (BuildContext context, int index) {
                  final ShopItem item = shop.items[index];
                  return ListTile(
                    dense: true,
                    title: Text('${item.name} (${item.quantity})'),
                    subtitle: Text('가격 골드 ${item.price}'),
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
    );
  }
}
