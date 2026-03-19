import 'package:flutter/material.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

class WorkshopQueueJobList extends StatelessWidget {
  const WorkshopQueueJobList({
    super.key,
    required this.jobs,
    this.onClaimJob,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<CraftQueueJobView> jobs;
  final ValueChanged<String>? onClaimJob;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: shrinkWrap,
      physics: physics,
      children: jobs.map((CraftQueueJobView job) {
        return ListTile(
          dense: true,
          title: Text(job.title),
          subtitle: Text(
            job.resultText == null
                ? '${job.typeLabel} / ${job.statusText}'
                : '${job.typeLabel} / ${job.statusText}\n${job.resultText}',
          ),
          isThreeLine: job.resultText != null,
          trailing: job.canClaim
              ? FilledButton.tonal(
                  onPressed: onClaimJob == null ? null : () => onClaimJob!(job.id),
                  child: const Text('수령'),
                )
              : null,
        );
      }).toList(),
    );
  }
}
