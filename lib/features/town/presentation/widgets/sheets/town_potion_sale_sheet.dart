import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_potion_sale_controller.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_potion_sale_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownPotionSaleSheet extends ConsumerWidget {
  const TownPotionSaleSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TownPotionSaleView> views = ref.watch(
      townPotionSaleViewsProvider,
    );

    return AppSheetLayout(
      title: '포션 판매',
      body: views.isEmpty
          ? const AppEmptyState('판매 가능한 포션이 없습니다')
          : ResourceIconGrid(
              items: views
                  .map((TownPotionSaleView entry) {
                    return ResourceIconGridItem(
                      key: ValueKey<String>('sale_potion_${entry.stackKey}'),
                      assetPath: CatalogIconAssetPaths.potion(entry.potionId),
                      badgeLabel: 'x${entry.quantity}',
                      semanticLabel: '${entry.name} x${entry.quantity}',
                      tooltipMessage:
                          '${entry.name} x${entry.quantity}\n품질 ${entry.qualityLabel} / 점수 ${entry.scoreLabel}\n판매가 ${entry.saleValue}',
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return _PotionSaleDetailDialog(
                              entry: entry,
                              onSell: () {
                                Navigator.of(dialogContext).pop();
                                ref
                                    .read(townPotionSaleControllerProvider)
                                    .sellCraftedPotion(entry.stackKey, 1);
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
}

class _PotionSaleDetailDialog extends StatelessWidget {
  const _PotionSaleDetailDialog({required this.entry, required this.onSell});

  final TownPotionSaleView entry;
  final VoidCallback onSell;

  @override
  Widget build(BuildContext context) {
    return AppDialogLayout(
      title: entry.name,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('보유 수량 x${entry.quantity}'),
          const SizedBox(height: AppSpacing.sm),
          Text('품질 ${entry.qualityLabel}'),
          const SizedBox(height: AppSpacing.sm),
          Text('점수 ${entry.scoreLabel}'),
          const SizedBox(height: AppSpacing.sm),
          Text('판매가 ${entry.saleValue}'),
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
        FilledButton(onPressed: onSell, child: const Text('판매')),
      ],
    );
  }
}
