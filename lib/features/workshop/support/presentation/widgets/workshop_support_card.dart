import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';

import 'workshop_support_sheet.dart';

class WorkshopSupportCard extends StatelessWidget {
  const WorkshopSupportCard({
    super.key,
    required this.assignedCount,
    required this.slotLimit,
  });

  final int assignedCount;
  final int slotLimit;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '작업실 지원',
      summary: assignedCount == 0
          ? '배치된 보조 없음'
          : '보조 배치 $assignedCount/$slotLimit명',
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
