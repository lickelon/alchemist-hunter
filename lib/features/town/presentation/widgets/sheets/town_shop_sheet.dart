import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
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
          Row(
            children: <Widget>[
              AppBadge(label: '골드 $refreshCost'),
              const SizedBox(width: AppSpacing.md),
              FilledButton.tonalIcon(
                onPressed: () {
                  ref.read(shopControllerProvider).forceRefresh(shopType);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('갱신'),
              ),
            ],
          ),
        ],
      ),
      body: shop.items.isEmpty
          ? const AppEmptyState('판매 재료가 없습니다')
          : ResourceIconGrid(
              items: shop.items
                  .map((ShopItem item) {
                    final bool soldOut = item.quantity <= 0;
                    final String badgeLabel = soldOut
                        ? '품절'
                        : 'x${item.quantity}';
                    return ResourceIconGridItem(
                      key: ValueKey<String>('shop_item_${item.materialId}'),
                      assetPath: CatalogIconAssetPaths.material(
                        item.materialId,
                      ),
                      badgeLabel: badgeLabel,
                      semanticLabel: '${item.name} $badgeLabel',
                      tooltipMessage: item.name,
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return _ShopItemDetailDialog(
                              item: item,
                              soldOut: soldOut,
                              nextRefreshLabel: _clockLabel(shop.nextRefreshAt),
                              onBuy: () {
                                if (shopType == ShopType.general) {
                                  ref
                                      .read(shopControllerProvider)
                                      .buyGeneralMaterial(item.materialId, 1);
                                } else {
                                  ref
                                      .read(shopControllerProvider)
                                      .buyCatalystMaterial(item.materialId, 1);
                                }
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                    );
                  })
                  .toList(growable: false),
            ),
    );
  }

  String _clockLabel(DateTime value) {
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ShopItemDetailDialog extends StatelessWidget {
  const _ShopItemDetailDialog({
    required this.item,
    required this.soldOut,
    required this.nextRefreshLabel,
    required this.onBuy,
  });

  final ShopItem item;
  final bool soldOut;
  final String nextRefreshLabel;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return AppDialogLayout(
      title: item.name,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CatalogAssetIcon(
            assetPath: CatalogIconAssetPaths.material(item.materialId),
            size: 64,
            padding: 8,
            semanticLabel: item.name,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '골드 ${item.price}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    AppBadge(label: soldOut ? '품절' : '재고 ${item.quantity}'),
                    if (soldOut) AppBadge(label: '다음 $nextRefreshLabel'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
          label: const Text('닫기'),
        ),
        FilledButton(
          onPressed: soldOut ? null : onBuy,
          child: Text(soldOut ? '품절' : '구매'),
        ),
      ],
    );
  }
}
