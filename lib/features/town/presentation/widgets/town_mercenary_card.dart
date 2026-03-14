import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/sheets/town_mercenary_hire_sheet.dart';

class TownMercenaryHireCard extends StatelessWidget {
  const TownMercenaryHireCard({
    super.key,
    required this.candidateCount,
    required this.mercenaryCount,
  });

  final int candidateCount;
  final int mercenaryCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Mercenary Hire',
      description: '후보 $candidateCount명 / 보유 용병 $mercenaryCount명',
      icon: Icons.groups_outlined,
      onTap: () => _showHireSheet(context),
    );
  }

  void _showHireSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const TownMercenaryHireSheet();
      },
    );
  }
}
