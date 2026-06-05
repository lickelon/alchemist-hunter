import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
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
      header: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          AppBadge(label: '한도 ${shop.purchaseLimitPerItem}개'),
          AppBadge(label: '재입고 ${_durationLabel(shop.refreshInterval)}'),
          AppBadge(label: '다음 ${_clockLabel(shop.nextRefreshAt)}'),
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
                  subtitle: _ShopItemSummary(
                    price: item.price,
                    quantity: item.quantity,
                    soldOut: soldOut,
                    nextRefreshLabel: _clockLabel(shop.nextRefreshAt),
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
      footer: Row(
        children: <Widget>[
          AppBadge(label: '골드 $refreshCost'),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: () {
                ref.read(shopControllerProvider).forceRefresh(shopType);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('갱신'),
            ),
          ),
        ],
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

class _ShopItemSummary extends StatelessWidget {
  const _ShopItemSummary({
    required this.price,
    required this.quantity,
    required this.soldOut,
    required this.nextRefreshLabel,
  });

  final int price;
  final int quantity;
  final bool soldOut;
  final String nextRefreshLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              AppBadge(label: soldOut ? '품절' : '재고 $quantity'),
              if (soldOut) AppBadge(label: '다음 $nextRefreshLabel'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          DetailLines(lines: <String>['골드 $price']),
        ],
      ),
    );
  }
}
