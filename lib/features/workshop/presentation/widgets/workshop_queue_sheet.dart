import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
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
      child: AppSheetLayout(
        title: '제작 큐',
        header: Text('슬롯 ${jobs.length}/$queueCapacity'),
        body: jobs.isEmpty
            ? const Center(child: Text('큐가 비어있습니다'))
            : WorkshopQueueJobList(jobs: jobs, onClaimJob: controller.claimJob),
      ),
    );
  }
}
