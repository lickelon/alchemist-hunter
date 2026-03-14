import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_skill_tree_sheet.dart';

class WorkshopSkillTreeCard extends StatelessWidget {
  const WorkshopSkillTreeCard({
    super.key,
    required this.unlockedCount,
    required this.totalCount,
  });

  final int unlockedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Workshop Skill Tree',
      description: '해금 $unlockedCount/$totalCount',
      icon: Icons.hub_outlined,
      onTap: () => _showSkillTreeSheet(context),
    );
  }

  void _showSkillTreeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const WorkshopSkillTreeSheet();
      },
    );
  }
}
