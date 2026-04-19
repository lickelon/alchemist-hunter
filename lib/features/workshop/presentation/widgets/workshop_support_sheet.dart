import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
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

    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '작업실 보조 슬롯',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('배치 $assignedCount/$slotLimit명 / $summary'),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView(
              children: slots.map((WorkshopSupportSlotView slot) {
                final List<WorkshopSupportCandidateView> candidates = ref.watch(
                  workshopSupportCandidateViewsProvider(slot.slotId),
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${slot.slotLabel} 슬롯',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '현재 ${slot.assignedCharacterName} / 효과 ${slot.effectLabel}',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
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
                        const SizedBox(height: AppSpacing.md),
                        ...candidates.map((WorkshopSupportCandidateView item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
    );
  }
}
