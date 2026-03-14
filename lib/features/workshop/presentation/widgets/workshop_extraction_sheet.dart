import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

import 'workshop_material_extraction_detail.dart';
import 'workshop_trait_inventory_strip.dart';

class WorkshopExtractionSheet extends ConsumerWidget {
  const WorkshopExtractionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MaterialInventoryView> materials = ref.watch(
      materialInventoryViewsProvider,
    );
    final List<ExtractedTraitInventoryView> extractedTraits = ref.watch(
      extractedTraitViewsProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '추출',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                '보유 추출 특성',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              WorkshopTraitInventoryStrip(traits: extractedTraits),
              const Divider(),
              const Text(
                '재료 선택',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: materials.isEmpty
                    ? const Center(child: Text('추출 가능한 재료가 없습니다'))
                    : ListView.builder(
                        itemCount: materials.length,
                        itemBuilder: (BuildContext context, int index) {
                          final MaterialInventoryView entry = materials[index];
                          return ListTile(
                            dense: true,
                            title: Text(entry.name),
                            subtitle: Text(
                              '${entry.rarity.name} / ${entry.traitSummary}',
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext detailContext) {
                                    return WorkshopMaterialExtractionDetail(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
