import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';

import 'workshop_support_sheet.dart';

class WorkshopSupportCard extends StatelessWidget {
  const WorkshopSupportCard({
    super.key,
    required this.assignedCount,
    required this.slotLimit,
    required this.summary,
  });

  final int assignedCount;
  final int slotLimit;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Workshop Support',
      description: '배치 $assignedCount/$slotLimit명 / $summary',
      icon: Icons.groups_2_outlined,
      onTap: () => _showSupportSheet(context),
    );
  }

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const WorkshopSupportSheet();
      },
    );
  }
}
