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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '용병 고용',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('보유 골드 $gold'),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  ref
                      .read(mercenaryControllerProvider)
                      .refreshMercenaryCandidates();
                },
                child: const Text('후보 갱신'),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: candidates.isEmpty
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
            ],
          ),
        ),
      ),
    );
  }
}
