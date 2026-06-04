import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/controllers/mercenary_controller.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_mercenary_selectors.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_resource_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownMercenaryHireSheet extends ConsumerWidget {
  const TownMercenaryHireSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int gold = ref.watch(townGoldProvider);
    final List<TownMercenaryCandidateView> candidates = ref.watch(
      townMercenaryCandidateViewsProvider,
    );

    return AppSheetLayout(
      title: '용병 고용',
      header: AppBadge(label: '골드 $gold'),
      footer: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
              label: const Text('닫기'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FilledButton.tonal(
              onPressed: () {
                ref
                    .read(mercenaryControllerProvider)
                    .refreshMercenaryCandidates();
              },
              child: const Text('후보 갱신'),
            ),
          ),
        ],
      ),
      body: candidates.isEmpty
          ? const AppEmptyState('고용 후보가 없습니다')
          : ListView(
              children: candidates.map((TownMercenaryCandidateView entry) {
                return ListTile(
                  dense: true,
                  title: Text(entry.name),
                  subtitle: _MercenaryCandidateSummary(entry: entry),
                  trailing: FilledButton.tonal(
                    onPressed: entry.canHire
                        ? () {
                            ref
                                .read(mercenaryControllerProvider)
                                .hireMercenary(entry.id);
                          }
                        : null,
                    child: const Text('고용'),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _MercenaryCandidateSummary extends StatelessWidget {
  const _MercenaryCandidateSummary({required this.entry});

  final TownMercenaryCandidateView entry;

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
              AppBadge(label: entry.tierLabel),
              AppBadge(label: entry.roleLabel),
              AppBadge(label: '고용 ${entry.hireCost}'),
              if (!entry.canHire) AppBadge(label: '골드 부족'),
            ],
          ),
        ],
      ),
    );
  }
}
