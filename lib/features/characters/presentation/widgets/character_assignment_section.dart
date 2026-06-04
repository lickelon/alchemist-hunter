import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_detail_section.dart';
import 'package:flutter/material.dart';

class CharacterAssignmentSection extends StatelessWidget {
  const CharacterAssignmentSection({
    super.key,
    required this.assignmentLabel,
    required this.assignmentGuideLabel,
  });

  final String assignmentLabel;
  final String assignmentGuideLabel;

  @override
  Widget build(BuildContext context) {
    final String statusLabel = assignmentLabel.replaceFirst('배치 상태: ', '');
    return CharacterDetailSection(
      title: '배치 상태',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppBadge(label: statusLabel),
          const SizedBox(height: AppSpacing.sm),
          Text(
            assignmentGuideLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
