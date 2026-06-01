import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_equipment_selectors.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_potion_selectors.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_preview_selector.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:flutter/material.dart';

const double _kSelectorMaxHeight = ResourceIconGrid.twoRowMaxHeight;

class WorkshopEnchantPotionSelector extends StatelessWidget {
  const WorkshopEnchantPotionSelector({
    super.key,
    required this.potions,
    required this.selectedPotionStackKey,
    required this.onChanged,
  });

  final List<EnchantPotionView> potions;
  final String? selectedPotionStackKey;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final TextStyle subsectionTitleStyle = AppTextStyles.of(
      context,
    ).subsectionTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('포션 선택', style: subsectionTitleStyle),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _kSelectorMaxHeight),
          child: potions.isEmpty
              ? const AppEmptyState('인챈트에 사용할 포션이 없습니다')
              : ResourceIconGrid(
                  items: potions
                      .map((EnchantPotionView potion) {
                        return ResourceIconGridItem(
                          key: ValueKey<String>(
                            'enchant_potion_${potion.stackKey}',
                          ),
                          assetPath: CatalogIconAssetPaths.potion(
                            potion.potionId,
                          ),
                          badgeLabel: 'x${potion.quantity}',
                          semanticLabel: '${potion.name} x${potion.quantity}',
                          tooltipMessage:
                              '${potion.name} x${potion.quantity}\n품질 ${potion.qualityLabel} / 원소 ${potion.traitsLabel}',
                          selected: potion.stackKey == selectedPotionStackKey,
                          onTap: () => onChanged(potion.stackKey),
                        );
                      })
                      .toList(growable: false),
                ),
        ),
      ],
    );
  }
}

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
          constraints: const BoxConstraints(maxHeight: _kSelectorMaxHeight),
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

class WorkshopEnchantPreviewSection extends StatelessWidget {
  const WorkshopEnchantPreviewSection({super.key, required this.preview});

  final EnchantPreviewView? preview;

  @override
  Widget build(BuildContext context) {
    final TextStyle subsectionTitleStyle = AppTextStyles.of(
      context,
    ).subsectionTitle;
    final TextStyle dataEmphasisStyle = AppTextStyles.of(context).dataEmphasis;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('예상 결과', style: subsectionTitleStyle),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.interactive,
          ),
          child: preview == null
              ? const Text('포션과 장비를 선택하면 인챈트 결과를 미리 볼 수 있습니다')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(preview!.equipmentName, style: subsectionTitleStyle),
                    const SizedBox(height: AppSpacing.sm),
                    DetailLines(
                      lines: <String>[
                        '현재 ${preview!.currentEnchantLabel}',
                        '예상 ${preview!.nextEnchantLabel}',
                        preview!.currentStatLabel,
                        preview!.nextStatLabel,
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(preview!.deltaStatLabel, style: dataEmphasisStyle),
                    if (preview!.replaceRequired) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      const Text('기존 인챈트가 교체됩니다'),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
