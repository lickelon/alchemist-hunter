import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';
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

    return AppBottomSheet(
      child: AppSheetLayout(
        title: '용병 고용',
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('보유 골드 $gold'),
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonal(
              onPressed: () {
                ref
                    .read(mercenaryControllerProvider)
                    .refreshMercenaryCandidates();
              },
              child: const Text('후보 갱신'),
            ),
          ],
        ),
        body: candidates.isEmpty
            ? const Center(child: Text('고용 후보가 없습니다'))
            : ListView(
                children: candidates.map((TownMercenaryCandidateView entry) {
                  return ListTile(
                    dense: true,
                    title: Text(entry.name),
                    subtitle: Text(
                      '${entry.tierLabel} / ${entry.roleLabel}\n고용 비용 ${entry.hireCost}${entry.hireHint}',
                    ),
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
      ),
    );
  }
}
