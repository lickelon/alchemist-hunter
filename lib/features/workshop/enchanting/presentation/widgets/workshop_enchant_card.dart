import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/widgets/workshop_enchant_sheet.dart';

class WorkshopEnchantCard extends StatelessWidget {
  const WorkshopEnchantCard({super.key, required this.canEnchant});

  final bool canEnchant;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Enchant',
      summary: canEnchant ? '즉시 인챈트 가능' : '인챈트 준비 필요',
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
