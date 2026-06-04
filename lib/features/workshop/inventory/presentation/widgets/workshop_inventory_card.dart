import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/inventory/presentation/widgets/workshop_inventory_sheet.dart';
import 'package:flutter/material.dart';

class WorkshopInventoryCard extends StatelessWidget {
  const WorkshopInventoryCard({
    super.key,
    required this.materialTypeCount,
    required this.traitTypeCount,
    required this.potionStackCount,
  });

  final int materialTypeCount;
  final int traitTypeCount;
  final int potionStackCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '작업실 보관함',
      summary: potionStackCount > 0
          ? '포션 $potionStackCount스택'
          : traitTypeCount > 0
          ? '원소 $traitTypeCount종'
          : materialTypeCount > 0
          ? '재료 $materialTypeCount종'
          : '자원 없음',
      icon: Icons.inventory_2_outlined,
      onTap: () => _showInventorySheet(context),
    );
  }

  void _showInventorySheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const WorkshopInventorySheet();
      },
    );
  }
}
