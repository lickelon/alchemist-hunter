import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/widgets/workshop_enchant_sheet.dart';

class WorkshopEnchantCard extends StatelessWidget {
  const WorkshopEnchantCard({super.key, required this.canEnchant});

  final bool canEnchant;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '인챈트',
      summary: canEnchant ? '가능' : '준비 필요',
      icon: Icons.auto_fix_high_outlined,
      onTap: () => _showEnchantSheet(context),
    );
  }

  void _showEnchantSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const WorkshopEnchantSheet();
      },
    );
  }
}
