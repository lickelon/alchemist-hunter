import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_enchant_sheet.dart';

class WorkshopEnchantCard extends StatelessWidget {
  const WorkshopEnchantCard({
    super.key,
    required this.potionStackCount,
    required this.equipmentCount,
  });

  final int potionStackCount;
  final int equipmentCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Enchant',
      description: potionStackCount == 0 || equipmentCount == 0
          ? '즉시 인챈트 준비 부족 / 포션 $potionStackCount스택 / 장비 $equipmentCount개'
          : '즉시 인챈트 가능 / 포션 $potionStackCount스택 / 장비 $equipmentCount개',
      icon: Icons.auto_fix_high_outlined,
      onTap: () => _showEnchantSheet(context),
    );
  }

  void _showEnchantSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const WorkshopEnchantSheet();
      },
    );
  }
}
