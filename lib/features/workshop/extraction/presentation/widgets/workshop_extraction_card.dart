import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'workshop_extraction_sheet.dart';

class WorkshopExtractionCard extends StatelessWidget {
  const WorkshopExtractionCard({super.key, required this.materialTypeCount});

  final int materialTypeCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '재료 추출',
      summary: materialTypeCount == 0 ? '재료 없음' : '재료 $materialTypeCount종',
      icon: Icons.biotech_outlined,
      onTap: () => _showExtractionSheet(context),
    );
  }

  void _showExtractionSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const WorkshopExtractionSheet();
      },
    );
  }
}
