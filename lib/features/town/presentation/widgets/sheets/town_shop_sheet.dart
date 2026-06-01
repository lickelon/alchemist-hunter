import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/controllers/shop_controller.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_shop_selectors.dart';
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

    return AppSheetLayout(
      title: title,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '상품별 주기 한도 ${shop.purchaseLimitPerItem}개 / '
            '${_durationLabel(shop.refreshInterval)}마다 재입고',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '다음 재입고 ${_clockLabel(shop.nextRefreshAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () {
                ref.read(shopControllerProvider).forceRefresh(shopType);
              },
              child: Text('강제 갱신 (골드 $refreshCost)'),
            ),
          ),
        ],
      ),
      body: shop.items.isEmpty
          ? const AppEmptyState('판매 재료가 없습니다')
          : ListView.builder(
              itemCount: shop.items.length,
              itemBuilder: (BuildContext context, int index) {
                final ShopItem item = shop.items[index];
                final bool soldOut = item.quantity <= 0;
                return ListTile(
                  dense: true,
                  title: Text(item.name),
                  subtitle: Text(
                    soldOut
                        ? '가격 골드 ${item.price} / 품절\n'
                              '다음 재입고 ${_clockLabel(shop.nextRefreshAt)}'
                        : '가격 골드 ${item.price} / 재고 ${item.quantity}',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: soldOut
                        ? null
                        : () {
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
                    child: Text(soldOut ? '품절' : '구매'),
                  ),
                );
              },
            ),
    );
  }

  String _clockLabel(DateTime value) {
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _durationLabel(Duration value) {
    if (value.inMinutes < 60) {
      return '${value.inMinutes}분';
    }
    if (value.inMinutes % 60 == 0) {
      return '${value.inHours}시간';
    }
    return '${value.inHours}시간 ${value.inMinutes % 60}분';
  }
}
