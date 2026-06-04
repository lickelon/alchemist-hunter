import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
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
      summary: assignedCount == 0 ? '보조 없음' : '배치 $assignedCount/$slotLimit',
      icon: Icons.groups_2_outlined,
      onTap: () => _showSupportSheet(context),
    );
  }

  void _showSupportSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const WorkshopSupportSheet();
      },
    );
  }
}
