import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/sheets/town_equipment_sheet.dart';
import 'package:flutter/material.dart';

class TownEquipmentCraftCard extends StatelessWidget {
  const TownEquipmentCraftCard({
    super.key,
    required this.equipmentCount,
    this.forgeQueueCount = 0,
    this.completedCount = 0,
  });

  final int equipmentCount;
  final int forgeQueueCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Equipment Craft',
      description:
          '보유 장비 $equipmentCount개 / 대장간 진행 $forgeQueueCount건 / 완료 $completedCount건',
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
