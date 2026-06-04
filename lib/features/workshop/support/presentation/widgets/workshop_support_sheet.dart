import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
import 'package:alchemist_hunter/common/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_controller.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_assignment_selectors.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_candidate_selectors.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_view_models.dart';

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
    final TextStyle subsectionTitleStyle = AppTextStyles.of(
      context,
    ).subsectionTitle;

    return AppSheetLayout(
      title: '작업실 보조 슬롯',
      header: Text('배치 $assignedCount/$slotLimit명'),
      body: ListView(
        children: <Widget>[
          Text(
            summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...slots.map((WorkshopSupportSlotView slot) {
            final List<WorkshopSupportCandidateView> candidates = ref.watch(
              workshopSupportCandidateViewsProvider(slot.slotId),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: SectionCard(
                title: '${slot.slotLabel} 슬롯',
                titleStyle: subsectionTitleStyle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DetailLines(
                      lines: <String>[
                        '현재 ${slot.assignedCharacterName}',
                        '효과 ${slot.effectLabel}',
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...candidates.map((WorkshopSupportCandidateView item) {
                      return Card.outlined(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          dense: true,
                          title: Text(item.name),
                          subtitle: _SupportCandidateSummary(item: item),
                          trailing: item.selectedForSlot
                              ? const Icon(Icons.check_circle_outline)
                              : null,
                          onTap: item.assignable
                              ? () {
                                  ref
                                      .read(workshopSupportControllerProvider)
                                      .toggleAssignment(slot.slotId, item.id);
                                }
                              : null,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SupportCandidateSummary extends StatelessWidget {
  const _SupportCandidateSummary({required this.item});

  final WorkshopSupportCandidateView item;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              AppBadge(label: item.roleLabel),
              if (item.assignedToSlotLabel != null)
                AppBadge(label: item.assignedToSlotLabel!),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.supportEffectLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
