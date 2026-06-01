import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_potion_selectors.dart';
import 'package:flutter/material.dart';

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
          constraints: const BoxConstraints(
            maxHeight: ResourceIconGrid.twoRowMaxHeight,
          ),
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
