import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:flutter/material.dart';

import 'workshop_extraction_sheet.dart';

class WorkshopExtractionCard extends StatelessWidget {
  const WorkshopExtractionCard({
    super.key,
    required this.materialTypeCount,
    required this.extractedTraitTypeCount,
  });

  final int materialTypeCount;
  final int extractedTraitTypeCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Extraction',
      description: '재료 $materialTypeCount종 / 추출 특성 $extractedTraitTypeCount종',
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
