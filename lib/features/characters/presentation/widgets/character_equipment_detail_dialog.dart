import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_equipment_item_grid.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/equipment_display_labels.dart';
import 'package:flutter/material.dart';

class CharacterEquipmentDetailDialog extends StatelessWidget {
  const CharacterEquipmentDetailDialog({
    super.key,
    required this.item,
    required this.actionLabel,
    required this.onEquip,
  });

  final EquipmentInstance item;
  final String actionLabel;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    return AppDialogLayout(
      title: item.name,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(_slotLabel(item.slot)),
          const SizedBox(height: AppSpacing.sm),
          Text(equipmentInstanceStatLabel(item)),
          if (item.enchant != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text('인챈트 ${item.enchant!.label}'),
          ],
          if (item.totalStatModifiers.isNotEmpty ||
              item.totalModifiers.isNotEmpty ||
              item.totalPassives.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(equipmentInstanceEffectLabel(item)),
          ],
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
        FilledButton(onPressed: onEquip, child: Text(actionLabel)),
      ],
    );
  }
}

String _slotLabel(EquipmentSlot slot) {
  return '슬롯 ${characterEquipmentSlotBadgeLabel(slot)}';
}
