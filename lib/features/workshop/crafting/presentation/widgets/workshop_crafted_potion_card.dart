import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafted_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_resource_detail_dialogs.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_resource_icon_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopCraftedPotionCard extends StatelessWidget {
  const WorkshopCraftedPotionCard({super.key, required this.stackCount});

  final int stackCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '완성 포션',
      summary: stackCount == 0 ? '완성 포션 없음' : '포션 스택 $stackCount개',
      icon: Icons.local_drink_outlined,
      onTap: () => _showPotionSheet(context),
    );
  }

  void _showPotionSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const _WorkshopCraftedPotionSheet();
      },
    );
  }
}

class _WorkshopCraftedPotionSheet extends ConsumerWidget {
  const _WorkshopCraftedPotionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CraftedPotionStackView> potions = ref.watch(
      craftedPotionStackViewsProvider,
    );

    return AppSheetLayout(
      title: '완성 포션 상세',
      body: potions.isEmpty
          ? const Center(child: Text('완성 포션이 없습니다'))
          : WorkshopResourceIconGrid(
              items: potions.map((CraftedPotionStackView entry) {
                return WorkshopResourceIconGridItem(
                  key: ValueKey<String>('crafted_potion_${entry.stackKey}'),
                  assetPath: CatalogIconAssetPaths.potion(entry.potionId),
                  badgeLabel: 'x${entry.quantity}',
                  semanticLabel: '${entry.name} x${entry.quantity}',
                  tooltipMessage:
                      '${entry.name} x${entry.quantity}\n품질 ${entry.qualityLabel} / 점수 ${entry.scoreLabel}',
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return WorkshopPotionResourceDetailDialog(
                          potion: entry,
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
