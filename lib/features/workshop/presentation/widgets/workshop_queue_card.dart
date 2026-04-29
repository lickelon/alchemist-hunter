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
      summary: jobCount == 0 ? '대기 중 작업 없음' : '대기 중 작업 $jobCount건',
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
