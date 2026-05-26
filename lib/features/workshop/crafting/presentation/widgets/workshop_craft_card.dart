import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/craft_queue_option_selectors.dart';
import 'package:alchemist_hunter/features/workshop/dashboard/presentation/viewmodels/workshop_shared_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workshop_enqueue_options_sheet.dart';

class WorkshopCraftCard extends StatelessWidget {
  const WorkshopCraftCard({super.key, required this.craftableCount});

  final int craftableCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '포션 제작',
      summary: craftableCount == 0
          ? '즉시 제작 가능한 포션 없음'
          : '즉시 제작 가능 $craftableCount종',
      icon: Icons.local_drink_outlined,
      onTap: () => _showCraftSheet(context),
    );
  }

  void _showCraftSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const WorkshopCraftSheet();
      },
    );
  }
}

class WorkshopCraftSheet extends ConsumerWidget {
  const WorkshopCraftSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PotionQueueOptionView> options = ref.watch(
      workshopPotionQueueOptionViewsProvider,
    );
    final int queueLength = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.workshop.queue.length,
      ),
    );
    final int queueCapacity = ref.watch(workshopQueueCapacityProvider);
    final bool queueFull = queueLength >= queueCapacity;

    return AppSheetLayout(
      title: '포션 제조',
      header: queueFull
          ? Text('작업실 큐 가득 참 ($queueLength/$queueCapacity)')
          : null,
      body: options.isEmpty
          ? const Center(child: Text('등록 가능한 포션이 없습니다'))
          : ListView.builder(
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final PotionQueueOptionView option = options[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CatalogAssetIcon(
                    assetPath: CatalogIconAssetPaths.potion(option.potionId),
                    size: 36,
                    padding: 5,
                  ),
                  title: Text(option.title),
                  subtitle: Text(
                    option.unlocked
                        ? option.materialHint
                        : '잠김: ${option.lockReason}',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed:
                        option.unlocked &&
                            option.craftableNow &&
                            !option.queueFull
                        ? () {
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return WorkshopEnqueueOptionsDialog(
                                  potionId: option.potionId,
                                  title: option.title,
                                  maxCraftableCount: option.maxCraftableCount,
                                );
                              },
                            );
                          }
                        : null,
                    child: const Text('등록'),
                  ),
                );
              },
            ),
    );
  }
}
