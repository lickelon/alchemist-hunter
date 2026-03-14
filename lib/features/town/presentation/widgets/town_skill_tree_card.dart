import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/sheets/town_skill_tree_sheet.dart';

class TownSkillTreeCard extends StatelessWidget {
  const TownSkillTreeCard({
    super.key,
    required this.unlockedCount,
    required this.totalCount,
  });

  final int unlockedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Town Skill Tree',
      description: '해금 $unlockedCount/$totalCount',
      icon: Icons.account_tree_outlined,
      onTap: () => _showSkillTreeSheet(context),
    );
  }

  void _showSkillTreeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const TownSkillTreeSheet();
      },
    );
  }
}
