import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';

import 'workshop_hatch_sheet.dart';

class WorkshopHatchCard extends StatelessWidget {
  const WorkshopHatchCard({
    super.key,
    required this.recipeCount,
    required this.homunculusCount,
  });

  final int recipeCount;
  final int homunculusCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Homunculus Hatch',
      description: '레시피 $recipeCount종 / 보유 호문쿨루스 $homunculusCount체',
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
