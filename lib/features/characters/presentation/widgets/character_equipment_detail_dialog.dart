import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_equipment_item_grid.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/equipment/equipment_detail_labels.dart';
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
    final List<String> lines = <String>[
      _slotLabel(item.slot),
      ...equipmentInstanceDetailLabels(item),
    ];

    return AppDialogLayout(
      title: item.name,
      body: DetailLines(lines: lines),
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
