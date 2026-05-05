import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';

import 'workshop_hatch_sheet.dart';

class WorkshopHatchCard extends StatelessWidget {
  const WorkshopHatchCard({super.key, required this.recipeCount});

  final int recipeCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Homunculus Hatch',
      summary: recipeCount == 0 ? '부화 가능한 레시피 없음' : '즉시 부화 가능 $recipeCount종',
      icon: Icons.egg_alt_outlined,
      onTap: () => _showHatchSheet(context),
    );
  }

  void _showHatchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const WorkshopHatchSheet();
      },
    );
  }
}
