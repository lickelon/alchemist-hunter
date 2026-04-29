import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:flutter/material.dart';

import 'workshop_extraction_sheet.dart';

class WorkshopExtractionCard extends StatelessWidget {
  const WorkshopExtractionCard({super.key, required this.materialTypeCount});

  final int materialTypeCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Extraction',
      summary: materialTypeCount == 0
          ? '추출 가능한 재료 없음'
          : '즉시 추출 재료 $materialTypeCount종',
      icon: Icons.biotech_outlined,
      onTap: () => _showExtractionSheet(context),
    );
  }

  void _showExtractionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const WorkshopExtractionSheet();
      },
    );
  }
}
