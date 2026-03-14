import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

class WorkshopQueueJobList extends ConsumerWidget {
  const WorkshopQueueJobList({super.key, required this.jobs});

  final List<CraftQueueJobView> jobs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WorkshopCraftQueueController controller = ref.read(
      workshopCraftQueueControllerProvider,
    );

    return ListView(
      children: jobs.map((CraftQueueJobView job) {
        return ListTile(
          dense: true,
          title: Text(job.title),
          subtitle: Text(job.statusText),
          trailing: job.statusText.contains('재개 가능') || job.canResume
              ? FilledButton.tonal(
                  onPressed: job.canResume
                      ? () => controller.resumeBlocked(job.id)
                      : null,
                  child: const Text('재개'),
                )
              : null,
        );
      }).toList(),
    );
  }
}
