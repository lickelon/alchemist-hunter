import 'package:flutter/material.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

class WorkshopQueueJobList extends StatelessWidget {
  const WorkshopQueueJobList({super.key, required this.jobs});

  final List<CraftQueueJobView> jobs;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: jobs.map((CraftQueueJobView job) {
        return ListTile(
          dense: true,
          title: Text(job.title),
          subtitle: Text('${job.typeLabel} / ${job.statusText}'),
        );
      }).toList(),
    );
  }
}
