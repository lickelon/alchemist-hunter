import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_equipment_selectors.dart';
import 'package:flutter/material.dart';

class WorkshopEnchantEquipmentSelector extends StatelessWidget {
  const WorkshopEnchantEquipmentSelector({
    super.key,
    required this.equipments,
    required this.selectedEquipmentId,
    required this.onChanged,
  });

  final List<EnchantEquipmentView> equipments;
  final String? selectedEquipmentId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final TextStyle subsectionTitleStyle = AppTextStyles.of(
      context,
    ).subsectionTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('장비 선택', style: subsectionTitleStyle),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: ResourceIconGrid.twoRowMaxHeight,
          ),
          child: equipments.isEmpty
              ? const AppEmptyState('인챈트 가능한 장비가 없습니다')
              : ResourceIconGrid(
                  items: equipments
                      .map((EnchantEquipmentView item) {
                        return ResourceIconGridItem(
                          key: ValueKey<String>(
                            'enchant_equipment_${item.equipmentId}',
                          ),
                          assetPath: CatalogIconAssetPaths.equipment(
                            item.blueprintId,
                          ),
                          badgeLabel: item.slotLabel,
                          semanticLabel: item.name,
                          tooltipMessage:
                              '${item.name}\n${item.locationLabel} / ${item.slotLabel}\n${item.statLabel}\n${item.enchantLabel}',
                          selected: item.equipmentId == selectedEquipmentId,
                          onTap: () => onChanged(item.equipmentId),
                        );
                      })
                      .toList(growable: false),
                ),
        ),
      ],
    );
  }
}
