import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/sheets/town_equipment_sheet.dart';
import 'package:flutter/material.dart';

class TownEquipmentCraftCard extends StatelessWidget {
  const TownEquipmentCraftCard({
    super.key,
    this.forgeQueueCount = 0,
    this.completedCount = 0,
  });

  final int forgeQueueCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '장비 제작',
      summary: completedCount > 0
          ? '수령 대기 $completedCount건'
          : forgeQueueCount > 0
          ? '제작 진행 $forgeQueueCount건'
          : '새 장비 제작 가능',
      icon: Icons.construction_outlined,
      onTap: () => _showEquipmentSheet(context),
    );
  }

  void _showEquipmentSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const TownEquipmentSheet();
      },
    );
  }
}
