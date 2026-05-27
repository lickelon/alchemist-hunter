import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownEquipmentSheet extends ConsumerWidget {
  const TownEquipmentSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TownEquipmentBlueprintView> blueprints = ref.watch(
      townEquipmentBlueprintViewsProvider,
    );
    final List<TownForgeJobView> forgeJobs = ref.watch(
      townForgeJobViewsProvider,
    );
    final List<TownEquipmentInventoryView> inventory = ref.watch(
      townEquipmentInventoryViewsProvider,
    );

    return AppSheetLayout(
      title: '대장간',
      body: ListView(
        children: <Widget>[
          const _SheetSectionTitle('장비 등록'),
          const SizedBox(height: AppSpacing.md),
          ...blueprints.map((TownEquipmentBlueprintView entry) {
            return ListTile(
              dense: true,
              leading: CatalogAssetIcon(
                assetPath: CatalogIconAssetPaths.equipment(entry.id),
              ),
              title: Text(entry.name),
              subtitle: DetailLines(
                lines: <String>[
                  '${entry.slotLabel} / ${entry.statLabel}',
                  entry.materialCostLabel,
                  '제작 시간 ${entry.durationLabel}',
                ],
              ),
              trailing: FilledButton.tonal(
                onPressed: entry.canCraft
                    ? () {
                        ref
                            .read(equipmentCraftControllerProvider)
                            .craftEquipment(entry.id);
                      }
                    : null,
                child: const Text('등록'),
              ),
            );
          }),
          const Divider(),
          const _SheetSectionTitle('대장간 진행'),
          const SizedBox(height: AppSpacing.md),
          if (forgeJobs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text('등록된 대장간 작업이 없습니다'),
            )
          else
            ...forgeJobs.map((TownForgeJobView entry) {
              return ListTile(
                dense: true,
                title: Text(entry.name),
                subtitle: Text(
                  '${entry.statusLabel} / ${entry.remainingLabel}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: entry.canClaim
                      ? () {
                          ref
                              .read(equipmentCraftControllerProvider)
                              .claimCompleted(entry.id);
                        }
                      : null,
                  child: const Text('수령'),
                ),
              );
            }),
          const Divider(),
          const _SheetSectionTitle('보유 장비'),
          const SizedBox(height: AppSpacing.md),
          if (inventory.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text('보유 장비가 없습니다'),
            )
          else
            ResourceIconGrid(
              items: inventory
                  .map((TownEquipmentInventoryView entry) {
                    return ResourceIconGridItem(
                      key: ValueKey<String>('town_equipment_${entry.id}'),
                      assetPath: CatalogIconAssetPaths.equipment(
                        entry.blueprintId,
                      ),
                      badgeLabel: entry.slotLabel,
                      semanticLabel: entry.name,
                      tooltipMessage: '${entry.name}\n${entry.statLabel}',
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return _EquipmentInventoryDetailDialog(
                              entry: entry,
                            );
                          },
                        );
                      },
                    );
                  })
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}

class _EquipmentInventoryDetailDialog extends StatelessWidget {
  const _EquipmentInventoryDetailDialog({required this.entry});

  final TownEquipmentInventoryView entry;

  @override
  Widget build(BuildContext context) {
    return AppDialogLayout(
      title: entry.name,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('슬롯 ${entry.slotLabel}'),
          const SizedBox(height: AppSpacing.sm),
          Text(entry.statLabel),
        ],
      ),
    );
  }
}

class _SheetSectionTitle extends StatelessWidget {
  const _SheetSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.of(context).subsectionTitle);
  }
}
