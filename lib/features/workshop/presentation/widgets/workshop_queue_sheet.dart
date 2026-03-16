import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

import 'workshop_enqueue_options_sheet.dart';
import 'workshop_queue_job_list.dart';

class WorkshopQueueSheet extends ConsumerWidget {
  const WorkshopQueueSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CraftQueueJobView> jobs = ref.watch(craftQueueJobViewsProvider);
    final WorkshopPendingClaimView pendingClaim = ref.watch(
      workshopPendingClaimViewProvider,
    );
    final List<PotionQueueOptionView> options = ref.watch(
      workshopPotionQueueOptionViewsProvider,
    );
    final WorkshopCraftQueueController controller = ref.read(
      workshopCraftQueueControllerProvider,
    );
    final int queueCapacity = ref.watch(workshopQueueCapacityProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '제작 큐',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('슬롯 ${jobs.length}/$queueCapacity'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      '작업실 보상 수령',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(pendingClaim.summary),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: pendingClaim.canClaim
                          ? controller.claimPending
                          : null,
                      child: const Text('통합 수령'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '포션 등록',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Expanded(
                flex: 3,
                child: options.isEmpty
                    ? const Center(child: Text('등록 가능한 포션이 없습니다'))
                    : ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final PotionQueueOptionView option = options[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(option.title),
                            subtitle: Text(
                              option.unlocked
                                  ? option.materialHint
                                  : '잠김: ${option.lockReason}',
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: option.unlocked && option.craftableNow
                                  ? () {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        builder:
                                            (BuildContext bottomSheetContext) {
                                              return WorkshopEnqueueOptionsSheet(
                                                potionId: option.potionId,
                                                title: option.title,
                                                maxCraftableCount:
                                                    option.maxCraftableCount,
                                              );
                                            },
                                      );
                                    }
                                  : null,
                              child: const Text('등록'),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(),
              const Text(
                '현재 대기열',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Expanded(
                flex: 2,
                child: jobs.isEmpty
                    ? const Center(child: Text('대기열이 비어있습니다'))
                    : WorkshopQueueJobList(jobs: jobs),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
