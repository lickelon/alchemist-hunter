import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_job_selectors.dart';

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
          subtitle: _QueueJobMetaRow(job: job),
          trailing: job.canClaim
              ? FilledButton.tonal(
                  onPressed: onClaimJob == null
                      ? null
                      : () => onClaimJob!(job.id),
                  child: const Text('수령'),
                )
              : null,
        );
      }).toList(),
    );
  }
}

class _QueueJobMetaRow extends StatelessWidget {
  const _QueueJobMetaRow({required this.job});

  final CraftQueueJobView job;

  @override
  Widget build(BuildContext context) {
    final String? timeLabel = job.timeLabel;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          AppBadge(label: job.statusLabel),
          if (timeLabel != null)
            Text(
              timeLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
