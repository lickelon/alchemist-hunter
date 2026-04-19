import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

import 'workshop_queue_job_list.dart';

class WorkshopQueueSheet extends ConsumerWidget {
  const WorkshopQueueSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CraftQueueJobView> jobs = ref.watch(craftQueueJobViewsProvider);
    final WorkshopCraftQueueController controller = ref.read(
      workshopCraftQueueControllerProvider,
    );
    final int queueCapacity = ref.watch(workshopQueueCapacityProvider);

    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '제작 큐',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('슬롯 ${jobs.length}/$queueCapacity'),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: jobs.isEmpty
                ? const Center(child: Text('큐가 비어있습니다'))
                : WorkshopQueueJobList(
                    jobs: jobs,
                    onClaimJob: controller.claimJob,
                  ),
          ),
        ],
      ),
    );
  }
}
