import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/workshop_display_labels.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_inventory_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workshop_material_extraction_detail.dart';

class WorkshopExtractionSheet extends ConsumerWidget {
  const WorkshopExtractionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MaterialInventoryView> materials = ref.watch(
      materialInventoryViewsProvider,
    );

    return AppSheetLayout(
      title: '추출',
      header: const Text(
        '재료 선택',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      body: materials.isEmpty
          ? const Center(child: Text('추출 가능한 재료가 없습니다'))
          : ListView.builder(
              itemCount: materials.length,
              itemBuilder: (BuildContext context, int index) {
                final MaterialInventoryView entry = materials[index];
                return ListTile(
                  dense: true,
                  title: Text(entry.name),
                  subtitle: Text(
                    '${workshopMaterialRarityLabel(entry.rarity)} / 원소 ${entry.traitSummary}',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return WorkshopMaterialExtractionDetailDialog(
                            materialId: entry.id,
                          );
                        },
                      );
                    },
                    child: const Text('분석/추출'),
                  ),
                );
              },
            ),
    );
  }
}
