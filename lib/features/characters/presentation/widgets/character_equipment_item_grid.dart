import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_view_models.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_equipment_detail_dialog.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_detail_labels.dart';
import 'package:flutter/material.dart';

class CharacterEquipmentItemGrid extends StatelessWidget {
  const CharacterEquipmentItemGrid({
    super.key,
    required this.character,
    required this.slot,
    required this.onEquip,
    required this.showDetailDialog,
  });

  final CharacterProgress character;
  final CharacterEquipmentSlotView slot;
  final void Function(String characterId, String equipmentId) onEquip;
  final bool showDetailDialog;

  @override
  Widget build(BuildContext context) {
    if (slot.availableItems.isEmpty) {
      return const AppEmptyState('장착 가능한 장비가 없습니다');
    }
    return ResourceIconGrid(
      items: slot.availableItems.map((EquipmentInstance item) {
        final String actionLabel = slot.equippedItem == null ? '장착' : '교체';
        return ResourceIconGridItem(
          key: ValueKey<String>('character_equipment_${item.id}'),
          assetPath: CatalogIconAssetPaths.equipment(item.blueprintId),
          badgeLabel: characterEquipmentSlotBadgeLabel(item.slot),
          semanticLabel: item.name,
          tooltipMessage: '${item.name}\n${equipmentInstanceDetailLabel(item)}',
          onTap: () {
            if (!showDetailDialog) {
              Navigator.of(context).pop();
              onEquip(character.id, item.id);
              return;
            }
            showDialog<void>(
              context: context,
              builder: (BuildContext dialogContext) {
                return CharacterEquipmentDetailDialog(
                  item: item,
                  actionLabel: actionLabel,
                  onEquip: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                    onEquip(character.id, item.id);
                  },
                );
              },
            );
          },
        );
      }).toList(),
    );
  }
}

String characterEquipmentSlotBadgeLabel(EquipmentSlot slot) {
  return switch (slot) {
    EquipmentSlot.weapon => '무기',
    EquipmentSlot.armor => '방어구',
    EquipmentSlot.accessory => '장신구',
  };
}
