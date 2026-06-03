import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/workshop_craft_queue_controller.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/workshop_craft_queue_controller_provider.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_job_selectors.dart';
import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_resource_selectors.dart';

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

    return AppSheetLayout(
      title: '제작 큐',
      header: Text('슬롯 ${jobs.length}/$queueCapacity'),
      body: jobs.isEmpty
          ? const AppEmptyState('대기 중인 작업이 없습니다')
          : WorkshopQueueJobList(jobs: jobs, onClaimJob: controller.claimJob),
    );
  }
}
