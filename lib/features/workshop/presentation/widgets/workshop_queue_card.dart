import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:flutter/material.dart';

import 'workshop_queue_sheet.dart';

class WorkshopQueueCard extends StatelessWidget {
  const WorkshopQueueCard({super.key, required this.jobCount});

  final int jobCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Craft Queue',
      description: jobCount == 0 ? '대기열이 비어있음' : '대기열 $jobCount개 작업',
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
