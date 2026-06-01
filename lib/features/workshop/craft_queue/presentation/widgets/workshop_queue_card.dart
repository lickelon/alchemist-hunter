import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'workshop_queue_sheet.dart';

class WorkshopQueueCard extends StatelessWidget {
  const WorkshopQueueCard({
    super.key,
    required this.jobCount,
    required this.description,
  });

  final int jobCount;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '제작 대기열',
      summary: description,
      icon: Icons.playlist_add_check_circle_outlined,
      onTap: () => _showQueueSheet(context),
    );
  }

  void _showQueueSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const WorkshopQueueSheet();
      },
    );
  }
}
