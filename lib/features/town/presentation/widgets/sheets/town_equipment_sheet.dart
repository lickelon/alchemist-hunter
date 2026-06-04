import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/common/widgets/section_card.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/controllers/equipment_craft_controller.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_equipment_blueprint_selectors.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_equipment_inventory_selectors.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_equipment_view_models.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_forge_selectors.dart';
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
          SectionCard(
            title: '장비 등록',
            child: Column(
              children: blueprints
                  .map((TownEquipmentBlueprintView entry) {
                    return ListTile(
                      dense: true,
                      leading: CatalogAssetIcon(
                        assetPath: CatalogIconAssetPaths.equipment(entry.id),
                      ),
                      title: Text(entry.name),
                      subtitle: _EquipmentLabelBadges(
                        labels: <String>[
                          entry.slotLabel,
                          entry.statLabel,
                          entry.materialCostLabel,
                          '시간 ${entry.durationLabel}',
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
                  })
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: '진행',
            child: forgeJobs.isEmpty
                ? const AppEmptyState('진행 중인 작업이 없습니다')
                : Column(
                    children: forgeJobs
                        .map((TownForgeJobView entry) {
                          return ListTile(
                            dense: true,
                            title: Text(entry.name),
                            subtitle: _ForgeJobSummary(entry: entry),
                            trailing: FilledButton.tonal(
                              onPressed: entry.canClaim
                                  ? () {
                                      ref
                                          .read(
                                            equipmentCraftControllerProvider,
                                          )
                                          .claimCompleted(entry.id);
                                    }
                                  : null,
                              child: const Text('수령'),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: '보유 장비',
            child: inventory.isEmpty
                ? const AppEmptyState('보유 장비가 없습니다')
                : ResourceIconGrid(
                    items: inventory
                        .map((TownEquipmentInventoryView entry) {
                          return ResourceIconGridItem(
                            key: ValueKey<String>('town_equipment_${entry.id}'),
                            assetPath: CatalogIconAssetPaths.equipment(
                              entry.blueprintId,
                            ),
                            badgeLabel: entry.slotLabel,
                            semanticLabel: entry.name,
                            tooltipMessage: entry.name,
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
          ),
        ],
      ),
    );
  }
}

class _ForgeJobSummary extends StatelessWidget {
  const _ForgeJobSummary({required this.entry});

  final TownForgeJobView entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          AppBadge(label: entry.statusLabel),
          AppBadge(label: entry.remainingLabel),
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
      body: _EquipmentLabelBadges(
        labels: <String>['슬롯 ${entry.slotLabel}', entry.statLabel],
      ),
    );
  }
}

class _EquipmentLabelBadges extends StatelessWidget {
  const _EquipmentLabelBadges({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: labels
            .expand(_splitEquipmentLabel)
            .map((String label) => AppBadge(label: label))
            .toList(growable: false),
      ),
    );
  }
}

Iterable<String> _splitEquipmentLabel(String label) {
  return label
      .split('\n')
      .expand((String line) => line.split(' / '))
      .where((String part) => part.isNotEmpty);
}
