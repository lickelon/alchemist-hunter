import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:flutter/material.dart';

import 'workshop_queue_sheet.dart';

class WorkshopQueueCard extends StatelessWidget {
  const WorkshopQueueCard({
    super.key,
    required this.jobCount,
    this.claimSummary = '수령 가능한 작업실 보상 없음',
  });

  final int jobCount;
  final String claimSummary;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Craft Queue',
      description: '대기열 $jobCount개 / $claimSummary',
      icon: Icons.playlist_add_check_circle_outlined,
      onTap: () => _showQueueSheet(context),
    );
  }

  void _showQueueSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const WorkshopQueueSheet();
      },
    );
  }
}
