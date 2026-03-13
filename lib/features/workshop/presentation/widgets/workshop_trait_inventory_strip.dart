import 'package:flutter/material.dart';

import 'package:alchemist_hunter/features/workshop/application/workshop_providers.dart';

class WorkshopTraitInventoryStrip extends StatelessWidget {
  const WorkshopTraitInventoryStrip({super.key, required this.traits});

  final List<ExtractedTraitInventoryView> traits;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: traits.isEmpty
          ? const Center(child: Text('추출된 특성이 없습니다'))
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                final ExtractedTraitInventoryView entry = traits[index];
                return Chip(
                  label: Text(
                    '${entry.name} ${entry.amount.toStringAsFixed(2)}',
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemCount: traits.length,
            ),
    );
  }
}
