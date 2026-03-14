import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/sheets/town_equipment_sheet.dart';
import 'package:flutter/material.dart';

class TownEquipmentCraftCard extends StatelessWidget {
  const TownEquipmentCraftCard({super.key, required this.equipmentCount});

  final int equipmentCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Equipment Craft',
      description: equipmentCount == 0
          ? '제작 장비 없음'
          : '보유 장비 $equipmentCount개',
      icon: Icons.construction_outlined,
      onTap: () => _showEquipmentSheet(context),
    );
  }

  void _showEquipmentSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const TownEquipmentSheet();
      },
    );
  }
}
