import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
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
    final List<String> summaryLabels = ref.watch(
      workshopSupportSummaryProvider,
    );
    final List<WorkshopSupportSlotView> slots = ref.watch(
      workshopSupportSlotViewsProvider,
    );
    final TextStyle subsectionTitleStyle = AppTextStyles.of(
      context,
    ).subsectionTitle;

    return AppSheetLayout(
      title: '작업실 보조 슬롯',
      header: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          AppBadge(label: '배치 $assignedCount/$slotLimit'),
          ...summaryLabels.map((String label) => AppBadge(label: label)),
        ],
      ),
      body: ListView(
        children: <Widget>[
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
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: <Widget>[
                        AppBadge(label: slot.assignedCharacterName),
                        AppBadge(label: slot.effectLabel),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                tooltip: '상세',
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return _SupportCandidateDetailDialog(
                                        item: item,
                                      );
                                    },
                                  );
                                },
                              ),
                              if (item.selectedForSlot)
                                const Icon(Icons.check_circle_outline),
                            ],
                          ),
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
        ],
      ),
    );
  }
}

class _SupportCandidateDetailDialog extends StatelessWidget {
  const _SupportCandidateDetailDialog({required this.item});

  final WorkshopSupportCandidateView item;

  @override
  Widget build(BuildContext context) {
    final List<String> lines = <String>[
      item.supportEffectLabel,
      if (item.assignedToSlotLabel != null) item.assignedToSlotLabel!,
    ];
    return AppDialogLayout(
      title: item.name,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppBadge(label: item.roleLabel),
          const SizedBox(height: AppSpacing.lg),
          DetailLines(description: '보조', lines: lines),
        ],
      ),
    );
  }
}
