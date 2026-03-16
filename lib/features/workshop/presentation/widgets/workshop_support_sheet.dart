import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

class WorkshopSupportSheet extends ConsumerWidget {
  const WorkshopSupportSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int assignedCount = ref.watch(workshopSupportAssignedCountProvider);
    final int slotLimit = ref.watch(workshopSupportSlotLimitProvider);
    final String summary = ref.watch(workshopSupportSummaryProvider);
    final List<WorkshopSupportSlotView> slots = ref.watch(
      workshopSupportSlotViewsProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '작업실 보조 슬롯',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('배치 $assignedCount/$slotLimit명 / $summary'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: slots.map((WorkshopSupportSlotView slot) {
                    final List<WorkshopSupportCandidateView> candidates = ref.watch(
                      workshopSupportCandidateViewsProvider(slot.slotId),
                    );
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${slot.slotLabel} 슬롯',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '현재 ${slot.assignedCharacterName} / 효과 ${slot.effectLabel}',
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: candidates.map((
                                WorkshopSupportCandidateView item,
                              ) {
                                final String label = item.assignedToSlotLabel == null
                                    ? item.name
                                    : '${item.name} (${item.assignedToSlotLabel})';
                                return ChoiceChip(
                                  selected: item.selectedForSlot,
                                  onSelected: item.assignable
                                      ? (_) {
                                          ref
                                              .read(workshopSupportControllerProvider)
                                              .toggleAssignment(slot.slotId, item.id);
                                        }
                                      : null,
                                  label: Text(label),
                                );
                              }).toList(growable: false),
                            ),
                            const SizedBox(height: 8),
                            ...candidates.map((WorkshopSupportCandidateView item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '${item.name} / 역할 ${item.roleLabel} / 보조효과 ${item.supportEffectLabel}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
